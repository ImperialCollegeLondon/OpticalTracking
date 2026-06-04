function [transforms, bones] = calculate_transforms(trackers, loading_condition, digitisation_transforms, config)
    %% Apply the tracker transforms to the data
    data.name = loading_condition;
    config.specimen.loading_condition = loading_condition;

    label = trackers.camera().get_possible_labels(config.camera_labels);

    data.tibia = trackers.with_label(label.tibia);
    data.femur = trackers.with_label(label.femur);
    data.patella = trackers.with_label(label.patella);
    if (data.femur.is_none() && data.tibia.is_none()) || (data.femur.is_none() && data.patella.is_none())
        return
    end

    ttTtc = digitisation_transforms.tibia.transform;
    ttrtc = digitisation_transforms.tibia.origin;
    ftTfc = digitisation_transforms.femur.transform;
    ftrfc = digitisation_transforms.femur.origin;
    ptTtc = digitisation_transforms.patella.transform;
    ptrpc = digitisation_transforms.patella.origin;
    tTts = digitisation_transforms.tibia.surface_relative_to_bone;
    % ttTtscc = digitisation_transforms.tibia.surface_transform;

    %% Load how tracker moves with time
    gTtti = findTrackerFixedFrames(data.tibia);
    gTfti = findTrackerFixedFrames(data.femur);
    gTpti = findTrackerFixedFrames(data.patella);
    % Create matrices of tracker marker position and rotations in time




    %% Calculate transformation matrices from body fixed to global fixed frames and motion relative to initial position

    gTfi = pagemtimes(gTfti, ftTfc);%multiply here instead of multiply by inverse as detailed in Pam's method
    gTti = pagemtimes(gTtti, ttTtc);%multiply here instead of divide in Pam's method
    fTt = pagemldivide(gTfi, gTti); % Transformation of Tibia relative to the femur


    if isempty(tTts)
        fTts = [];
    else
        fTts = pagemtimes(fTt , tTts);
    end
    % We want it relative to the initial position, not relative to the new position of the tibia.

    % fRt=fTt(1:3,1:3); %Rotations of tibia relative to femur

    %calculate the position vectors of the origin in the global frame of
    %reference
    grfi = squeeze(pagemtimes(gTfti, ftrfc)); %femur origin in global reference frame
    femur.origin=grfi;
    grti = squeeze(pagemtimes(gTtti, ttrtc)); %tibia origin in global reference frame
    tibia.origin=grti;
    % frti = squeeze(fTt(:, 4, :));%tibial origin point in the femoral reference frame, note this also equals gTfi{i,1}(1:3,1:3)'*(grti{i,1}(1:3)-grfi{i,1}(1:3); as in Woltring et al. It also equals fTt{i,1}(:,4) and equals gTfi{i,1}\grti{i,1} as gTfi, grfi{1,1} = [0,0,0,1]' which makes sense as the femoral origin in the femoral reference frame is 0,0,0);
    % Creates the structures the code expects, but all with empty data. Necessary to handle a missing patella without crashing.
    if isempty(gTpti) || isempty(ptTtc)
        gTpi = [];
        fTp = [];
        grpi = [];
        % frpi = [];
        patella.i = [];
        patella.j = [];
        patella.k = [];
    else
        gTpi = pagemtimes(gTpti, ptTtc);%multiply here instead of divide in Pam's method
        fTp = pagemldivide(gTfi, gTpi); % Patella relative to the femur
        grpi = pagemtimes(gTpti, ptrpc); % Patellar origin (patellar tendon insertion) in the global frame of reference
        %convert the points to the femoral reference plane
        % grtPTi=pagemtimes(gTtti,ttrtPTc); %tibial patella tendon insertion point in global frame of reference
        % frtPTi=pagemldivide(gTfi,grtPTi); %tibial patella tendon insertion point in femoral frame of reference
        % frpi = squeeze(fTp(:, 4, :)); %patella patella tendon insertion point in femoral frame of reference (fTp(:,4) == gTfi\grpi)
        % Patellar x, y, z axis unit vector, Grood and Suntay definition
        patella.i  = squeeze( gTpi(1:3, 1, :));
        patella.j  = squeeze( gTpi(1:3, 2, :));
        patella.k  = squeeze( gTpi(1:3, 3, :));
    end
    patella.origin = grpi;

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
    bones.patella = patella;
    transforms.gTfi = gTfi;
    transforms.gTti = gTti;
    transforms.gTpi = gTpi;
    transforms.tTts = tTts;
    transforms.fTts = fTts;
end

% function [transforms, bones] = calculate_transforms(trackers, loading_condition, digitisation_transforms, config)
%     error("not yet implemented")
%     data.name = loading_condition;
%     config.specimen.loading_condition = loading_condition;
%
%     label = trackers.camera().get_possible_labels(config.camera_labels);
%
%     bones = {'tibia', 'femur', 'patella'};
%
%     for b = 1:numel(bones)
%         bone = bones{b};
%         data.(bone) = trackers.with_label(label.(bone));
%         %% Load how tracker moves with time
%         if data.(bone).is_none
%             bones.(bone).i = [];
%             bones.(bone).j = [];
%             bones.(bone).k = [];
%             in_global.(bone) = [];
%         end
%         gTtracker = findTrackerFixedFrames(data.(bone));
%
%         %% Load the digitisation
%         trackerTbone = digitisation_transforms.(bone).transform;
%         trackerrbone = digitisation_transforms.(bone).origin;
%         trackerTsurface = digitisation_transforms.(bone).surface_transform;
%
%         in_global.(bone) = pagemtimes(gTtracker, trackerTbone);
%
%         bones.(bone).i = squeeze(in_global.(bone)(1:3, 1, :));
%         bones.(bone).j = squeeze(in_global.(bone)(1:3, 2, :));
%         bones.(bone).k = squeeze(in_global.(bone)(1:3, 3, :));
%         bones.(bone).origin = squeeze(pagemtimes(gTtracker, trackerrbone)); %femur origin in global reference frame
%
%
%         if ~isempty(trackerTsurface)
%             gTs.(bone) = pagemtimes(gTtracker, trackerTsurface);
%             boneTsurface.(bone) = pagemldivide(in_global.(bone), gTs.(bone));
%         end
%
%         if isempty(ttTtscc)
%             gTtsi = []; 
%             fTts = [];
%             tTts = [];
%         else
%             gTtsi = pagemtimes(gTtti, ttTtscc); % Tibial surface relative to global
%             fTts = pagemldivide(gTfi, gTtsi);
%             tTts = pagemldivide(gTti, gTtsi); %% <<<<<<<<< This makes it constant.
%         end
%     end
%
%
%     if isempty(in_global.tibia) 
%         transforms.fTt = []
%     else
%         transforms.fTt = pagemldivide(in_global.femur, in_global.tibia);
%     end
%
%     if isempty(in_global.patella) 
%         transforms.fTp = []
%     else
%         transforms.fTp = pagemldivide(in_global.femur, in_global.patella);
%     end
%
%     transforms.tTts = tTts;
%     transforms.fTts = fTts;
% end
