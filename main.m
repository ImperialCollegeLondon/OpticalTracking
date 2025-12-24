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
addpath(genpath('lib'))
addpath(genpath('external'))
defaults

if exist('Trajectory', 'class') ~= 8
    error(['Could not detect Post-processing framework in %s', '%sexternal%s\nPlease download it from https://github.com/ImperialCollegeLondon/opticaltracking-postprocess'], pwd, filesep, filesep);
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

    module = Module.Knee;

    n_digitisation = Digitisation.new(fp_conditions, config, module);
    if n_digitisation.is_none()
        warning("Failed to complete digitisation");
        continue
    end
    digitisation(i) = n_digitisation.unwrap();

    if config.enable_raw_plot, clf; digitisation.visualise(), keyboard, end
end

    jcs = JCS.new(digitisation);
    jcs.trajectories.intraspecimen_mean();
    [trajectories, interp_idx] = jcs.trajectories.interpolate();
    % jcs.print_to_file();
    % jcs.plot()

    tension = load_tension(fp_data, config);
    if ~tension.is_none
        tension_mean(i).name = specimen_name;
        tension_mean(i).(state_clean) = tension.unwrap();
    end

disp("Done loading data")
toc


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
