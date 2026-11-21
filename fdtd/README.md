# FDTD: Maxwell's equations on a metal donut

Content generated with DeepSeek Pro AI assistance.

A small, self-contained 2D finite-difference time-domain (FDTD) simulator.

## Physics

We solve the **transverse-magnetic (TMz)** mode of Maxwell's equations. The only
electric-field component is `Ez` (pointing in the Z direction out of the "page" or x-y
coordinate plane); the magnetic field lives in the page as `(Hx, Hy)`. Faraday's law and
Ampère's law reduce to three scalar update equations:

```
∂Ez/∂t = (1/ε₀) (∂Hy/∂x − ∂Hx/∂y)
∂Hx/∂t = −(1/μ₀) ∂Ez/∂y
∂Hy/∂t =  (1/μ₀) ∂Ez/∂x
```

FDTD discretises these on a staggered **Yee lattice**: `E` samples live on the grid, `H`
samples are offset by half a cell. A central-difference leapfrog update steps `E` and `H`
forward in time.

The scatterer is a **metal donut** (a conducting annulus with a metal rod through its centre).
Metal cells force `Ez = 0` — a perfect-electric-conductor boundary — which is a stable, first
approximation to a strongly conducting ring. A Gaussian-enveloped sinusoidal "soft source"
launches a broadband pulse that propagates left-to-right and scatters off the donut.

The output is VP9-encoded WebM, ready to embed in HTML5.

## Notes

- The timestep `dt = dl / (c₀ √2)` satisfies the 2D Courant–Friedrichs–Lewy (CFL) stability
  condition.
- Source frequency is chosen so the wavelength is well resolved by the grid (`dl ≪ λ`).
