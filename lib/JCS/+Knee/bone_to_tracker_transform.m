function [transforms, outline]= bone_to_tracker_transform(digitisation, config, previous_digitisation)
arguments
    digitisation Digitisation
    config
    previous_digitisation = [];
end

trackers = digitisation.bone;

tibia = trackers.tibia;
femur = trackers.femur;
patella = trackers.patella;
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

gTft0 = gTft0.unwrap_or([]);
gTtt0 = gTtt0.unwrap_or([]);
gTpt0 = gTpt0.unwrap_or([]);
%% Relate body fixed frames and origin to the tracker rigid body
% A constant transform of the body fixed frame in the tracker frame of reference (assumes rigid body)
% As in, tibia in the tibial tracker's frame of reference.
transforms.tibia.transform = gTtt0\gTt0; %ttTtc
transforms.tibia.origin = gTtt0\grt0; %ttrtc

transforms.femur.transform = gTft0\gTf0; %ftTfc
transforms.femur.origin = gTft0\grf0; %ftrfc

transforms.patella.transform = gTpt0\gTp0; %ttTpc
transforms.patella.origin = gTpt0\grp0; %ptrpc


%% Surfaces

[surfaces, outline] = digitisation.locate_centre();
transforms.tibia.surface_transform = surfaces.tibia.map(@(gTts0) gTtt0 \ gTts0).unwrap_or([]); %ttTts. Tibial surface in tibial tracker
transforms.tibia.surface_relative_to_bone = surfaces.tibia.map(@(gTts0) gTt0 \ gTts0 ).unwrap_or([]);

if isempty(transforms.tibia.surface_relative_to_bone)
    transforms.tibia.surface_relative_to_bone = previous_digitisation.transforms.tibia.surface_relative_to_bone;
    outline = previous_digitisation.surface;
end
end

function o = origins(tracker)
    if isempty(tracker)
        o = [];
    else
        o = tracker(:,4);
    end
end
