function transforms = bone_to_tracker_transform(digitisation, config)
    % Create the transforms that describe the relationship between rigid bodies and their respective trackers
    trackers = digitisation.bone;

    tibia = trackers.tibia;
    femur = trackers.femur;
    hip = trackers.hip;
    right = config.is_right_knee;

    %% Define coordinate systems for each bone using digitised points
    % For tibia
    gTt0 = defineBodyFixedFrameTibia(tibia, right);
    grt0 = gTt0.map(@(x) origins(x)).unwrap_or([]);
    gTf0 = defineBodyFixedFrameFemur(femur, right).map(@(x) x * digitisation.optimisation);
    grf0 = gTf0.map(@(x) origins(x)).unwrap_or([]);
    gTh0 = defineBodyFixedFrameHip(hip, right);
    grh0 = gTh0.map(@(x) origins(x)).unwrap_or([]);



    %% Define frame of reference for each of the trackers in global coordinates
    gTft0 = femur.tracker.map(@(x) defineTrackerFixedFrame(x.rotations_mean, x.translations_mean));
    gTtt0 = tibia.tracker.map(@(x) defineTrackerFixedFrame(x.rotations_mean, x.translations_mean));
    gTht0 = hip.tracker.map(@(x) defineTrackerFixedFrame(x.rotations_mean, x.translations_mean));

    gTft0 = unwrap_tracker(gTf0, gTft0);
    gTtt0 = unwrap_tracker(gTt0, gTtt0);
    gTht0 = unwrap_tracker(gTh0, gTht0);

    %% Relate body fixed frames and origin to the tracker rigid body
    % A constant transform of the body fixed frame in the tracker frame of reference (assumes rigid body)
    % As in, tibia in the tibial tracker's frame of reference.
    transforms.tibia.transform = gTt0.map(@(gTt0) gTtt0\gTt0).unwrap_or([]); %ttTtc
    transforms.tibia.origin = gTtt0\grt0; %ttrtc

    transforms.femur.transform = gTf0.map(@(gTf0) gTft0\gTf0).unwrap_or([]); %ftTfc
    transforms.femur.origin = gTft0\grf0; %ftrfc

    transforms.hip.transform = gTh0.map(@(gTh0) gTht0\gTh0).unwrap_or([]); %ttTpc
    transforms.hip.origin = gTht0\grh0; %htrpc


    transforms.femur.gTft0 = gTft0;

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
