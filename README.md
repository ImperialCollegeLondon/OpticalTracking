# Optical Tracking using Polaris Vega

## Usage
Run `main.m`.
A window will popup to pick the folder with calibration files.
They must include the bone and its position, e.g., `tibia-medial`, `Tibia lateral`, or `femur_proximal`.
If such file cannot be found, it will look `TM` in place of tibia-medial, `FL` in place of femur-lateral, etc.

Once calibration is complete, another popup window will show up. Pick the folder with the test runs.

## Overview
Optical tracking consists of two stages.

Define the coordinate systems:
1. Digitisation of landmarks (femur, tibia, patella,...)
2. Definition of bone coordinate system
3. Definition of tracker coordinate system
4. Calculation of bone-to-tracker transform

Process tracked data:
1. Import tracked data
2. Define dynamic tracker positions
3. Calculate dynamic bone positions

The definition of the coordinate systems comes from `create_rigid_bodies()`, and calculation of the transform is in `bone_to_tracker_transform.m`.
All processing of tracked data is in `run_data.m`.
## Naming convention
Variables names convey the frame of reference, whether it's a transform or a position vector, the bone and the point in time.

A variable named `gTt0` is trying to convey the following notation:
```math
_gT_{t_0}
```
which means that we define a **transform** ($T$) in the **global** ($_g$) frame of reference that describes the **tibia**'s ($t$) position in the initial instant ($_0$).
In other words, the matrix that describes transforming from **global** to **tibial** frame of reference. 

Similarly, the variable `Pin1_r_tc` is:
```math
_{\text{Pin1}}r_{t_c}
```
which means that in **Pin 1**'s ($_{\text{Pin1}}$) frame of reference, we define a position vector ($r$) for the **tibia**'s origin ($_t$).

## Visualising a frame of reference change
`Pin1_T_t = gT_Pin1_t\gTt`, the change of frame of reference can be visualised like so:
```math
\begin{align*}
_{\text{Pin1}}T_{t_c} &= {\left[ _gT_{\text{Pin1}} \right]}^{-1} \cdot \left[_gT_{t}\right] \\
    & = \left[ _{\text{Pin1}}T_{g} \right] \cdot \left[_gT_{t}\right] \\
    & = \left[ _{\text{Pin1}}T_{\cancel{g}} \right] \cdot \left[\cancel{_g}T_{t}\right] \\
    & = \left[ _{\text{Pin1}}T_{t}\right] \\
\end{align*}
```
