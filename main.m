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
% These can be changed in ./defaults.m`
% 
% lib/configure/clean_specimen_condition.m is a list of regex to help
% clean up inconsistency in your folders. e.g., between cases (ACL vs acl),
% in naming (Reconstruction vs repair vs recon), or mistakes (esp instead of Sps)

% clc; clear; close all;
%% Load default configuration. Check ./lib/configure/defaults.m if you want to modify them.

config = defaults();

disp("Choose the root folder where all the specimens are")
root = uigetdir(".", "Choose the root folder");

%%
module = Module.Knee;

config = pick_labels(config, module);

digitisation = Digitisation.new(root, config, module);
% digitisation.visualise();

disp("Now loading trajectories");
jcs = JCS.new(digitisation);
trajectories = jcs.solve();

assignments(1) = Assignments("Anterior", "Neutral");
assignments(2) = Assignments("External", "Neutral");
assignments(3) = Assignments("Internal", "Neutral");
assignments(4) = Assignments("Anterior_External", "Anterior");
assignments(5) = Assignments("Anterior_Internal", "Anterior");
assignments(6) = Assignments("SPS", "Valgus");

% trajectories = [
%     trajectories.include_state("COR").split_piecewise(assignments),...
%     trajectories.exclude_state("COR")
% ];

[traj_cor, angles] = trajectories...
    .include_state("COR")...
    .exclude_state("ACLR")...
    .split_piecewise(assignments)...
    .split_states("_COR");
cor = traj_cor.centre_of_rotation(angles);
% cor.plot(digitisation);
cor_avg = cor.average();
model = stlread("models/tibia2.stl");

    pts = model.Points;
    z_max = max(pts(:, 3));
    pts(:, 3) = pts(:, 3) - (z_max + 1);
    pts = pts*1.80;
    model_shifted = triangulation(model.ConnectivityList, pts);
cor_avg.plot(model_shifted);

keyboard
% optimised = digitisation.optimise(trajectories.intact_neutral());
path = trajectories.path();
path_avg = path.average();
norm = path.normalise("Neutral", "Intact_50N");
ie = norm.exclude_state("COR").ie();
norm_avg = path.normalise("Neutral", "Intact_50N").average();
norm_avg.exclude_state("COR").plot

% digitisation.visualise_surfaces;
% hold on;
% kinematics.trajectories.plot_centre_of_rotation();

%%
disp("Loading tension")
kinematics.load_tension("**/*tension.csv");
disp("Done loading data");
%%
% jcs.print_to_file();
% jcs.plot()
trajectories = kinematics.trajectories;
path = trajectories.path;
path.plot();


kinematics.trajectories.intraspecimen_mean();
kinematics.trajectories.set_flexion_min(-3);
kinematics.trajectories.cp_sensor_to_kinematics();
[flex, ext] = kinematics.trajectories.path.split_flex_ext;

% flex.spm;

normalised = flex.normalise("Neutral", "Intact", "ACL_recon");
spm = normalised.spm();
dunnett = spm.inference(0.05).dunnett(normalised, "ACL_recon");
spm.between_subject.tibiofemoral.anterior.inference(0.05).plot('plot_threshold_label',true, 'plot_p_values',true, 'autoset_ylim',true);

norm_avg = normalised.average();
norm_avg.plot();


% toc


% %% Visualise stl
% neutral = strcmpi({transforms.Intact.name}, "neutral");
% visualise_stl(config, transforms.Intact(neutral).in_femur.tibia, transforms.Intact(neutral).in_femur.femur);
% %% print to file
% print_mean_std_to_file(stats, states, root);
% %% Plot
% truncate_min = -5;
% truncate_max = 90;
% 
% % plot_interspecimen(config, stats, states, truncate_min, truncate_max)
% plot_interspecimen(config, stats, stats_offset, states, truncate_min, truncate_max)
% 
% diary off;
function specimen = getSgtitleSpecimen(fig)
%GETSGTITLESPECIMEN Extract the first line of a figure's sgtitle.
%   SPECIMEN = GETSGTITLESPECIMEN(FIG) returns the first line of the
%   sgtitle text for figure handle FIG, trimmed of whitespace. Returns
%   an empty string if the figure has no sgtitle.

    sgt = findobj(fig, 'Type', 'subplottext');

    if isempty(sgt)
        specimen = '';
        return
    end

    titleStr = sgt(1).String;

    if iscell(titleStr)
        firstLine = titleStr{1};
    else
        lines = strsplit(titleStr, newline);
        firstLine = lines{1};
    end

    specimen = strtrim(firstLine);
end
