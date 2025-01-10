clc;clear; close all;
run(fullfile("lib", "configure", "defaults.m"));
%%
defaults;
%% Create calibration files
disp("Choose the calibration folder");
fp_digitisation = uigetdir(".", "Choose the digitisation folder");

[root, ~, ~] = fileparts(fp_digitisation);
root_ls = get_root_files(root, {'digit', 'calibr'}); % Second argument is a list of folders to exclude.
% 'digit' covers variations of digitisation, digitize, digitise, etc.

specimen_name = get_specimen_name(root); % Assign specimen name based on folder name.

%% Create trackers
[trackers, landmarks, config] = create_trackers(fp_digitisation, config, label);

% %% Visualisation of Landmarks
% plot_landmarks(landmarks, config.is_right_knee);
%% Load experiment data
for k = 1:numel(root_ls)
    fp_data = fullfile(root_ls(k).folder, root_ls(k).name);
    try
    [data_raw, ~, idx_interpolation] = load_data(fp_data, config.label);
    catch ME
        if any(contains({ME.stack.name}, "label", "IgnoreCase",true))
            warning("Insufficient tracker data recorded. Check that you are recording all trackers.");
            continue;
        end
    end

    %% Run
    [datum, transforms] = generate_intraspecimen_jcs(data_raw, trackers, config);
    
    % all_data.(lower(root_ls(k).name)) = data;
    data.(root_ls(k).name) = datum;
end
%% Plot
plot_intraspecies(data, specimen_name);

%% STL
stl_plot(config, transforms(1).in_global.tibia, transforms(1).in_global.femur)

%%

function plot_intraspecies(data, specimen_name)
%% PLOT_INTRASPECIES    plots all states 
states = fieldnames(data);
test_run = {data.(states{1}).name};

for j = 1:numel(test_run)
    figure(j);
    tiledlayout(3,2);
    for i = 1:numel(states)
        state = states{i};
        datum = config.interspecimen_smoothing(data.(state)(j).tibiofemoral);
        % flex = data.(state)(j).tibiofemoral.flexion;
        % ext = data.(state)(j).tibiofemoral.extension;
        plotting(datum);
    end

    lg = legend(replace(states, '_', ' '), Interpreter="latex");
    lg.FontSize = 14;

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