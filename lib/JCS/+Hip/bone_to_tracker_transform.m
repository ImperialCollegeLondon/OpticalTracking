function transforms = bone_to_tracker_transform(digitisation, config)

trackers = digitisation.bone;

tibia = trackers.tibia;
femur = trackers.femur;
hip = trackers.hip;
right = config.is_right_knee;

%% Define coordinate systems for each bone using digitised points
% For tibia
gTt0 = defineBodyFixedFrameTibia(tibia, right);
grt0 = origins(gTt0);
gTf0 = defineBodyFixedFrameFemur(femur, right);
grf0 = origins(gTf0);
gTh0 = defineBodyFixedFrameHip(hip, right);
grh0 = origins(gTh0);


%% Define frame of reference for each of the trackers in global coordinates
gTft0 = femur.tracker.map(@(x) defineTrackerFixedFrame(x.rotations_mean, x.translations_mean));
gTtt0 = tibia.tracker.map(@(x) defineTrackerFixedFrame(x.rotations_mean, x.translations_mean));
gTht0 = hip.tracker.map(@(x) defineTrackerFixedFrame(x.rotations_mean, x.translations_mean));


gTft0 = gTft0.unwrap_or([]);
if isempty(gTft0)
    warning("If this warning is here, Lara has fucked up the code")
    gTft0 = eye(4);
end
gTtt0 = gTtt0.unwrap_or([]);
gTht0 = gTht0.unwrap_or([]);
%% Relate body fixed frames and origin to the tracker rigid body
% A constant transform of the body fixed frame in the tracker frame of reference (assumes rigid body)
% As in, tibia in the tibial tracker's frame of reference.
transforms.tibia.transform = gTtt0\gTt0; %ttTtc
transforms.tibia.origin = gTtt0\grt0; %ttrtc

transforms.femur.transform = gTft0\gTf0; %ftTfc
transforms.femur.origin = gTft0\grf0; %ftrfc

transforms.hip.transform = gTht0\gTh0; %ttTpc
transforms.hip.origin = gTht0\grh0; %ptrpc


% Surfaces

% [surfaces, outline] = digitisation.locate_centre();
% transforms.tibia.surface_transform = surfaces.tibia.map(@(gTts0) gTtt0 \ gTts0).unwrap_or([]); %ttTts. Tibial surface in tibial tracker

end

function o = origins(tracker)
    if isempty(tracker)
        o = [];
    else
        o = tracker(:,4);
    end
end
