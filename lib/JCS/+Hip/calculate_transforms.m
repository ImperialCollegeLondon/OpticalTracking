function [transforms, bones] = calculate_transforms(trackers, loading_condition, digitisation_transforms, config)
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

    ttTtc = digitisation_transforms.tibia.transform;
    ttrtc = digitisation_transforms.tibia.origin;
    ftTfc = digitisation_transforms.femur.transform;
    ftrfc = digitisation_transforms.femur.origin;
    htThc = digitisation_transforms.hip.transform;
    htrhc = digitisation_transforms.hip.origin;

    %% Load how tracker moves with time
    gTtti = findTrackerFixedFrames(data.tibia);
    gTfti = findTrackerFixedFrames(data.femur);
    gThti = findTrackerFixedFrames(data.hip);
    % Create matrices of tracker marker position and rotations in time


    %% Calculate transformation matricies from body fixed to global fixed frames and motion relative to initial position

    gTfi = pagemtimes(gTfti, ftTfc);%multiply here instead of multiply by inverse as detailed in Pam's method
    gTti = pagemtimes(gTtti, ttTtc);%multiply here instead of divide in Pam's method
    fTt = pagemldivide(gTfi, gTti); % Transformation of Tibia relative to the femur

    %calculate the position vectors of the origin in the global frame of
    %reference
    grfi = squeeze(pagemtimes(gTfti, ftrfc)); %femur origin in global reference frame
    femur.origin=grfi;
    grti = squeeze(pagemtimes(gTtti, ttrtc)); %tibia origin in global reference frame
    tibia.origin=grti;

    % Creates the structures the code expects, but all with empty data. Necessary to handle a missing hip without crashing.
    if isempty(gThti) || isempty(htThc)
        gThi = [];
        hTf = [];
        grhi = [];
        hip.i = [];
        hip.j = [];
        hip.k = [];
    else
        gThi = pagemtimes(gThti, htThc);%multiply here instead of divide in Pam's method
        hTf = pagemldivide(gThi, gTfi); % Femur in hip frame of reference
        grhi = pagemtimes(gThti, htrhc); % hip origin in the global frame of reference
        hip.i  = squeeze(gThi(1:3, 1, :));
        hip.j  = squeeze(gThi(1:3, 2, :));
        hip.k  = squeeze(gThi(1:3, 3, :));
    end
    hip.origin = grhi;

    % Femoral x, y, z unit vector, Grood and Suntay definition
    femur.i = squeeze(gTfi(1:3, 1, :));
    femur.j = squeeze(gTfi(1:3, 2, :));
    femur.k = squeeze(gTfi(1:3, 3, :));

    %Tibial x, y, z axis unit vector, Grood and Suntay definition
    tibia.i = squeeze(gTti(1:3, 1, :));
    tibia.j = squeeze(gTti(1:3, 2, :));
    tibia.k = squeeze(gTti(1:3, 3, :));

    transforms.fTt = fTt;
    transforms.hTf = hTf;
    bones.femur = femur;
    bones.tibia = tibia;
    bones.hip = hip;
    transforms.gTfi = gTfi;
    transforms.gTti = gTti;
    transforms.gThi = gThi;
end
