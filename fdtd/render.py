"""Render FDTD Ez snapshots to WebM by applying a colormap directly to the
field array and writing frames with imageio.v3."""

import numpy as np
import matplotlib.pyplot as plt
import imageio.v3 as iio


def _colormap(field, cmap, vmin, vmax):
    norm = np.clip((field - vmin) / (vmax - vmin), 0.0, 1.0)
    return cmap(norm)[..., :3]


def _panel(field, metal, cmap, vmin, vmax):
    rgb = _colormap(field, cmap, vmin, vmax)
    return np.where(metal[None, ..., None], 0.0, rgb)


def _downsample(frames, metal, target):
    n, nx, ny = frames.shape
    tx, ty = target
    if tx >= nx and ty >= ny:
        return frames, metal
    y = np.linspace(0, ny, ty + 1, endpoint=True).astype(int)
    x = np.linspace(0, nx, tx + 1, endpoint=True).astype(int)
    f = np.stack([
        frames[:, x[i]:x[i + 1], :][:, :, y[j]:y[j + 1]].mean(axis=(1, 2))
        for i in range(tx) for j in range(ty)
    ], axis=1).reshape(n, tx, ty)
    m = np.stack([
        metal[x[i]:x[i + 1], :][:, y[j]: y[j + 1]].any()
        for i in range(tx) for j in range(ty)
    ]).reshape(tx, ty)
    return f, m


def render_webm(frames, metal, out_path, mode="ez", fps=30, size=None):
    n, nx, ny = frames.shape
    eps = 1e-12

    if size is not None:
        frames, metal = _downsample(frames, metal, size)

    if mode == "ez":
        vmax = np.abs(frames).max(axis=(1, 2), keepdims=True) + eps
        rgb = _panel(frames, metal, plt.cm.seismic, -vmax, vmax)
    elif mode == "energy":
        energy = frames ** 2
        vmax = energy.max(axis=(1, 2), keepdims=True) + eps
        rgb = _panel(energy, metal, plt.cm.magma, 0.0, vmax)
    elif mode == "log":
        log = np.log10(frames ** 2 + 1e-6)
        vmax = log.max(axis=(1, 2), keepdims=True)
        rgb = _panel(log, metal, plt.cm.magma, vmax - 4.0, vmax)
    elif mode in ("hx", "hy"):
        vmax = np.abs(frames).max(axis=(1, 2), keepdims=True) + eps
        rgb = _panel(frames, metal, plt.cm.seismic, -vmax, vmax)
    elif mode == "all":
        vmax = np.abs(frames).max(axis=(1, 2), keepdims=True) + eps
        ez = _panel(frames, metal, plt.cm.seismic, -vmax, vmax)
        energy = frames ** 2
        vmax_en = energy.max(axis=(1, 2), keepdims=True) + eps
        en = _panel(energy, metal, plt.cm.magma, 0.0, vmax_en)
        log = np.log10(frames ** 2 + 1e-6)
        vmax_log = log.max(axis=(1, 2), keepdims=True)
        lg = _panel(log, metal, plt.cm.magma, vmax_log - 4.0, vmax_log)
        rgb = np.concatenate([ez, en, lg], axis=1)
    else:
        raise ValueError(f"unknown mode {mode!r}")

    rgb = np.transpose(rgb, (0, 2, 1, 3))[:, ::-1]
    iio.imwrite(out_path, (rgb * 255).astype("uint8"), fps=fps,
                codec="libvpx-vp9")