function trackers = bone_to_tracker_transform(landmarks, config)

tibia = landmarks.tibia;
femur = landmarks.femur;
patella = landmarks.patella;
right = config.is_right_knee;

%% Define coordinate systems for each bone using digitised points
% For tibia
gTt0 = defineBodyFixedFrameTibia(tibia, right);
grt0 = origins(gTt0);
gTf0 = defineBodyFixedFrameFemur(femur, right);
grf0 = origins(gTf0);
gTp0 = defineBodyFixedFramePatella(patella, right);
grp0 = origins(gTp0);

%% Define frame of reference for each of the trackers in global coordinates
gTft0 = femur.tracker.map(@(x) defineTrackerFixedFrame(x.rotations_mean, x.translations_mean));
gTtt0 = tibia.tracker.map(@(x) defineTrackerFixedFrame(x.rotations_mean, x.translations_mean));
gTpt0 = patella.tracker.map(@(x) defineTrackerFixedFrame(x.rotations_mean, x.translations_mean));
% [gTft0] = defineTrackerFixedFrame(femur.tracker.map(@(x) x.rotations_mean), femur.tracker.map(@(x) x.translations_mean));
% [gTtt0] = defineTrackerFixedFrame(tibia.tracker.map(@(x) x.rotations_mean), tibia.tracker.map(@(x) x.translations_mean));
% [gTpt0] = defineTrackerFixedFrame(patella.tracker.map(@(x) x.rotations_mean), patella.tracker.map(@(x) x.translations_mean));

%% Relate body fixed frames and origin to the tracker rigid body
% A constant transform of the body fixed frame in the tracker frame of reference (assumes rigid body)
% As in, tibia in the tibial tracker's frame of reference.
trackers.tibia.transform = gTtt0\gTt0; %ttTtc
trackers.tibia.origin = gTtt0\grt0; %ttrtc

trackers.femur.transform = gTft0\gTf0; %ftTfc
trackers.femur.origin = gTft0\grf0; %ftrfc

trackers.patella.transform = gTpt0\gTp0; %ttTpc
trackers.patella.origin = gTpt0\grp0; %ptrpc
end

function o = origins(tracker)
if isempty(tracker)
    o = [];
else
    o = tracker(:,4);
end
end
