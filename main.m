%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             READ ME
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This program runs every single specimen found in the root folder.
% File structure expected is SpecimenName/State/Loading condition:
% Experiment_3             <====== This is the folder you pick on the popup!
% ├───SN06_XXXX_right
% │   ├───Intact
% │   |    ├───Anterior.csv
% │   |    ├───Neutral.cs
% │   |    └───Sps.csv                   
% │   └───Digitisation                   
% │        ├───tibia_medial.csv          
% |        ...                           
% │        ├───pat med.csv             Notice SN08 appears twice. That is OK
% │        └───FL.csv                They are matched based on the first word (SN08)
% ├───SN08_XXXX_RK            <============╣  
% │   ├───ACL_cut                          ║  
% │   ├───digitise                         ║  
% ├───SN08_yyyy_2_RK          <============╝
% │   ├───ACL_recon
% │   └───Digitise_ACL_recon
% ...

% Make sure each folder is called SpecimenName_whatever_(side)_whatever
% e.g. SN06_right_122024, JJ01 left, XE0_2_left, MA03_333_lk, etc.
% right, left, lk, rk are the acceptable words.
% These can be changed in /lib/configure/defaults`
% 
% lib/configure/clean_specimen_condition.m is a list of regex to help
% clean up inconsistency in your folders. e.g., between cases (ACL vs acl),
% in naming (Reconstruction vs repair vs recon), or mistakes (esp instead of Sps)


% For plotting, you want to use `specimen`, but if you need to match
% `transforms` to their specific runs, use `specimen_with_duplicates`
clc; clear; close all;
%% Load default configuration. Check ./lib/configure/defaults.m if you want to modify them.
defaults
if config.digitisation_correction
    warning("Rotation of landmarks based on digitisation angle is enabled")
end

disp("Choose the root folder where all the specimens are")
root = uigetdir(".", "Choose the root folder");

%%
specimen_with_duplicates = [];
specimen_list = get_root_files(root, {'result'}); % Get all files in root and exclude any folders that include `result`
specimen_folders = fullfile({specimen_list.folder}, {specimen_list.name});
tic
for i = 1:numel(specimen_folders)
    specimen_name = get_specimen_name(specimen_list(i).name);
    config.specimen_name = specimen_name;
    fprintf("%d. Specimen: %s\n", i, specimen_name);
    fp_conditions = get_root_files(specimen_folders{i}, {});
    if isempty(fp_conditions)
        continue
    end

    fp_digitisation = get_digitisation(fp_conditions, config);
    if isempty(fp_digitisation)
        warning("No digitisation files found. Skipping specimen")
        continue
    end

    if isempty(get_root_files(fp_digitisation, {'result'}))
        continue
    end
    %% Load digitisation
    [root, ~, ~] = fileparts(fp_digitisation);
    config.is_right_knee = get_knee_side(root, config.right, config.left);
    [digitisation, config, ~] = load_data(fp_digitisation, label, config);
    if config.is_polaris
        config.label = label.polaris;
    else
        config.label = label.certus;
    end
    [trackers, landmarks] = create_trackers(digitisation, config);
    if config.debug, visualise_landmarks(landmarks, config), keyboard, end
    %% Load experiment data
    knee_states = get_root_files(root, config.digitisation);
    try
        for k = 1:numel(knee_states)
            state = knee_states(k);
            
            fp_data = fullfile(state.folder, state.name);
            try
                [data_raw, ~, idx_interpolation] = load_data(fp_data, config.label);
            catch ME
                if any(contains({ME.stack.name}, "label", "IgnoreCase",true))
                    warning("Some data may be valid, but entire state will be skipped.");
                    continue;
                end
            end
        
            %% Run
            state_clean = clean_specimen_condition(state.name);
            config.state = state_clean;
            [datum, transforms.(state_clean)] = get_jcs(data_raw, trackers, config);

            if config.enable_raw_plot
                plot_raw(datum, config)
            end
    
            if config.print_single_runs, print_to_file(datum, fp_data), end
        
            data.(state_clean) = datum;
        end
    catch ME
        if config.debug
            rethrow(ME)
        else
            warning(ME.message);
            continue;
        end
    end
    states = string(fieldnames(data));
    for k = 1:numel(states)
        if config.debug
            fprintf("%s:\n", clean_specimen_condition(states(k)))
        end
        try
        data_post_processed = intraspecimen_postprocess(data.(states(k)), config);
        catch ME
            warning("x")
            continue
        end

        % Unique runs are kept separate because the transforms in global are
        % unique. Not useful for data. Useful for drawing if not using tibia/patella on femur
        specimen_with_duplicates(i).name = specimen_name;
        specimen_with_duplicates(i).(states(k)) = data_post_processed;
    end

end
disp("Done loading data")
toc
if isempty(specimen_with_duplicates)
    error("No specimens were run. To see all errors, go to lib/configure/defaults.m, and set config.debug = true.")
end
%% Post process
% Condense data
specimens = remove_duplicate_specimens(specimen_with_duplicates);

%% Offset specimen specific
specimens_offset = specimen_specific_offset(specimens, config);
%%
states = setdiff(fieldnames(specimens), "name");

for s = 1:numel(states)
    state = states{s};
    stats_offset.(state) = interspecimen_stats([specimens_offset.(state)], config);
end

%% Do the stats
for s = 1:numel(states)
    state = states{s};
    stats.(state) = interspecimen_stats([specimens.(state)], config);
end

%% print to file
print_mean_std_to_file(stats, states, root);
%% Plot
truncate_min = -5;
truncate_max = 90;

% plot_interspecimen(config, stats, states, truncate_min, truncate_max)
plot_interspecimen(config, stats, stats_offset, states, truncate_min, truncate_max)

diary off;
