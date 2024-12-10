clc;clear;
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
landmark_raw_data = sanitise_data(calibration, probe_labels, use_quaternion);
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
%% Sanitise data
data_sanitised = sanitise_data(data_raw, probe_labels, use_quaternion);
for i = 1:numel(data_raw)
    data(i).name = data_sanitised(i).name;
    data(i).tibia = extract_from_label(data_sanitised(i).probes, label.tibia);
    data(i).femur = extract_from_label(data_sanitised(i).probes, label.femur);
    output(i).name = data_sanitised(i).name;
    [output(i).data, difference, g_transforms]= run_data(data(i), trackers, right);

    % Shift flexion so max extension is 0:
    flex = num2cell([output(i).data.flexion] - min([output(i).data.flexion]));
    [output(i).data.flexion] = flex{:};
    plot_all(output(i))
end
