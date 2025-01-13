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
run(fullfile("lib", "configure", "defaults.m"));

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

    digitisation_file_mask = contains({fp_conditions.name}, config.digitisation , "IgnoreCase",true);
    if sum(digitisation_file_mask) > 1 % There's more than 1 digitisation file
        digitisation_file_mask(1:find(digitisation_file_mask, 1, "last")-1) = false; % Pick the last one
        warning("Found more than one digitisation folder. Using '%s'", fp_conditions(digitisation_file_mask).name);
    elseif ~any(digitisation_file_mask)
        warning("No digitisation files found. Skipping specimen")
        continue
    end
    fp_digitisation = fullfile(fp_conditions(digitisation_file_mask).folder, fp_conditions(digitisation_file_mask).name);

    try
    [trackers, landmarks, config] = create_trackers(fp_digitisation, config, label); % This mutates config. terrible idea, but fine for now.
    [data, transforms, ~] = read_run_print_to_file(fp_digitisation, trackers, config);
    catch ME
        if config.debug
            rethrow(ME)
        else
            warning(ME.message);
            continue;
        end
    end

    states = fieldnames(data);
    state_data = struct2cell(data);

    % Unique runs are kept separate because the transforms in global are
    % unique. Not useful for data. Useful for drawing if not using tibia/patella on femur
    specimen_with_duplicates(i).name = specimen_name;
    for f = 1:numel(states)
        specimen_with_duplicates(i).(states{f}) = state_data{f};
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
