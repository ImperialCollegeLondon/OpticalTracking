function trajectory = grood_and_suntay(data, trackers, config)
    right = config.is_right_knee;
    trajectory = Trajectory(config.specimen.name, config.specimen.state, config.specimen.loading_condition, false, right);
    % Use RvA nomenclature for all transforms and references (origins)
    ttTtc = trackers.tibia.transform;
    ttrtc = trackers.tibia.origin;
    ftTfc = trackers.femur.transform;
    ftrfc = trackers.femur.origin;
    ptTtc = trackers.patella.transform;
    ptrpc = trackers.patella.origin;

    %% Load how tracker moves with time
    gTtti = findTrackerFixedFrames(data.tibia);
    gTfti = findTrackerFixedFrames(data.femur);
    gTpti = findTrackerFixedFrames(data.patella);
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

    trajectory.add_data('tibiofemoral', GroodAndSuntay.tibiofemoral(fTt, femur, tibia, right));
    trajectory.add_data('patellofemoral', GroodAndSuntay.patellofemoral(fTp, femur, patella, right));

    trajectory.add_transforms('gTfi', gTfi);
    trajectory.add_transforms('gTti', gTti);
    trajectory.add_transforms('gTpi', gTpi);
    trajectory.add_transforms('fTt', fTt);
    trajectory.add_transforms('fTp', fTp);
    trajectory.add_transforms('fTf', repmat(eye(4), 1, 1, size(fTt, 3)));

% num_nan = sum(isnan(table2array(result_tf)), "all");
% if num_nan > 0.2 * numel(result_tf)
%     warning("%s %s: %d%% of data missing", config.specimen.state, config.specimen.loading_condition, round(num_nan/numel(result_tf)*100) )
%     if config.plot_missing_data
%         plot_raw(output, config, {});
%     end
% end
%
% if config.enable_warn_arc_of_flexion && max(result_tf.flexion) - min(result_tf.flexion) < config.warn_arc_of_flexion
%     warning("%s %s: Arc of flexion less than 50 deg", config.specimen.state, config.specimen.loading_condition)
% end
end
