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
% g_transforms = repmat(struct('tibia', [], 'femur', []), numel(data_sanitised), 1);
% difference = repmat(struct('name', '', 'data', []), numel(output), 1);
for i = 1:numel(data_raw)
    data(i).name = data_sanitised(i).name;
    data(i).tibia = extract_from_label(data_sanitised(i).probes, label.tibia);
    data(i).femur = extract_from_label(data_sanitised(i).probes, label.femur);

    [output(i), difference(i), g_transforms(i)]= run_data(data(i), trackers, right);


    % Shift flexion so max extension is 0:
    output(i).data.flexion = [output(i).data.flexion] - min([output(i).data.flexion]);
    plot_all(output(i))
end
[g_transforms.name] = deal(output.name);

%%
N = length(g_transforms.tibia);

figure;

filename = 'tibia_rotation.gif'; % Output GIF file
for i = 1:N
    [x_t, y_t, z_t, t_t] = unit_vectors(g_transforms.tibia(i));
    [x_f, y_f, z_f, t_f] = unit_vectors(g_transforms.femur(i));
    
    clf;
    grid on;
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
    axis equal;
    title("Bones");
    legend({'X-axis', 'Y-axis', 'Z-axis'});
    hold on;
    %% Plot
    t = plotter(x_t, y_t, z_t, t_t, 'r');
    f = plotter(-x_f, -y_f, z_f, t_f, 'b');
    legend([t f], {"Tibia", "Femur"})
    %%
    hold off
    % Capture the plot as a frame for the GIF
    frame = getframe(gcf);
    im = frame2im(frame);
    [imind, cm] = rgb2ind(im, 256);
    
    % Write to GIF file
    if i == 1
        imwrite(imind, cm, filename, 'gif', 'Loopcount', inf, 'DelayTime', 0.1);
    else
        imwrite(imind, cm, filename, 'gif', 'WriteMode', 'append', 'DelayTime', 0.1);
    end
end

function [x, y, z, t] = unit_vectors(transform)
T = transform{:};
x = T(1:3, 1);
y = T(1:3, 2);
z = T(1:3, 3);
t = T(1:3, 4);
end

function plot_x = plotter(x, y, z, t, colour)
origin = [0; 0; 0];
plot_x = quiver3(origin(1), origin(2), origin(3), x(1), x(2), x(3), colour);
quiver3(origin(1), origin(2), origin(3), y(1), y(2), y(3), 0.5, colour);
quiver3(origin(1), origin(2), origin(3), z(1), z(2), z(3), 0.3, colour);
end
