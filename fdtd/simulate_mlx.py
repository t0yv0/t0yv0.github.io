"""2D FDTD simulation of Maxwell's equations (TMz) around a metal donut.

MLX runs natively on the Apple GPU (Metal/MPS) and exposes JAX-style function transforms
(``mx.compile``, ``mx.vmap``, ``mx.grad``).

The FDTD time loop is expressed as an explicit Python ``for`` loop over a small
``@mx.compile``-d ``step`` function. The step body is traced once and compiled to a Metal
kernel; the loop itself stays on the host and drives state forward. Because MLX builds lazily
and dispatches asynchronously, we only ``mx.eval`` when we actually need to read a snapshot
back, so the GPU work batches across steps instead of synchronizing every iteration.

Run from this directory:
    uv run python simulate_mlx.py --render ez --video donut-ez.webm

"""

from __future__ import annotations

import argparse
from dataclasses import dataclass

import mlx.core as mx
import numpy as np


C0 = 299_792_458.0
MU0 = 4.0 * np.pi * 1e-7
EPS0 = 1.0 / (MU0 * C0 * C0)


@dataclass
class Grid:
    """A cell-centered domain on which the field is sampled."""

    nx: int
    ny: int
    dl: float          # cell size, meters

    @property
    def shape(self) -> tuple[int, int]:
        return (self.nx, self.ny)


def sample_points(g: Grid) -> tuple[mx.array, mx.array]:
    xs = (mx.arange(g.nx) + 0.5) * g.dl
    ys = (mx.arange(g.ny) + 0.5) * g.dl
    return xs, ys


def material_masks(g: Grid, center_x: float, center_y: float,
                   donut_r_in: float, donut_r_out: float,
                   rod_radius: float) -> mx.array:
    """Return a boolean mask that is True on metal (non-air) cells."""
    xs, ys = sample_points(g)
    gx, gy = mx.meshgrid(xs, ys, indexing="ij")
    rx = gx - center_x
    ry = gy - center_y
    r = mx.sqrt(rx * rx + ry * ry)

    in_annulus = (r >= donut_r_in) & (r <= donut_r_out)
    in_rod = r <= rod_radius
    return mx.where(in_annulus | in_rod, True, False)


def _update_h(hx, hy, ez, ch, dl):
    dez_dy = (mx.roll(ez, -1, axis=1) - ez) / dl
    dez_dx = (mx.roll(ez, -1, axis=0) - ez) / dl
    new_hx = hx - ch * dez_dy
    new_hy = hy + ch * dez_dx
    return new_hx, new_hy


def _update_e(hx, hy, ez, metal, ce, dl):
    dhy_dx = (hy - mx.roll(hy, 1, axis=0)) / dl
    dhx_dy = (hx - mx.roll(hx, 1, axis=1)) / dl
    new_ez = ez + ce * (dhy_dx - dhx_dy)
    return mx.where(metal, 0.0, new_ez)


def sponge_mask(g: Grid, width: int) -> mx.array:
    xs, ys = sample_points(g)
    gx, gy = mx.meshgrid(xs, ys, indexing="ij")
    d_left = gx / g.dl
    d_right = (g.nx - 1) - gx / g.dl
    d_bottom = gy / g.dl
    d_top = (g.ny - 1) - gy / g.dl
    d = mx.minimum(mx.minimum(d_left, d_right),
                   mx.minimum(d_bottom, d_top))
    return mx.clip(d / width, 0.0, 1.0)


