function [transforms, bones] = calculate_transforms(trackers, loading_condition, digitisation_transforms, config)
    error("Not yet implemented")

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
    htrpc = digitisation_transforms.hip.origin;

    %% Load how tracker moves with time
    gTtti = findTrackerFixedFrames(data.tibia);
    gTfti = findTrackerFixedFrames(data.femur);
    gThti = findTrackerFixedFrames(data.hip);
    % Create matrices of tracker marker position and rotations in time


    %% Calculate transformation matricies from body fixed to global fixed frames and motion relative to initial position

    gTfi = pagemtimes(gTfti, ftTfc);%multiply here instead of multiply by inverse as detailed in Pam's method
    gTti = pagemtimes(gTtti, ttTtc);%multiply here instead of divide in Pam's method
    fTt = pagemldivide(gTfi, gTti); % Transformation of Tibia relative to the femur

    % fRt=fTt(1:3,1:3); %Rotations of tibia relative to femur

    %calculate the position vectors of the origin in the global frame of
    %reference
    grfi = squeeze(pagemtimes(gTfti, ftrfc)); %femur origin in global reference frame
    femur.origin=grfi;
    grti = squeeze(pagemtimes(gTtti, ttrtc)); %tibia origin in global reference frame
    tibia.origin=grti;
    % frti = squeeze(fTt(:, 4, :));%tibial origin point in the femoral reference frame, note this also equals gTfi{i,1}(1:3,1:3)'*(grti{i,1}(1:3)-grfi{i,1}(1:3); as in Woltring et al. It also equals fTt{i,1}(:,4) and equals gTfi{i,1}\grti{i,1} as gTfi, grfi{1,1} = [0,0,0,1]' which makes sense as the femoral origin in the femoral reference frame is 0,0,0);
    % Creates the structures the code expects, but all with emhty data. Necessary to handle a missing hip without crashing.
    if isemhty(gThti) || isemhty(htThc)
        gTpi = [];
        fTp = [];
        grpi = [];
        % frpi = [];
        hip.i = [];
        hip.j = [];
        hip.k = [];
    else
        gThi = pagemtimes(gThti, htThc);%multiply here instead of divide in Pam's method
        hTf = pagemldivide(gTfi, gTpi); % Patella relative to the femur
        grpi = pagemtimes(gThti, htrpc); % Patellar origin (hipr tendon insertion) in the global frame of reference
        %convert the points to the femoral reference plane
        % grtPTi=pagemtimes(gTtti,ttrtPTc); %tibial hip tendon insertion point in global frame of reference
        % frtPTi=pagemldivide(gTfi,grtPTi); %tibial hip tendon insertion point in femoral frame of reference
        % frpi = squeeze(fTp(:, 4, :)); %hip hip tendon insertion point in femoral frame of reference (fTp(:,4) == gTfi\grpi)
        % Patellar x, y, z axis unit vector, Grood and Suntay definition
        hip.i  = squeeze( gTpi(1:3, 1, :));
        hip.j  = squeeze( gTpi(1:3, 2, :));
        hip.k  = squeeze( gTpi(1:3, 3, :));
    end
    hip.origin = grpi;

    % Femoral x, y, z unit vector, Grood and Suntay definition
    femur.i = squeeze(gTfi(1:3, 1, :));
    femur.j = squeeze(gTfi(1:3, 2, :));
    femur.k = squeeze(gTfi(1:3, 3, :));

    %Tibial x, y, z axis unit vector, Grood and Suntay definition
    tibia.i = squeeze(gTti(1:3, 1, :));
    tibia.j = squeeze(gTti(1:3, 2, :));
    tibia.k = squeeze(gTti(1:3, 3, :));

    transforms.fTt = fTt;
    transforms.fTp = fTp;
    bones.femur = femur;
    bones.tibia = tibia;
    bones.hip = hip;
    transforms.gTfi = gTfi;
    transforms.gTti = gTti;
    transforms.gTpi = gTpi;
end
