function [output, difference, transforms_global] = run_data(data, trackers, right)

% Helper functions
angle = @(u_,v_) acosd(dot(u_,v_)/(norm(u_,2)*norm(v_,2))); %define a function to calculate the angle between two vectors
ucross=@(u_,v_) cross(u_,v_)/norm(cross(u_,v_),2); %define function to find unit cross product
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

result(length(gTfti)) = struct('flexion', [], 'varus', [], 'external', [], 'lateral', [], 'anterior', [], 'superior', []);
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
    grti=gTtti{i,1}*ttrtc; %tibia origin in global reference frame
    frti=gTfi{i,1}\(grti-grfi); %tibial origin point in the femoral reference frame, note this also equals gTfi{i,1}(1:3,1:3)'*(grti{i,1}(1:3)-grfi{i,1}(1:3); as in Woltring et al. It also equals fTt{i,1}(:,4) and equals gTfi{i,1}\grti{i,1} as gTfi{1,1}\grfi{1,1} = [0,0,0,1]' which makes sense as the femoral origin in the femoral reference frame is 0,0,0;

    % Patella
    if isempty(gTpti) || isempty(ptTtc)
        gTpi = [];
        fTp = [];
        grpi = [];
        frpi = [];
    else
        gTpi{i,1}=gTpti{i,1}*ptTtc;%multiply here instead of divide in Pam's method
        fTp=gTfi{i,1}\gTpi{i,1}; % Patella relative to the femur
        grpi=gTpti{i,1}*ptrpc; % Patellar origin (patellar tendon insertion) in the global frame of reference
        %convert the points to the femoral reference plane
        % grtPTi{i,1}=gTtti{i,1}*ttrtPTc; %tibial patella tendon insertion point in global frame of reference
        % frtPTi{i,1}=gTfi{i,1}\grtPTi{i,1}; %tibial patella tendon insertion point in femoral frame of reference
        frpi=gTfi{i,1}\grpi; %patella patella tendon insertion point in femoral frame of reference (equals fTp{i,1}(1:4,4))
    end

    I_=gTfi{i,1}(1:3,1);%Femoral X axis unit vector, Grood and Suntay definition
    J_=gTfi{i,1}(1:3,2);%Femoral Y axis unit vector, Grood and Suntay definition
    K_=gTfi{i,1}(1:3,3);%Femoral Z axis unit vector, Grood and Suntay definition
    
    i_=gTti{i,1}(1:3,1);%Tibial x axis unit vector, Grood and Suntay definition
    j_=gTti{i,1}(1:3,2);%Tibial y axis unit vector, Grood and Suntay definition
    k_=gTti{i,1}(1:3,3);%Tibial z axis unit vector, Grood and Suntay definition
    
    e1_=I_;%Femoral X axis in global reference frame, Grood and Suntay definition
    e3_=k_;%Tibial z axis in global reference frame, Grood and Suntay definition
    e2_=ucross(e3_,e1_);%Floating axis in global reference frame, Grood and Suntay definition
    
    flexion = asind(dot(-e2_,K_));
    beta = acosd(dot(I_,k_));
    if right
        external = asind(dot(-e2_,i_));
        varus = 90-beta;
    else
        external = asind(dot(e2_,i_));
        varus = -(90-beta);
    end
    
    %     H_=tibiaOrigin-femurOrigin;
    H_ = [grti(1:3)-grfi(1:3)]';%translation vector of from femoral origin to tibial origin (in global coordinate frame)
    if right
        lateral = dot(H_,e1_);%projected onto the medial lateral axis e1
    else
        lateral = dot(H_,-e1_);
    end
    anterior = dot(H_,e2_);%projected onto the anterior posterior axis e2
    distal = -dot(H_,e3_);%projected onto the compression distraction axis e3, minus sign to make distraction +ve
    
    
    %Code to check between different notations
    [angles(i,:),trfi(1,:)]=rotationsAndTranslations(fTt,right);

    trfi(1,:)=-trfi(1,:);%which also equals gTti{i,1}\(grfi{i,1}-grti{i,1})

    B=fTt;%B notation used in equations 18-20 in grood and suntay, note they use a matrix with translation rows 2-4 in column 1, here it is column 4 rows 1-3, and rotations are similarly mapped
    q(i,1)=B(1,4);
    if ~right
        q(i,1)=-q(i,1);
    end
    q(i,2)=B(2,4)*cosd(angles(i,1))-B(3,4)*sind(angles(i,1));
    q(i,3)=-(B(1,3)*B(1,4)+B(2,3)*B(2,4)+B(3,3)*B(3,4));

    
    % fRtCheck{i,1}=[dot(I_,i_) dot(I_,j_) dot(I_,k_)
    %     dot(J_,i_) dot(J_,j_) dot(J_,k_)
    %     dot(K_,i_) dot(K_,j_) dot(K_,k_)];
    % 
    % fRt{i,1}-fRtCheck{i,1};


    
    result(i).flexion = flexion;
    result(i).varus = varus;
    result(i).external = external;
    result(i).lateral = lateral;
    result(i).anterior = anterior;
    result(i).superior = distal;

end
output.data = struct2table(result);
output.name = strrep(data.name, '_', ' ');

    transforms_global.femur = gTfi;
    transforms_global.tibia = gTti;
    diff = table();
    diff.flexion = angles(:,1) - [result.flexion]';
    diff.varus = angles(:,2) - [result.varus]';
    diff.external = angles(:,3) - [result.external]';
    diff.lateral = q(:,1) - [result.lateral]';
    diff.anterior = q(:,2) - [result.anterior]';
    diff.superior = q(:,3) - [result.superior]';

    difference.data = diff;
    difference.name = data.name;
end
