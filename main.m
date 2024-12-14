clc;clear; close all;
right = false; % true if right knee; false if left knee.
label.probe = 'Probe';
label.tibia = 'T';
label.femur = 'Y';

%% Create calibration files
disp("Choose the calibration folder");
fp_calibration = uigetdir(".", "Choose the calibration folder");
%%
[calibration, use_quaternion] = load_data(fp_calibration);
% Find the user-given labels to each tracker/probe.
% if label_probe_landmarks and label_tracker_... don't match them, the code will not run.
probe_labels = get_probe_labels(label, calibration, fp_calibration);
%%
landmark_raw_data = organise_data(calibration, probe_labels, use_quaternion);
%%
% Assign the rigid body landmarks using the probe, and create their respective trackers
landmarks = create_landmarks(landmark_raw_data, label);
%%
trackers = bone_to_tracker_transform(landmarks.tibia, landmarks.femur, right);

%% Load experiment data
disp("Choose the data folder");
fp_data = uigetdir(".", "Choose the data folder");
disp("Done");
data_raw = load_data(fp_data);
%% Extract data only for the relevant tracker
clear g_transforms
data_all_probes = organise_data(data_raw, probe_labels, use_quaternion);
for i = 1:numel(data_raw)
    data(i).name = data_all_probes(i).name;
    % Assign the tracker to the right bone.
    data(i).tibia = extract_from_label(data_all_probes(i).probes, label.tibia);
    data(i).femur = extract_from_label(data_all_probes(i).probes, label.femur);

    [output(i), difference(i), g_transforms(i)]= run_data(data(i), trackers, right);


    % Shift flexion so min flexion (= extension) is 0. If using a different method,
    % e.g., known maximum flexion, just modify the following line.
    output(i).data.flexion = [output(i).data.flexion] - min([output(i).data.flexion]);
end
[g_transforms.name] = deal(output.name);

%% Plot 
for i = 1:numel(output)
    plot_all(output(i))
end
