function trackers = bone_to_tracker_transform(tibia, femur, right)
%% Define coordinate systems for each bone using digitised points
% For tibia
[gTt0, originT] = defineBodyFixedFrameTibia(tibia.medial.translations_mean, tibia.lateral.translations_mean, tibia.distal.translations_mean, right);
grt0 = [originT, 1]';

% For femur
[gTf0, originF] = defineBodyFixedFrameFemur(femur.medial.translations_mean, femur.lateral.translations_mean, femur.proximal.translations_mean, right);
grf0 = [originF, 1]';

%% Define frame of reference for each of the trackers in global coordinates
[gTft0] = defineTrackerFixedFrame(femur.tracker.rotations_mean, femur.tracker.translations_mean);
[gTtt0] = defineTrackerFixedFrame(tibia.tracker.rotations_mean, tibia.tracker.translations_mean);

%% Relate body fixed frames and origin to the tracker rigid body
% A constant transform of the body fixed frame in the tracker frame of reference (assumes rigid body)
trackers.tibia = gTtt0\gTt0; %ttTtc
trackers.femur = gTft0\gTf0; %ftTfc
end
