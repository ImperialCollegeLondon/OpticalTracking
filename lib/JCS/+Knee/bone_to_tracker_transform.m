function [transforms, outline]= bone_to_tracker_transform(digitisation, previous_digitisation)
arguments
    digitisation Digitisation
    previous_digitisation = [];
end

trackers = digitisation.bone;

tibia = trackers.tibia;
femur = trackers.femur;
patella = trackers.patella;
right = digitisation.is_right_knee;

%% Define coordinate systems for each bone using digitised points
% For tibia
gTt0 = defineBodyFixedFrameTibia(tibia, right);
grt0 = gTt0.map(@(x) origins(x)).unwrap_or([]);
gTf0 = defineBodyFixedFrameFemur(femur, right).map(@(x) x * digitisation.optimisation);
grf0 = gTf0.map(@(x) origins(x)).unwrap_or([]);
gTp0 = defineBodyFixedFramePatella(patella, right);
grp0 = gTp0.map(@(x) origins(x)).unwrap_or([]);

%% Define frame of reference for each of the trackers in global coordinates
gTft0 = femur.tracker.map(@(x) defineTrackerFixedFrame(x.rotations_mean, x.translations_mean));
gTtt0 = tibia.tracker.map(@(x) defineTrackerFixedFrame(x.rotations_mean, x.translations_mean));
gTpt0 = patella.tracker.map(@(x) defineTrackerFixedFrame(x.rotations_mean, x.translations_mean));

gTft0 = unwrap_tracker(gTf0, gTft0);
gTtt0 = unwrap_tracker(gTt0, gTtt0);
gTpt0 = unwrap_tracker(gTp0, gTpt0);

% gTft0 = gTft0.unwrap_or([]);
% gTtt0 = gTtt0.unwrap_or([]);
% gTpt0 = gTpt0.unwrap_or([]);
%% Relate body fixed frames and origin to the tracker rigid body
% A constant transform of the body fixed frame in the tracker frame of reference (assumes rigid body)
% As in, tibia in the tibial tracker's frame of reference.
transforms.tibia.transform = gTt0.map(@(gTt0) gTtt0\gTt0).unwrap_or([]); %ttTtc
transforms.tibia.origin = gTtt0\grt0; %ttrtc

transforms.femur.transform = gTf0.map(@(gTf0) gTft0\gTf0).unwrap_or([]); %ftTfc
transforms.femur.origin = gTft0\grf0; %ftrfc

transforms.patella.transform = gTp0.map(@(gTp0) gTpt0\gTp0).unwrap_or([]); %ttTpc
transforms.patella.origin = gTpt0\grp0; %ptrpc


%% For optimisation
transforms.femur.gTft0 = gTft0;

%% Surfaces

[surfaces, outline] = digitisation.locate_centre();
transforms.tibia.surface_transform = surfaces.tibia.map(@(gTts0) gTtt0 \ gTts0).unwrap_or([]); %ttTts. Tibial surface in tibial tracker
transforms.tibia.surface_relative_to_bone = surfaces.tibia.map(@(gTts0) gTt0.unwrap_or([]) \ gTts0 ).unwrap_or([]);

if isempty(transforms.tibia.surface_relative_to_bone) && ~isempty(previous_digitisation)
    transforms.tibia.surface_relative_to_bone = previous_digitisation.transforms.tibia.surface_relative_to_bone;
    outline = previous_digitisation.surface;
end
end

function o = origins(tracker)
    o = tracker(:,4);
end

function res = unwrap_tracker(body, tracker)
    if body.is_none()
        res = tracker.unwrap_or([]);
    else
        res = tracker.unwrap_or(eye(4));
    end
end
