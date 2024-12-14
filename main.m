clc;clear;
%%
right = false; % true if right knee; false if left knee.

%% Tracker labels
% These should be change if the labels used for the trackers change.

% Polaris labels: determined by either looking at its name
% (e.g., Brainlab Y Junction) or the label defined in the .tbr file.
label.polaris.tibia = "T";
label.polaris.femur = "Y";
label.polaris.probe = "Probe";
% Certus labels:
label.certus.tibia = "tibia";
label.certus.femur = "femur";
label.certus.probe = "Probe";


%% Create calibration files
disp("Choose the calibration folder");
fp_calibration = uigetdir(".", "Choose the calibration folder");
%% Load digitisation
[calibration, use_quaternion, probe_labels, is_polaris] = load_data(fp_calibration, label);
%% Load experiment data
disp("Choose the data folder");
fp_data = uigetdir(".", "Choose the data folder");
disp("Done");
data_raw = load_data(fp_data, label);

%% Modify a global variable like an idiot
if is_polaris
    label = label.polaris;
else
    label = label.certus;
end
%% Create trackers
% Clean up headers and create a nicer structure
landmark_raw_data = sanitise_data(calibration, probe_labels, use_quaternion);
% Assign the rigid body landmarks using the probe, and create their respective trackers
landmarks = create_landmarks(landmark_raw_data, label);
% Calculate bone to tracker transforms
trackers = bone_to_tracker_transform(landmarks.tibia, landmarks.femur, right);


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
