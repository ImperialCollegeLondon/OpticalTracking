% These are sensible defaults.
% Please read them anyway, especially Settings and Run flags.

%% Settings
config.print_single_runs = true; % Print individual runs to file. They are located in the Results folder for each specimen/knee state.
config.step_size = 1; % quantisation step size for output data. i.e., flexion is grouped in intervals of 1, 0.5, 0.2, etc. Suggest 1.
config.average_runs = true; % Whether to take intraspecimen mean. Suggest true.
config.split_flex_ext = false; % Split flexion from extension arc
config.digitisation_angle = 0; % Angle of the knee when it was digitised
config.intact_name = "Intact"; % Usually "Intact" or "Native". Must be consistent with file naming.
%% Run flags
config.enable_raw_plot = true; % Creates plots of translations/rotations over time. Suggest enable config.debug as well, otherwise this produces hundreds of popups.
config.show_minima = true;
config.debug = true; % Generates landmark visualisation, run splitting plots, allows errors to stop execution, etc.
% If something is not working, set config.debug = true. Prepare for spam.
config.digitisation_correction = false;
config.plot_missing_data = false;

config.enable_warn_arc_of_flexion = true; % Warn if arc arc of flexion is less than `config.warn_arc_of_flexion`
config.warn_arc_of_flexion = 50; % Warn if arc arc of flexion is less than
%% Post-processing definitions
% Smoothing functions are very computationally expensive. Suggest no intraspecimen smoothing intraspecimen.
% Intraspecimen
config.fill_missing_quantisation = @(x) fillmissing(x, "linear"); % Missing quanta are filled with this function. E.g., have flexion angles 40 and 42; it fills the 41 linearly.
config.intraspecimen_smoothing = @(x) smoothdata(x, "gaussian", 10); % @(x) x => no smoothing

 % Interspecimen
config.interpolation_algorithm = @(x, v, xq) interp1(x, v, xq, "pchip");
config.interspecimen_smoothing = @(x) smoothdata(x, "gaussian", 10); 

config.shift_flex = @(x) x; % No flexion shift
% config.shift_flex = @(x) x - min(x); % Offset so min flex (extension) is 0
% config.shift_flex = @(x) x + 120 - max(x); % Offset so max flexion is 120.

%% Definitions that automate runs.
% Substrings in the folder name to determine if it's left or right knee:
config.right = {'rk', 'right', 'r'};
config.left = {'lk', 'left', 'l'};

config.digitisation = {'digit', 'calibr'}; % Case insensitive digitisation file names. If it contains any of these texts, treats it as a digitisation file

%% Tracker labels
% These should be changed if the labels used for the trackers change.

% Polaris labels: determined by either looking at its name
% (e.g., Brainlab Y Junction) or the label defined in the .tbr file.
config.polaris.tibia = 'T';
config.polaris.femur = 'Y';
config.polaris.patella = '';
config.polaris.probe = 'Probe';

% Certus labels: Names used for each tracker in the data files.
% The way we find the Certus probe is defined in lib/configure/is_certus_probe.
config.certus.tibia = 'tibia';
config.certus.femur = 'femur';
config.certus.patella = 'patella';
config.certus.probe = 'Probe'; % Don't change this even if the probe is called something else.

%% STL files
config.stl.tibia_left = "models/tibia-left.stl";
config.stl.tibia_right = "models/tibia-right.stl";
config.stl.femur_left = "models/femur-left.stl";
config.stl.femur_right = "models/femur-right.stl";

%% Create the config

% config = Config(config);

%% Misc
% Change the rendering in images from tex to latex.
% If the serifs annoy you, just comment out this line.
set(0,'defaulttextinterpreter','latex')
set(groot, 'DefaultLineLineWidth', 1);
profile on; % Allows you to track performance by running `profile viewer` after the program runs.
diary("log.txt"); % Creates a file called log.txt which tracks everything happening in the console. Good for checking history of your runs.
warning('off', 'backtrace'); % Removes where warnings are coming from. Remove if you want to figure out the source of warnings without turning them into errors with config.debug
warning('off', 'MATLAB:MKDIR:DirectoryExists'); % Stop spamming that folders already exist. Do not remove this.
