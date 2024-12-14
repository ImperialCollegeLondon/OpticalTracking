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

output(length(gTfti)) = struct('flexion', [], 'varus', [], 'external', [], 'lateral', [], 'anterior', [], 'superior', []);

for i = 1:length(gTfti)
    %calculate the body fixed motion relative to the global coordinates
    gTfi{i,1}=gTfti{i,1}*ftTfc;%multiply here instead of multiply by inverse as detailed in Pam's method
    gTti{i,1}=gTtti{i,1}*ttTtc;%multiply here instead of divide in Pam's method
    
    %calculate the motion relative to each other
    fTt{i,1}=gTfi{i,1}\gTti{i,1}; % Transformation of Tibia relative to the femur
    fRt{i,1}=fTt{i,1}(1:3,1:3); %Rotations of tibia relative to femur
    
    %calculate the position vectors of the origin in the global frame of
    %reference
    grfi{i,1}=gTfti{i,1}*ftrfc; %femur origin in global reference frame
    grti{i,1}=gTtti{i,1}*ttrtc; %tibia origin in global reference frame
    frti{i,1}=gTfi{i,1}\(grti{i,1}-grfi{i,1}); %tibial origin point in the femoral reference frame, note this also equals gTfi{i,1}(1:3,1:3)'*(grti{i,1}(1:3)-grfi{i,1}(1:3); as in Woltring et al. It also equals fTt{i,1}(:,4) and equals gTfi{i,1}\grti{i,1} as gTfi{1,1}\grfi{1,1} = [0,0,0,1]' which makes sense as the femoral origin in the femoral reference frame is 0,0,0;

    % Patella
    if isempty(gTpti) || isempty(ptTtc)
        gTpi = [];
        fTp = [];
        grpi = [];
        frpi = [];
        frti = [];
    else
        gTpi{i,1}=gTpti{i,1}*ptTtc;%multiply here instead of divide in Pam's method
        fTp{i,1}=gTfi{i,1}\gTpi{i,1}; % Patella relative to the femur
        grpi{i,1}=gTpti{i,1}*ptrpc; % Patellar origin (patellar tendon insertion) in the global frame of reference
        %convert the points to the femoral reference plane
        % grtPTi{i,1}=gTtti{i,1}*ttrtPTc; %tibial patella tendon insertion point in global frame of reference
        % frtPTi{i,1}=gTfi{i,1}\grtPTi{i,1}; %tibial patella tendon insertion point in femoral frame of reference
        frpi{i,1}=gTfi{i,1}\grpi{i,1}; %patella patella tendon insertion point in femoral frame of reference (equals fTp{i,1}(1:4,4))
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
    beta(i,1) = acosd(dot(I_,k_));
    if right
        external = asind(dot(-e2_,i_));
        varus = 90-beta(i,1);
    else
        external = asind(dot(e2_,i_));
        varus = -(90-beta(i,1));
    end
    
    %     H_=tibiaOrigin-femurOrigin;
    H_(i,:)=[grti{i,1}(1:3)-grfi{i,1}(1:3)]';%translation vector of from femoral origin to tibial origin (in global coordinate frame)
    if right
        lateral = dot(H_(i,:),e1_);%projected onto the medial lateral axis e1
    else
        lateral = dot(H_(i,:),-e1_);
    end
    anterior = dot(H_(i,:),e2_);%projected onto the anterior posterior axis e2
    distal = -dot(H_(i,:),e3_);%projected onto the compression distraction axis e3, minus sign to make distraction +ve
    
    
    %Code to check between different notations
    [angles(i,:),trfi{i,1}(1,:)]=rotationsAndTranslations(fTt{i},right);

    trfi{i,1}(1,:)=-trfi{i,1}(1,:);%which also equals gTti{i,1}\(grfi{i,1}-grti{i,1})

    B=fTt{i};%B notation used in equations 18-20 in grood and suntay, note they use a matrix with translation rows 2-4 in column 1, here it is column 4 rows 1-3, and rotations are similarly mapped
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


    
    output(i).flexion = flexion;
    output(i).varus = varus;
    output(i).external = external;
    output(i).lateral = lateral;
    output(i).anterior = anterior;
    output(i).superior = distal;
    
end
    transforms_global.femur = gTfi;
    transforms_global.tibia = gTti;

    difference(i).flexion = angles(:,1) - output(i).flexion;
    difference(i).varus = angles(:,2) - output(i).varus;
    difference(i).external = angles(:,3) - output(i).external;
    difference(i).lateral = q(:,1) - output(i).lateral;
    difference(i).anterior = q(:,2) - output(i).anterior;
    difference(i).superior = q(:,3) - output(i).superior;

end
