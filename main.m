clc;clear;
%%
right = false; % true if right knee; false if left knee.

%% Tracker labels
% These should be change if the labels used for the trackers change.

% Polaris labels: determined by either looking at its name
% (e.g., Brainlab Y Junction) or the label defined in the .tbr file.
label.polaris.tibia = "T";
label.polaris.femur = "Y";
label.polaris.patella = '';
label.polaris.probe = "Probe";
% Certus labels:
label.certus.tibia = "tibia";
label.certus.femur = "femur";
label.certus.patella = "patella";
label.certus.probe = "Probe";


%% Create calibration files
disp("Choose the calibration folder");
fp_calibration = uigetdir(".", "Choose the calibration folder");
%% Load digitisation
[calibration, use_quaternion, probe_labels, is_polaris] = load_data(fp_calibration, label);
%% Load experiment data
disp("Choose the data folder");
fp_data = uigetdir(".", "Choose the data folder");
data_raw = load_data(fp_data, label);

if is_polaris
    disp("Detected Polaris data.");
    label_f = label.polaris;
else
    disp("Detected Certus data.")
    label_f = label.certus;
end
%% Create trackers
% Clean up headers and create a nicer structure
landmark_raw_data = sanitise_data(calibration, probe_labels, use_quaternion);
% Assign the rigid body landmarks using the probe, and create their respective trackers
landmarks = create_landmarks(landmark_raw_data, label_f);
% Calculate bone to tracker transforms
trackers = bone_to_tracker_transform(landmarks.tibia, landmarks.femur, landmarks.patella, right);


%% Sanitise data
data_sanitised = sanitise_data(data_raw, probe_labels, use_quaternion);
for i = 1:numel(data_raw)
    data(i).name = data_sanitised(i).name;
    data(i).tibia = extract_from_label(data_sanitised(i).probes, label_f.tibia);
    data(i).femur = extract_from_label(data_sanitised(i).probes, label_f.femur);
    data(i).patella = extract_from_label(data_sanitised(i).probes, label_f.patella);

    [output(i), difference(i), g_transforms(i)]= run_data(data(i), trackers, right);
    % Shift flexion so max extension is 0:
    % flex = num2cell([output(i).data.flexion] - min([output(i).data.flexion]));
    % Shift max flexion to be 120 deg
    [output(i).data.flexion] = output(i).data.flexion + 120 - max(output(i).data.flexion);
end
[g_transforms.name] = deal(output.name);

%% Plot
for i = 1:numel(data_sanitised)
plot_all(output(i))
end
