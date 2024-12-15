# Optical Tracking using Polaris Vega

## Usage
Run `main.m`.
A window will popup to pick the folder with calibration files.
They must include the bone and its position, e.g., `tibia-medial`, `Tibia lateral`, or `femur_proximal`.
If such file cannot be found, it will look `TM` in place of tibia-medial, `FL` in place of femur-lateral, etc.

Once calibration is complete, another popup window will show up. Pick the folder with the test runs.

## Overview
To understand what this code does, take a look at this image. We're assuming the z-axis is 0 to make life easier.
![rigid-bodies-demonstration](https://github.com/user-attachments/assets/224b66f0-a5d4-4d39-88bf-66405e6e7944)

The blue and red are objects in space with orientations based on their x and y axes.
The optical tracking camera gives us the black x,y axes (the _global_ frame of reference), but we are interested in the motion of the blue object relative to the red.

The origin of the ![blue](https://placehold.co/15x15/0000ff/0000ff.png) blue object could be described as `(2,1,0)` in the ![black](https://placehold.co/15x15/000/000.png)global reference, or `(1,-1, 0)` relative to the ![red](https://placehold.co/15x15/ff0000/ff0000.png) red object.
In our notation, these would be:
```math
_gr_b = \begin{bmatrix} 2 \\\ 1 \\\ 0 \end{bmatrix} \quad \quad _rr_b = \begin{bmatrix} 1 \\\ -1 \\\ 0 \end{bmatrix}
```

### What about rotation?
Let's consider ![red](https://placehold.co/15x15/ff0000/ff0000.png) red object first to show what no rotation looks like.
The transform that represents rotations and translations is a 4x4 matrix. 
```math
_gT_r = \begin{bmatrix} R & t \\\ 0 & 1\end{bmatrix} = 
\begin{bmatrix}
R_{xx} & R_{xy} & R_{xz} & t_x \\\
R_{yx} & R_{yy} & R_{yz} & t_y \\\
R_{zx} & R_{zy} & R_{zz} & t_z \\\
0 & 0 & 0 & 1
\end{bmatrix} 
```
`t`, the translations, are x,y,z translations from the global frame of reference to the object. From the image we can see that is `x: 1`, `y: 2`, `z:0`
```math
_gT_r = 
\begin{bmatrix}
R_{xx} & R_{xy} & R_{xz} & 1 \\\
R_{yx} & R_{yy} & R_{yz} & 2 \\\
R_{zx} & R_{zy} & R_{zz} & 0 \\\
0 & 0 & 0 & 1
\end{bmatrix} 
```

each column of `R`, the rotations, shows how the unit vectors are orientated relative to the global frame of reference. We can see that the unit vectors for both the global and the red object are orientated the same way.
```math
\quad _g\hat{i}_g  = \begin{bmatrix} 1 \\\ 0 \\\ 0 \end{bmatrix} \quad\quad \text{and} \quad\quad _g\hat{i}_r = \begin{bmatrix} 1 \\\ 0 \\\ 0 \end{bmatrix} \quad\quad\quad\quad\\\
\quad _g\hat{j}_g  = \begin{bmatrix} 0 \\\ 1 \\\ 0 \end{bmatrix} \quad\quad \text{and} \quad\quad _g\hat{j}_r = \begin{bmatrix} 0 \\\ 1 \\\ 0 \end{bmatrix} \quad\text{...etc}
```
Which means we end up with a ![red](https://placehold.co/15x15/ff0000/ff0000.png) red transformation matrix that looks something like:
```math
_gT_r = 
\begin{bmatrix}
1 & 0 & 0 & 1 \\\
0 & 1 & 0 & 2 \\\
0 & 0 & 1 & 0 \\\
0 & 0 & 0 & 1
\end{bmatrix} 
```

If we apply the same logic to the blue object and assume, say, 60 degrees, then the `i` unit vector (x axis) has rotated like so: 
```math
 _g\hat{i}_b = \begin{bmatrix}
\frac{1}{2} \\\ \frac{\sqrt{3}}{2} \\\ 0
\end{bmatrix}
```
Doing the same to `j` and `k` and including the translation vector to create the transform that describes, in the ![black](https://placehold.co/15x15/000/000.png) global frame of reference, the ![blue](https://placehold.co/15x15/0000ff/0000ff.png) blue object:
```math
_gT_b = 
\begin{bmatrix}
\frac{1}{2} & -\frac{\sqrt{3}}{2}  & 0 & 2 \\\
\frac{\sqrt{3}}{2} & \frac{1}{2} & 0 & 1 \\\
0 & 0 & 1 & 0 \\\
0 & 0 & 0 & 1
\end{bmatrix} 
```
or, in the ![red](https://placehold.co/15x15/ff0000/ff0000.png) red frame of reference, the ![blue](https://placehold.co/15x15/0000ff/0000ff.png) blue object has this transform:
```math
_rT_b = 
\begin{bmatrix}
\frac{1}{2} & -\frac{\sqrt{3}}{2}  & 0 & 1 \\\
\frac{\sqrt{3}}{2} & \frac{1}{2} & 0 & -1 \\\
0 & 0 & 1 & 0 \\\
0 & 0 & 0 & 1
\end{bmatrix} 
```

## Optical Tracking
Optical tracking consists of two stages where we repeatedly apply the transformations described above

### Define the coordinate systems
We define landmarks on bones that roughly represent their functional axes. Then attach trackers to each bone, which will be captured by the camera.
1. Digitisation of landmarks
2. Definition of bone coordinate system
3. Definition of tracker coordinate system
4. Calculation of bone-to-tracker transform

### Process tracked data
Apply the motion (translations and rotations) captured through the trackers to the landmarks. Describe the motion of the bones relative to each other.
1. Import tracked data
2. Define dynamic tracker positions
3. Calculate dynamic bone positions

The definition of the coordinate systems comes from `landmarks = create_landmarks()`, and calculation of the transform is in `trackers = bone_to_tracker_transform()`.
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
