clc;clear; close all;
run(fullfile("lib", "configure", "defaults.m"));
%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Important post-processing definitions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
is_right_knee = false; % true if right knee; false if left knee. There's other code to determine this if you follow the standard.
config.step_size = 1; % quantisation step size for output data. i.e., flexion is grouped in intervals of 0.5 or 1 or n.
config.average_runs = true; % Whether to take intraspecimen mean. Suggest to keep true.
config.split_flex_ext = false; % Split flexion from extension arc
config.smoothing = @(x) smoothdata(x, "gaussian"); % Smoothing function
config.shift_flex = @(x) x - min(x); % Offset so max extension is 0
% config.shift_flex = @(x) x + 120 - max(x); % Offset so max flexion is 120.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Tracker labels
% These should be change if the labels used for the trackers change.

% Polaris labels: determined by either looking at its name
% (e.g., Brainlab Y Junction) or the label defined in the .tbr file.
label.polaris.tibia = 'T';
label.polaris.femur = 'Y';
label.polaris.patella = '';
label.polaris.probe = 'Probe';
% Certus labels: Names used for each tracker in the data files.
% Expects probe to have any name that contains a whitespace but include the word "Port", e.g. "a b".
% Whitespaces rule can be found in load_data_certus() and "Port" rule is in load_data().
label.certus.tibia = 'tibia';
label.certus.femur = 'femur';
label.certus.patella = 'patella';
label.certus.probe = 'Probe'; % Don't change this even if the probe is called something else.
% Certus probe just needs to have a space in the name and it'll be found.

%% Create calibration files
disp("Choose the calibration folder");
fp_digitisation = uigetdir(".", "Choose the digitisation folder");

[root, ~, ~] = fileparts(fp_digitisation);
root_ls = get_root_files(root, {'digit', 'calibr'}); % Second argument is a list of folders to exclude.
% 'digit' covers variations of digitisation, digitize, digitise, etc.

% Determine if right or left knee
% Expects specimen folder to be called: SpecimenName_xxxxxxxx_Right,
% or SpecimenName_xxxxxxxx_LK (case insensitive)
config.is_right_knee = get_knee_side(root, is_right_knee, {'rk', 'right'}, {'lk', 'left'});

specimen_name = get_specimen_name(root); % Assign specimen name based on folder name.
%% Load digitisation
[digitisation, new_config, ~] = load_data(fp_digitisation, label);
config = merge_config(config, new_config);

if config.is_polaris
    % disp("Detected Polaris data.");
    config.label = label.polaris;
else
    % disp("Detected Certus data.")
    config.label = label.certus;
end
%% Create trackers
% Clean up headers and create a nicer structure
landmark_raw = organise_data(digitisation, config);
% Assign the rigid body landmarks using the probe, and create their respective trackers
landmarks = create_landmarks(landmark_raw, config);
% Calculate bone to tracker transforms in global coordinate system
trackers = bone_to_tracker_transform(landmarks, config);
% %% Visualisation of Landmarks
% plot_landmarks(landmarks, config.is_right_knee);

%% Load experiment data
disp("Choose the run folder")
fp_data = uigetdir(".", "Choose the run folder");
try
    [data_raw, ~, idx_interpolation] = load_data(fp_data, config.label);
catch ME
    if any(contains({ME.stack.name}, "label", "IgnoreCase",true))
        warning("Insufficient tracker data recorded. Check that you are recording all trackers.");
    end
end

%% Run
data_all_probes = organise_data(data_raw, config);
    for i = 1:numel(data_raw)
        loading_condition = data_all_probes(i).name;
        input.name = loading_condition;
        % Assign the tracker to the right bone.
        input.tibia = extract_from_label(data_all_probes(i).probes, config.label.tibia);
        input.femur = extract_from_label(data_all_probes(i).probes, config.label.femur);
        input.patella = extract_from_label(data_all_probes(i).probes, config.label.patella);
    
        [data(i), transforms(i)] = calculate_joint_kinematics(input, trackers, config.is_right_knee);
    end
%% STL
% stl_plot(config, transforms(1).in_global.tibia, transforms(1).in_global.femur, 1.2)

%% Plot
plot_intraspecies(data, specimen_name);

%%
function plot_intraspecies(data, specimen_name)
%% PLOT_INTRASPECIES    plots all states 
test_run = {data.name};

for j = 1:numel(test_run)
    figure(j);
    tiledlayout(3,2);
        datum = config.intraspecimen_smoothing(data(j).tibiofemoral);
        % flex = data.(state)(j).tibiofemoral.flexion;
        % ext = data.(state)(j).tibiofemoral.extension;
        plotting(datum);

    sgt = sgtitle({specimen_name test_run{j}});
    sgt.Interpreter = "latex";
    sgt.FontSize = 20;
end
end

function plotting(data)
line_width = 1;
% Varus
nexttile(1); hold on; grid on;

plot(data.flexion, data.varus, 'LineWidth', line_width)

title("Varus rotation")
xlabel('Flexion ($\circ$)')
ylabel('Varus ($\circ$) +ve')
% External
nexttile(2); hold on; grid on;

plot(data.flexion, data.external, 'LineWidth', line_width)
title("External rotation")
xlabel('Flexion ($\circ$)')
ylabel('External (mm) +ve')

% Lateral
nexttile(3); hold on; grid on;
plot(data.flexion, data.lateral, 'LineWidth', line_width)

title("Lateral translation")
xlabel('Flexion ($\circ$)')
ylabel('Lateral (mm) +ve')

% Anterior
nexttile(4); hold on; grid on;
plot(data.flexion, data.anterior, 'LineWidth', line_width)

title("Anterior translation")
xlabel('Flexion ($\circ$)')
ylabel('Anterior (mm) +ve')

% Superior
nexttile(5); hold on; grid on;
plot(data.flexion, data.superior, 'LineWidth', line_width)

title("Superior translation")
xlabel('Flexion ($\circ$)')
ylabel('Superior (mm) +ve')
end


function config = merge_config(config, new_config)
    fields = fieldnames(new_config);
    for i = 1:numel(fields)
        field = fields{i};
        if ~isfield(config, field)
            config.(field) = new_config.(field);
        end
    end
end
function root_ls = get_root_files(root, exclude_folders)
% `exclude_folders` is a cell with parts of names of folders that should be
% ignored. Typically "digit" (to exclude digitisation, digitise, digitize,
% etc) and "calibr" to exclude any variation of "calibration".

root_ls = dir(root);
root_ls = root_ls(~ismember({root_ls.name}, {'.', '..'}));
root_ls = root_ls(~contains({root_ls.name}, exclude_folders, 'IgnoreCase', true));
end

function specimen_name = get_specimen_name(root)
    parent_folder_full_fp = split(root, filesep);
    test_name = parent_folder_full_fp{end};
    test_name_split= split(test_name, '_');
    specimen_name = test_name_split{1};
end
function right = get_knee_side(root, is_right_knee, right_text, left_text)
right = [];
    parent_folder_full_fp = split(root, filesep);
    test_name = parent_folder_full_fp{end};
    test_name_split= split(test_name, '_');
    if any(strcmpi(test_name_split{end}, right_text))
        right = true;
    elseif any(strcmpi(test_name_split{end}, left_text))
        right = false;
    end
    if isempty(right)
        right = is_right_knee;
    end
end