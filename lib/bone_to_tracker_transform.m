function [T, F] = bone_to_tracker_transform(tibia, femur, Right)
%% Define coordinate systems for each bone using digitised points
% For tibia
[gTt0, originT] = defineBodyFixedFrameTibia(tibia.medial.translations_mean, tibia.lateral.translations_mean, tibia.distal.translations_mean, Right);
grt0 = [originT, 1]';

% For femur
[gTf0, originF] = defineBodyFixedFrameFemur(femur.medial.translations_mean, femur.lateral.translations_mean, femur.proximal.translations_mean, Right);
grf0 = [originF, 1]';

%% Define fixed frame for each of the trackers in global coordinates

% Tibia: transforms between the bony and tracker fixed coordinate systems
[gT_Pin1_t0] = defineTrackerFixedFrame(tibia.tracker.rotations_mean, tibia.tracker.translations_mean);
T.Pin1_T_tc = gT_Pin1_t0\gTt0;
T.Pin1_r_tc = gT_Pin1_t0\grt0;

% Femur: transforms between the bony and tracker fixed coordinate systems
[gT_Pin6_t0] = defineTrackerFixedFrame(femur.tracker.rotations_mean, femur.tracker.translations_mean);
F.Pin6_T_tc = gT_Pin6_t0\gTf0;
F.Pin6_r_tc = gT_Pin6_t0\grf0;
end