function [output, transforms] = calculate_joint_kinematics(data, trackers, right)
% Use RvA nomenclature for all transforms and references (origins)
ttTtc = trackers.tibia.transform;
ttrtc = trackers.tibia.origin;
ftTfc = trackers.femur.transform;
ftrfc = trackers.femur.origin;
ptTtc = trackers.patella.transform;
ptrpc = trackers.patella.origin;

%% Load how tracker moves with time
gTtti = findTrackerFixedFrames(data.tibia.rotations, data.tibia.translations);
gTfti = findTrackerFixedFrames(data.femur.rotations, data.femur.translations);
gTpti = findTrackerFixedFrames(data.patella.rotations, data.patella.translations);
% Create matrices of tracker marker position and rotations in time


%% Calculate transformation matricies from body fixed to global fixed frames and motion relative to initial position

gTfi = pagemtimes(gTfti, ftTfc);%multiply here instead of multiply by inverse as detailed in Pam's method
gTti = pagemtimes(gTtti, ttTtc);%multiply here instead of divide in Pam's method
fTt = pagemldivide(gTfi, gTti); % Transformation of Tibia relative to the femur

% fRt=fTt(1:3,1:3); %Rotations of tibia relative to femur

%calculate the position vectors of the origin in the global frame of
%reference
grfi = squeeze(pagemtimes(gTfti, ftrfc)); %femur origin in global reference frame
femur.point=grfi;
grti = squeeze(pagemtimes(gTtti, ttrtc)); %tibia origin in global reference frame
tibia.point=grti;
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
patella.point  = grpi;

% Femoral x, y, z unit vector, Grood and Suntay definition
femur.i = squeeze(gTfi(1:3, 1, :));
femur.j = squeeze(gTfi(1:3, 2, :));
femur.k = squeeze(gTfi(1:3, 3, :));

%Tibial x, y, z axis unit vector, Grood and Suntay definition
tibia.i = squeeze(gTti(1:3, 1, :));
tibia.j = squeeze(gTti(1:3, 2, :));
tibia.k = squeeze(gTti(1:3, 3, :));

result_tf = motion_tibiofemoral(fTt, femur, tibia, right);
result_pf = motion_patellofemoral(fTp, femur, patella, right);

output.name = strrep(data.name, '_', ' ');
output.patellofemoral = result_pf;
output.tibiofemoral = result_tf;

transforms.in_global.femur = gTfi;
transforms.in_global.tibia = gTti;
transforms.in_global.patella = gTpi;
transforms.in_femur.tibia = fTt;
transforms.in_femur.patella = fTp;
transforms.in_femur.femur = repmat(eye(4), 1, 1, size(fTt, 3));
end

