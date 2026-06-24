# Camera module
The `Camera` class is an enumeration of all available cameras, and the definition of how turn their data into `Tracker` objects.

To read a single data file, use `Camera.load_data('path/to/file.csv')`. It will create a matrix of `Tracker` and `PassiveStray` to represent all the trackers and strays available during that recording.

The proper way to use the code is through `load_data('path/to/dir')`, which is a thin wrapper around `Camera`'s `load_data()` function. It reads all files in a directory at once, assigning landmarks and labels to each tracker.

# Creating new cameras
When a new camera is introduced to the lab, the following definitions need to be updated:
- Camera enumeration
- How to distinguish that camera from others
- How to assign camera data into a tracker
