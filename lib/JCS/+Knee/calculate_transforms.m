function [transforms, bones] = calculate_transforms(trackers, strays, digitisation_transforms, config)
    %% Apply the tracker transforms to the data
    label = trackers.camera().get_possible_labels(config.labels());

    tibia_tracker = trackers.with_label(label.tibia);
    femur_tracker = trackers.with_label(label.femur);
    patella_tracker = trackers.with_label(label.patella);
    if (femur_tracker.is_none() && tibia_tracker.is_none()) || (femur_tracker.is_none() && patella_tracker.is_none())
        return
    end

    %% Load digitisations and tracker for run

    % If these are Option.None, it means the body was not digitised
    % They should be unwrap_or([]). i.e., you have no idea what is
    % happening.
    ttTtc = digitisation_transforms.tibia.transform;
    ttrtc = digitisation_transforms.tibia.origin;
    ftTfc = digitisation_transforms.femur.transform;
    ftrfc = digitisation_transforms.femur.origin;
    ptThc = digitisation_transforms.patella.transform;
    ptrpc = digitisation_transforms.patella.origin;

    tTts = digitisation_transforms.tibia_tracker.surface_relative_to_bone;

    % If these are Option.None, it means that rigid body was not tracked.
    % They should be unwrap_or(eye(4)). i.e., if the body was not tracked,
    % assume it hasn't moved at all.
    gTtti = findTrackerFixedFrames(tibia_tracker);
    gTfti = findTrackerFixedFrames(femur_tracker);
    gTpti = findTrackerFixedFrames(patella_tracker);


    %% Calculate transformation matricies from body fixed to global fixed frames and motion relative to initial position

    gTfi = ftTfc.map(@(ftTfc) pagemtimes(gTfti.unwrap_or(eye(4)), ftTfc));
    gTti = ttTtc.map(@(ttTtc) pagemtimes(gTtti.unwrap_or(eye(4)), ttTtc));
    gTpi = ptThc.map(@(ptThc) pagemtimes(gTpti.unwrap_or(eye(4)), ptThc));


    fTt = gTfi.zip(gTti).map(@(c) pagemldivide(c{1}, c{2}));
    fTp = gTfi.zip(gTpi).map(@(c) pagemldivide(c{1}, c{2}));
    fTts = fTt.zip(tTts).map(@(c) pagemtimes(c{1}, c{2}));

    %calculate the position vectors of the origin in the global frame of
    %reference
    grfi = ftrfc.map(@(ftrfc) pagemtimes(gTfti.unwrap_or(eye(4)), ftrfc));
    femur.origin = squeeze(grfi.unwrap_or([]));
    grti = ttrtc.map(@(ttrtc) pagemtimes(gTtti.unwrap_or(eye(4)), ttrtc));
    tibia.origin = squeeze(grti.unwrap_or([]));
    grpi = ptrpc.map(@(ptrpc) pagemtimes(gTpti.unwrap_or(eye(4)), ptrpc));
    patella.origin = squeeze(grpi.unwrap_or([]));

    tibia.i = []; tibia.j = []; tibia.k = [];
    femur.i = []; femur.j = []; femur.k = [];
    patella.i = []; patella.j = []; patella.k = [];

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
    if gTpi.is_some()
        h = gTpi.unwrap();
        patella.i = squeeze(h(1:3, 1, :));
        patella.j = squeeze(h(1:3, 2, :));
        patella.k = squeeze(h(1:3, 3, :));
    end


    transforms.fTt = fTt.unwrap_or([]);
    transforms.fTp = fTp.unwrap_or([]);
    bones.femur = femur;
    bones.tibia = tibia;
    bones.patella = patella;
    transforms.gTfi = gTfi.unwrap_or([]);
    transforms.gTti = gTti.unwrap_or([]);
    transforms.gTpi = gTpi.unwrap_or([]);
    transforms.tTts = tTts.unwrap_or([]);
    transforms.fTts = fTts.unwrap_or([]);
    transforms.gTfti = gTfti.unwrap_or([]);
end
