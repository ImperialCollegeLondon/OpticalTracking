function [output, transforms_global] = run_data(data, trackers, right)

    % Helper functions
    angle = @(u_,v_) acosd(dot(u_,v_)/(norm(u_,2)*norm(v_,2))); %define a function to calculate the angle between two vectors
    uvector=@(a,b) (b-a)/norm(b-a,2); %define a function to find a unit vector from a to b

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

    result_tf(length(gTfti)) = struct('flexion', [], 'varus', [], 'external', [], 'lateral', [], 'anterior', [], 'superior', []);
    result_pf(length(gTfti)) = struct('flexion', [], 'medial_rotation', [], 'lateral_tilt', [], 'medial_shift', [], 'anterior', [], 'superior', []);

    %% Preallocate
    gTfi = cell(size(gTfti));
    gTti = cell(size(gTfti));
    gTpi = cell(size(gTfti));
    %%
    for i = 1:length(gTfti)
        %calculate the body fixed motion relative to the global coordinates
        gTfi{i,1}=gTfti{i,1}*ftTfc;%multiply here instead of multiply by inverse as detailed in Pam's method
        gTti{i,1}=gTtti{i,1}*ttTtc;%multiply here instead of divide in Pam's method
        
        %calculate the motion relative to each other
        fTt=gTfi{i,1}\gTti{i,1}; % Transformation of Tibia relative to the femur
        fRt=fTt(1:3,1:3); %Rotations of tibia relative to femur
        
        %calculate the position vectors of the origin in the global frame of
        %reference
        grfi=gTfti{i,1}*ftrfc; %femur origin in global reference frame
        femur.point=grfi;
        grti=gTtti{i,1}*ttrtc; %tibia origin in global reference frame
        tibia.point=grti;
        frti=gTfi{i,1}\(grti-grfi); %tibial origin point in the femoral reference frame, note this also equals gTfi{i,1}(1:3,1:3)'*(grti{i,1}(1:3)-grfi{i,1}(1:3); as in Woltring et al. It also equals fTt{i,1}(:,4) and equals gTfi{i,1}\grti{i,1} as gTfi{1,1}\grfi{1,1} = [0,0,0,1]' which makes sense as the femoral origin in the femoral reference frame is 0,0,0;
        
        % Creates the structures the code expects, but all with empty data. Necessary to handle a missing patella without crashing.
        if isempty(gTpti) || isempty(ptTtc)
            gTpi = [];
            fTp = [];
            grpi = [];
            frpi = [];
            patella.i = [];
            patella.j = [];
            patella.k = [];
        else
            gTpi{i,1}=gTpti{i,1}*ptTtc;%multiply here instead of divide in Pam's method
            fTp=gTfi{i,1}\gTpi{i,1}; % Patella relative to the femur
            grpi=gTpti{i,1}*ptrpc; % Patellar origin (patellar tendon insertion) in the global frame of reference
            %convert the points to the femoral reference plane
            % grtPTi{i,1}=gTtti{i,1}*ttrtPTc; %tibial patella tendon insertion point in global frame of reference
            % frtPTi{i,1}=gTfi{i,1}\grtPTi{i,1}; %tibial patella tendon insertion point in femoral frame of reference
            frpi=gTfi{i,1}\grpi; %patella patella tendon insertion point in femoral frame of reference (equals fTp{i,1}(1:4,4))
            patella.i=gTpi{i,1}(1:3,1);%Patellar x axis unit vector, Grood and Suntay definition
            patella.j=gTpi{i,1}(1:3,2);%Patellar y axis unit vector, Grood and Suntay definition
            patella.k=gTpi{i,1}(1:3,3);%Patellar z axis unit vector, Grood and Suntay definition
        end
        patella.point = grpi;
        
        femur.i=gTfi{i,1}(1:3,1);%Femoral X axis unit vector, Grood and Suntay definition
        femur.j=gTfi{i,1}(1:3,2);%Femoral Y axis unit vector, Grood and Suntay definition
        femur.k=gTfi{i,1}(1:3,3);%Femoral Z axis unit vector, Grood and Suntay definition
        
        tibia.i=gTti{i,1}(1:3,1);%Tibial x axis unit vector, Grood and Suntay definition
        tibia.j=gTti{i,1}(1:3,2);%Tibial y axis unit vector, Grood and Suntay definition
        tibia.k=gTti{i,1}(1:3,3);%Tibial z axis unit vector, Grood and Suntay definition
        
        
        result_tf(i) = motion_tibiofemoral(fTt, femur, tibia, right);
        result_pf(i) = motion_patellofemoral(fTp, femur, patella, right);
        
    end

    output.name = strrep(data.name, '_', ' ');
    output.patellofemoral = struct2table(result_pf);
    output.tibiofemoral = struct2table(result_tf);

    transforms_global.femur = gTfi;
    transforms_global.tibia = gTti;
    transforms_global.patella = gTpi;
end

