%% Important post-processing definitions
% These are sensible defaults.

config.shift_flex = @(x) x - min(x); % Offset so min flex (extension) is 0
% config.shift_flex = @(x) x + 120 - max(x); % Offset so max flexion is 120.


config.print_single_runs = true; % Print individual runs to file. They are located in the Results folder for each specimen/knee state.
config.step_size = 1; % quantisation step size for output data. i.e., flexion is grouped in intervals of 1 or 0.5 or n.
config.average_runs = true; % Whether to take intraspecimen mean. Suggest to keep true.
config.split_flex_ext = false; % Split flexion from extension arc

config.digitisation = {'digit', 'calibr'}; % Case insensitive digitisation file names. If it contains any of these texts, treats it as a digitisation file

% Smoothing functions are very computationally expensive. Suggest no intraspecimen smoothing intraspecimen.
% Intraspecimen
config.fill_missing_quantisation = @(x) fillmissing(x, "linear"); % Missing quanta are filled with this function. E.g., have flexion angles 40 and 42; it fills the 41 linearly.
config.intraspecimen_smoothing = @(x) x; % @(x) x => no smoothing

% Interspecimen
config.interpolation_algorithm = @(x, v, xq) interp1(x, v, xq, "pchip"); % Should be changed to to generalised cross-validated cubic spline-interpolation.
config.interspecimen_smoothing = @(x) smoothdata(x, "gaussian", 10); 

config.intact_name = "Intact";
%% Tracker labels
% These should be changed if the labels used for the trackers change.

% Polaris labels: determined by either looking at its name
% (e.g., Brainlab Y Junction) or the label defined in the .tbr file.
label.polaris.tibia = 'T';
label.polaris.femur = 'Y';
label.polaris.patella = '';
label.polaris.probe = 'Probe';

% Certus labels: Names used for each tracker in the data files.
% The way we find the Certus probe is defined in lib/configure/is_certus_probe.
label.certus.tibia = 'tibia';
label.certus.femur = 'femur';
label.certus.patella = 'patella';
label.certus.probe = 'Probe'; % Don't change this even if the probe is called something else.


%% STL files
config.stl.tibia_left = "models/tibia-left.stl";
config.stl.tibia_right = "models/tibia-right.stl";
config.stl.femur_left = "models/femur-left.stl";
config.stl.femur_right = "models/femur-right.stl";

%% Misc
% Change the rendering in images from tex to latex.
% If the serifs annoy you, just comment out this line.
set(0,'defaulttextinterpreter','latex')
set(groot, 'DefaultLineLineWidth', 1);
profile on; % Allows you to track performance by running `profile viewer` after the program runs.
diary("log.txt"); % Creates a file called log.txt which tracks everything happening in the console. Good for checking history of your runs.
warning('off', 'backtrace'); % Removes where warnings are coming from. Remove if you want to figure out where warnings are coming from.
warning('off', 'MATLAB:MKDIR:DirectoryExists'); % Stop spamming that folders already exist. Do not remove this.