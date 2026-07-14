function [transforms, bones] = calculate_transforms(trackers, strays, loading_condition, digitisation_transforms, config)
    arguments
        trackers Tracker
        strays Option
        loading_condition
        digitisation_transforms
        config
    end
    %% Apply the tracker transforms to the data
    data.name = loading_condition;
    config.specimen.loading_condition = loading_condition;

    label = trackers.camera().get_possible_labels(config.camera_labels);

    data.tibia = trackers.with_label(label.tibia);
    data.femur = trackers.with_label(label.femur);
    data.hip = trackers.with_label(label.hip);
    if (data.femur.is_none() && data.tibia.is_none()) || (data.femur.is_none() && data.hip.is_none())
        return
    end

    %% Load digitisations and tracker data for run

    % If these are Option.None, it means the body was not digitised
    % They should be unwrap_or([]). i.e., you have no idea what is
    % happening.
    ttTtc = digitisation_transforms.tibia.transform;
    ttrtc = digitisation_transforms.tibia.origin;
    ftTfc = digitisation_transforms.femur.transform;
    ftrfc = digitisation_transforms.femur.origin;
    htThc = digitisation_transforms.hip.transform;
    htrhc = digitisation_transforms.hip.origin;

    % If these are Option.None, it means that rigid body was not tracked.
    % They should be unwrap_or(eye(4)). i.e., if the body was not tracked,
    % assume it hasn't moved at all.
    gTtti = findTrackerFixedFrames(data.tibia);
    gTfti = findTrackerFixedFrames(data.femur);
    gThti = findTrackerFixedFrames(data.hip);


    %% Calculate transformation matricies from body fixed to global fixed frames and motion relative to initial position

    gTfi = ftTfc.map(@(ftTfc) pagemtimes(gTfti.unwrap_or(eye(4)), ftTfc));
    gTti = ttTtc.map(@(ttTtc) pagemtimes(gTtti.unwrap_or(eye(4)), ttTtc));
    gThi = htThc.map(@(htThc) pagemtimes(gThti.unwrap_or(eye(4)), htThc));


    fTt = gTfi.zip(gTti).map(@(c) pagemldivide(c{1}, c{2}));
    hTf = gThi.zip(gTfi).map(@(c) pagemldivide(c{1}, c{2}));

    %calculate the position vectors of the origin in the global frame of
    %reference
    grfi = ftrfc.map(@(ftrfc) pagemtimes(gTfti.unwrap_or(eye(4)), ftrfc));
    femur.origin = squeeze(grfi.unwrap_or([]));
    grti = ttrtc.map(@(ttrtc) pagemtimes(gTtti.unwrap_or(eye(4)), ttrtc));
    tibia.origin = squeeze(grti.unwrap_or([]));
    grhi = htrhc.map(@(htrhc) pagemtimes(gThti.unwrap_or(eye(4)), htrhc));
    hip.origin = squeeze(grhi.unwrap_or([]));

    tibia.i = []; tibia.j = []; tibia.k = [];
    femur.i = []; femur.j = []; femur.k = [];
    hip.i = []; hip.j = []; hip.k = [];

    if gTfi.is_some()
        f = gTfi.unwrap();
        femur.i = squeeze(f(1:3, 1, :));
        femur.j = squeeze(f(1:3, 2, :));
        femur.k = squeeze(f(1:3, 3, :));
    end

    if gTti.is_some()
        t = gTti.unwrap();
        tibia.i = squeeze(t(1:3, 1, :));
        tibia.j = squeeze(t(1:3, 2, :));
        tibia.k = squeeze(t(1:3, 3, :));
    end
    if gThi.is_some()
        h = gThi.unwrap();
        hip.i = squeeze(h(1:3, 1, :));
        hip.j = squeeze(h(1:3, 2, :));
        hip.k = squeeze(h(1:3, 3, :));
    end

    keyboard
    strays_homo = strays.map(@translations_homogeneous);

    transforms.fTt = fTt.unwrap_or([]);
    transforms.hTf = hTf.unwrap_or([]);
    bones.femur = femur;
    bones.tibia = tibia;
    bones.hip = hip;
    bones.strays = strays;
    transforms.gTfi = gTfi.unwrap_or([]);
    transforms.gTti = gTti.unwrap_or([]);
    transforms.gThi = gThi.unwrap_or([]);
end
