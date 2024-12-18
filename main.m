clc;clear; close all;
%%
is_right_knee = false; % true if right knee; false if left knee.

%% Tracker labels
% These should be change if the labels used for the trackers change.

% Polaris labels: determined by either looking at its name
% (e.g., Brainlab Y Junction) or the label defined in the .tbr file.
label.polaris.tibia = "T";
label.polaris.femur = "Y";
label.polaris.patella = '';
label.polaris.probe = "Probe";
% Certus labels: Names used for each tracker in the data files.
% Expects probe to have any name that contains a whitespace but include the word "Port", e.g. "a b".
% Whitespaces rule can be found in load_data_certus() and "Port" rule is in load_data().
label.certus.tibia = "tibia";
label.certus.femur = "femur";
label.certus.patella = "patella";
label.certus.probe = "Probe"; % Don't change this even if the probe is called something else. Certus probe just needs to have a space in the name and it'll be found.

%% Create calibration files
disp("Choose the calibration folder");
fp_digitisation = uigetdir(".", "Choose the digitisation folder");

%% Load digitisation
[digitisation, use_quaternion, probe_labels, is_polaris, ~] = load_data(fp_digitisation, label);

%% Load experiment data
disp("Choose the data folder");
fp_data = uigetdir(".", "Choose the data folder");
%%
[input_raw, ~, ~, ~, idx_interpolation] = load_data(fp_data, label);

if is_polaris
    disp("Detected Polaris data.");
    label_f = label.polaris;
else
    disp("Detected Certus data.")
    label_f = label.certus;
end

%% Create trackers
% Clean up headers and create a nicer structure
landmark_raw_data = organise_data(digitisation, probe_labels, use_quaternion);
% Assign the rigid body landmarks using the probe, and create their respective trackers
landmarks = create_landmarks(landmark_raw_data, label_f);
% Calculate bone to tracker transforms
trackers = bone_to_tracker_transform(landmarks.tibia, landmarks.femur, landmarks.patella, is_right_knee);


%% Organise the raw data into the expected struct. Probably should be implemented as a class instead.
data_all_probes = organise_data(input_raw, probe_labels, use_quaternion);
%% Apply the tracker transforms to the data
clear g_transforms
g_transforms = struct('tibia', [], 'femur', [], 'patella', []);
g_transforms = repmat(g_transforms, 1, length(data_all_probes));
for i = 1:numel(input_raw)
    input(i).name = data_all_probes(i).name;
    % Assign the tracker to the right bone.
    input(i).tibia = extract_from_label(data_all_probes(i).probes, label_f.tibia);
    input(i).femur = extract_from_label(data_all_probes(i).probes, label_f.femur);
    input(i).patella = extract_from_label(data_all_probes(i).probes, label_f.patella);

    [data(i), g_transforms(i)]= run_data(input(i), trackers, is_right_knee);
    % Shift flexion so max extension is 0:
    % flex = num2cell([output(i).tibiofemoral.flexion] - min([output(i).tibiofemoral.flexion]));
    
    data(i).tibiofemoral.flexion = [data(i).tibiofemoral.flexion] - min([data(i).tibiofemoral.flexion]);
    
    % Shift max flexion to be 120 deg
    % [data(i).tibiofemoral.flexion] = data(i).tibiofemoral.flexion + 120 - max(data(i).tibiofemoral.flexion);
end
[g_transforms.name] = deal(data.name);
%% Plot
for i = 1:numel(data)
raw_plot_tf(data(i).name, data(i).tibiofemoral, idx_interpolation{i})
% plot_tf(data(i).name, data(i).tibiofemoral, idx_interpolation{i})
end

%% Write to csv
fp_results = fullfile(fp_data, "Results");
mkdir(fp_results);
for i = 1:numel(data)
    writetable(data(i).tibiofemoral, fullfile(fp_results, data(i).name + ".csv"))
end
