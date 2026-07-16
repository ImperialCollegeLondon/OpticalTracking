%% Load the paths and check if postprocessing framework is installed
addpath(genpath('lib'))
addpath(genpath('external'))
if exist('Trajectory', 'class') ~= 8
    error(['Could not detect Post-processing framework in %s', '%sexternal%s\nPlease download it from https://github.com/ImperialCollegeLondon/opticaltracking-postprocess'], pwd, filesep, filesep);
end

%% Misc
% Change the rendering in images from tex to latex.
% If the serifs annoy you, just comment out this line.
% set(0,'defaulttextinterpreter','latex')
set(groot, 'DefaultLineLineWidth', 1);
profile on; % Allows you to track performance by running `profile viewer` after the program runs.
diary("log.txt"); % Creates a file called log.txt which tracks everything happening in the console. Good for checking history of your runs.
warning('off', 'backtrace'); % Removes where warnings are coming from. Remove if you want to figure out the source of warnings without turning them into errors with config.debug
warning('off', 'MATLAB:MKDIR:DirectoryExists'); % Stop spamming that folders already exist. Do not remove this.