def run_simulation(g: Grid, metal: mx.array, num_steps: int,
                   source_amp: float, source_freq: float,
                   source_x: float,
                   record_every: int = 1) -> tuple[np.ndarray, Grid]:
    """Run the FDTD loop and return recorded Ez snapshots.

    Returns an array of shape (num_frames, nx, ny).
    """
    dt = float(g.dl * np.sqrt(1.0 / 2.0) / C0)
    ce = float(dt / EPS0)
    ch = float(dt / MU0)

    hx = mx.zeros(g.shape, dtype=mx.float32)
    hy = mx.zeros(g.shape, dtype=mx.float32)
    ez = mx.zeros(g.shape, dtype=mx.float32)

    xs, ys = sample_points(g)
    gx, gy = mx.meshgrid(xs, ys, indexing="ij")
    src_mask = mx.abs(gx - source_x) < g.dl * 0.5
    damp = sponge_mask(g, width=40)

    # A single fused, compiled FDTD step. State advances through the
    # (hx, hy, ez) tuple; the returned fields are fed back into the next
    # iteration. Everything the step needs is passed explicitly so ``compile``
    # can trace it cleanly (no captured MLX arrays as implicit constants).
    amp = float(source_amp)
    freq = float(source_freq)
    omega = float(2.0 * np.pi * freq)
    three_periods = float(3.0 / freq)
    dl = float(g.dl)

    @mx.compile
    def step(hx, hy, ez, metal, src_mask, damp, ce, ch, t):
        hx, hy = _update_h(hx, hy, ez, ch, dl)
        ez = _update_e(hx, hy, ez, metal, ce, dl)

        ramp = mx.minimum(1.0, t / three_periods)
        val = amp * ramp * mx.sin(omega * t)
        ez = ez + mx.where(src_mask, val, 0.0)
        ez = ez * damp
        return hx, hy, ez

    hx_frames = []
    hy_frames = []
    ez_frames = []
    for n in range(num_steps):
        hx, hy, ez = step(hx, hy, ez, metal, src_mask, damp,
                          ce, ch, float(n) * dt)
        if n % record_every == 0:
            mx.eval(hx, hy, ez)
            hx_frames.append(np.asarray(hx))
            hy_frames.append(np.asarray(hy))
            ez_frames.append(np.asarray(ez))

    mx.eval(hx, hy, ez)
    return {
        "hx": np.stack(hx_frames),
        "hy": np.stack(hy_frames),
        "ez": np.stack(ez_frames),
    }, g


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser()
    p.add_argument("--nx", type=int, default=640)
    p.add_argument("--ny", type=int, default=480)
    p.add_argument("--dl", type=float, default=2.5e-3, help="cell size in meters")
    p.add_argument("--steps", type=int, default=2000)
    p.add_argument("--record-every", type=int, default=5)
    p.add_argument("--freq", type=float, default=5.0e9, help="source freq Hz")
    p.add_argument("--amp", type=float, default=1.0)
    p.add_argument("--render",
                   choices=["ez", "energy", "log", "all", "hx", "hy"],
                   default="all")
    p.add_argument("--video", type=str, default=None,
                   help="output WebM path (writes video if provided)")
    p.add_argument("--fps", type=int, default=30)
    p.add_argument("--render-size", type=int, nargs=2, metavar=("NX", "NY"),
                   default=None,
                   help="downsample field to NXxNY before colormapping (default: full res)")
    return p.parse_args()


def main() -> None:
    args = parse_args()
    g = Grid(args.nx, args.ny, args.dl)

    domain_x = args.nx * args.dl
    domain_y = args.ny * args.dl
    cx, cy = domain_x / 2.0, domain_y / 2.0
    metal = material_masks(
        g,
        center_x=cx, center_y=cy,
        donut_r_in=0.18 * domain_x, donut_r_out=0.26 * domain_x,
        rod_radius=0.03 * domain_x,
    )

    fields, g = run_simulation(
        g, metal,
        num_steps=args.steps,
        source_amp=args.amp,
        source_freq=args.freq,
        source_x=0.12 * domain_x,
        record_every=args.record_every,
    )

    n = fields["ez"].shape[0]
    print(f"Simulated {n} frames of shape {g.shape}.")

    if args.render == "hx":
        frames = fields["hx"]
    elif args.render == "hy":
        frames = fields["hy"]
    else:
        frames = fields["ez"]

    if args.video:
        from render import render_webm
        render_webm(frames, np.asarray(metal), args.video,
                    mode=args.render, fps=args.fps,
                    size=tuple(args.render_size) if args.render_size else None)
        print(f"Wrote {args.video}")


if __name__ == "__main__":
    main()
