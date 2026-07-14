function transforms = bone_to_tracker_transform(digitisation)
    % Create the transforms that describe the relationship between rigid bodies and their respective trackers
    trackers = digitisation.bone;

    tibia = trackers.tibia;
    femur = trackers.femur;
    hip = trackers.hip;
    right = digitisation.is_right_knee;

    %% Define coordinate systems for each bone using digitised points
    % For tibia
    gTt0 = defineBodyFixedFrameTibia(tibia, right);
    grt0 = gTt0.map(@(x) origins(x)).unwrap_or([]);
    gTf0 = defineBodyFixedFrameFemur(femur, right).map(@(x) x * digitisation.optimisation);
    grf0 = gTf0.map(@(x) origins(x)).unwrap_or([]);
    gTh0 = defineBodyFixedFrameHip(hip, right);
    grh0 = gTh0.map(@(x) origins(x)).unwrap_or([]);

        % There was no pot. Do Lara bullshit
    if gTh0.is_none
        this_gTf0 = gTf0.unwrap();
        gTh0 = eye(4);
        % Z
        gTh0(1:3, 3) = this_gTf0(1:3, 3);

        % Y
        asis = hip.asis.map(@(x) x.translations_mean).unwrap();
        psis = hip.psis.map(@(x) x.translations_mean).unwrap();
        uvector=@(a,b) (b-a)/norm(b-a,2); %define a function to find a unit vector from a to b
        j = uvector(psis, asis);
        gTh0(1:3, 2) = j;

        % X
        gTh0(1:3, 1) = cross(gTh0(1:3, 2), gTh0(1:3, 3)); % Calculate X-axis using cross product
        gTh0(1:3, 1) = gTh0(1:3, 1) / norm(gTh0(1:3, 1), 2); % Normalize X-axis

        % Origin
        gTh0(1:3, 4) = this_gTf0(1:3, 4);
        grh0 = origins(gTh0);

        gTh0 = Option(gTh0);
    end

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
    transforms.tibia.transform = gTt0.map(@(gTt0) gTtt0\gTt0); %ttTtc
    transforms.tibia.origin = Option(gTtt0\grt0); %ttrtc

    transforms.femur.transform = gTf0.map(@(gTf0) gTft0\gTf0); %ftTfc
    transforms.femur.origin = Option(gTft0\grf0); %ftrfc

    transforms.hip.transform = gTh0.map(@(gTh0) gTht0\gTh0); %ttTpc
    transforms.hip.origin = Option(gTht0\grh0); %htrpc


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
