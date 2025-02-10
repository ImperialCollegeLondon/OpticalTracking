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
specimen_list = get_root_files(root, {'result', 'problem'}).unwrap(); % Get all files in root and exclude any folders that include `result`
specimen_folders = fullfile({specimen_list.folder}, {specimen_list.name});
tic

if config.plot_missing_data
    config.path_missing_data = fullfile(root, "problematic_data");
    mkdir(config.path_missing_data);
end
for i = 1:numel(specimen_folders)
    specimen_name = get_specimen_name(specimen_list(i).name);
    config.specimen.name = specimen_name;
    fprintf("%d. Specimen: %s\n", i, specimen_name);
    fp_conditions = get_root_files(specimen_folders{i}, {});
    if fp_conditions.is_none
        continue
    end
    fp_conditions = fp_conditions.unwrap();

    fp_digitisation = get_digitisation(fp_conditions, config.digitisation);
    if fp_digitisation.is_none()
        warning("No digitisation files found. Skipping specimen")
        continue
    end
    fp_digitisation = fp_digitisation.unwrap();

    if get_root_files(fp_digitisation, {'result'}).is_none()
        continue
    end
    %% Load digitisation
    [root, ~, ~] = fileparts(fp_digitisation);
    config.is_right_knee = get_knee_side(root, config.right, config.left) ...
        .expect("Could not determine knee side. Folder name should indicate the side.");

    [digitisation, config] = load_data(fp_digitisation, config);
    if digitisation.is_none()
        continue
    end
    digitisation = digitisation.unwrap();

    [trackers, landmarks] = create_trackers(digitisation, config);
    if config.enable_raw_plot, clf; visualise_landmarks(landmarks, config), keyboard, end
    %% Load experiment data
    knee_states = get_root_files(root, config.digitisation).unwrap();
    % try
        for k = 1:numel(knee_states)
            state = knee_states(k);
            
            fp_data = fullfile(state.folder, state.name);
            
            [data_raw, ~] = load_data(fp_data, config);
            
            if data_raw.is_none()
                warning('No csv files in %s', fp_data)
                continue;
            end
            data_raw = data_raw.unwrap();
            %% Run
            state_clean = clean_specimen_condition(state.name);
            config.specimen.state = state_clean;
            [datum, transforms.(state_clean)] = get_jcs(data_raw, trackers, config);

            tibiofemoral = setdiff(fieldnames(datum), "name");
            idx_interpol = cell(numel(datum), numel(tibiofemoral));
            for lc = 1:numel(datum)
                for tf = 1:numel(tibiofemoral)
                    [datum(lc).(tibiofemoral(tf)), idx_interpol{lc, tf}] = config.fill_missing_raw_data(datum(lc).(tibiofemoral(tf)));
                end
            end
            if config.enable_raw_plot
                plot_raw(datum, config, idx_interpol);
            end
    
            if config.print_single_runs, print_to_file(datum, fp_data), end
        
            data.(state_clean) = datum;

            %% Tension data
            if config.tension    
                tension = load_tension(fp_data, config);
                if ~tension.is_none
                    tension_mean(i).name = specimen_name;
                    tension_mean(i).(state_clean) = tension.unwrap();
                end
            end
        end

    states = string(fieldnames(data));
    for k = 1:numel(states)
        if config.debug
            fprintf("%s:\n", clean_specimen_condition(states(k)))
        end
        data_post_processed = intraspecimen_postprocess(data.(states(k)), config);

        % Unique runs are kept separate because the transforms in global are
        % unique. Not useful for data. Useful for drawing if not using tibia/patella on femur
        specimen_with_duplicates(i).name = specimen_name;
        specimen_with_duplicates(i).(states(k)) = data_post_processed;
    end

end
disp("Done loading data")
toc
if isempty(specimen_with_duplicates)
    error("No specimens were run. go to lib/configure/defaults.m, and set config.debug = true.")
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

%% Visualise stl
neutral = strcmpi({transforms.Intact.name}, "neutral");
visualise_stl(config, transforms.Intact(neutral).in_femur.tibia, transforms.Intact(neutral).in_femur.femur);
%% print to file
print_mean_std_to_file(stats, states, root);
%% Plot
truncate_min = -5;
truncate_max = 90;

% plot_interspecimen(config, stats, states, truncate_min, truncate_max)
plot_interspecimen(config, stats, stats_offset, states, truncate_min, truncate_max)

diary off;
