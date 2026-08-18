% This code uses the method outlined by Spoor and Veldpaus (1980) to
% compute the position of the helical screw axis (distinct from the
% instantaneous screw axis). It is intended as a validation of the
% instantaneous screw axis code which was based on the calculation of the
% angular velocity vector from the time derivative of the rotation matrix.

% This code combines the helical axis plots of the screw axis using the
% angular velocity and the method used by Spoor & Veldpaus (1980)

% Change Log

% July 2013 - Original code for hip joint  in ISB coordinate system by 
% Richard van Arkel

% June 2017 - Modified by Kiron Athwal to Grood & Suntay knee definitions
% i.e. definitions of XYZ for knee rather than for hip. + code updated for 
% new Polaris

% 11 July 2018 - Modified for screw axis location by Daryl Shieu Ming Pay
% including creation of patella tracking code.
 
% 06 Sept 2018 - Modified by Richard van Arkel ascertain left and right and 
% to get woltring, boyd and pandy methods to give same result (Finishing 
% Daryl's work).

% 12 Apr 2019 - SARA added by Richard van Arkel.

% 19 Apr 2019 - Grood and Suntay origin added by Richard van Arkel.

clear all
close all

angle = @(u_,v_) acosd(dot(u_,v_)/(norm(u_,2)*norm(v_,2))); %define a function to calculate the angle between two vectors
ucross=@(u_,v_) cross(u_,v_)/norm(cross(u_,v_),2); %define function to find unit cross product
uvector=@(a,b) (b-a)/norm(b-a,2); %define a function to find a unit vector from a to b

%% Inputs

% for the polaris coordinate systems, Y is width of view (parallel to floor), X is height, Z is depth of view 
freq=60;% Polaris tracking frequency.

right=false; % true for a right knee, false for a left knee

folderPathDigitise=fullfile(pwd,'data/Digitisation/');
folderPathData=fullfile(pwd,'data/Intact_COR_0/');
fileNameData=[folderPathData,'Anterior.csv'];

% folderPathDigitise=fullfile(pwd,'Amy Pilot Intact\Wooden Right Knee\Digitise');
% folderPathData=fullfile(pwd,'Amy Pilot Intact\Wooden Right Knee\DataPT53mm');
% fileNameData=[folderPathData,'\FlexExt-Quick.csv'];



%% Load axis data AND original points for the trackers

% TIBIA AXIS POINTS
fileNameDigitise=[folderPathDigitise,'tm.csv'];
rawData = readmatrix(fileNameDigitise);
XYZdataT{1} = rawData(:,all(~isnan(rawData)));%Polaris records something that is NaN when the data is missing, this line effectively gets rid of data where one of the trackers goes out of view and hence records missing data

fileNameDigitise=[folderPathDigitise,'tl.csv'];
rawData = readmatrix(fileNameDigitise);
XYZdataT{2} = rawData(:,all(~isnan(rawData)));

fileNameDigitise=[folderPathDigitise,'td1.csv'];
rawData = readmatrix(fileNameDigitise);
XYZdataT{3} = rawData(:,all(~isnan(rawData)));

% % Insertion point of the patella tendon on the tibia
% fileNameDigitise=[folderPathDigitise,'td1.csv'];
% rawData = readmatrix(fileNameDigitise);
% XYZdataT{4} = rawData(:,all(~isnan(rawData)));

TMed=mean(XYZdataT{1}(:,48:50)); % black probe are rows 48:50 but this may change!
TLat=mean(XYZdataT{2}(:,48:50));
TDis=mean(XYZdataT{3}(:,48:50));
% TIns=mean(XYZdataT{4}(:,48:50)); % Insertion point of the patella tendon on the tibia


tibiaXYZ=mean(XYZdataT{1}(:,28:30)); % tibia T probe rows 28:30
tibiaQ=mean(XYZdataT{1}(:,24:27));
tibiaR=quaternion2euler(tibiaQ);
% tibiaR=quaternion(tibiaQ);
    
% FEMUR AXIS POINTS
fileNameDigitise=[folderPathDigitise,'fm.csv'];
rawData = readmatrix(fileNameDigitise);
XYZdataF{1} = rawData(:,all(~isnan(rawData)));

fileNameDigitise=[folderPathDigitise,'fm.csv'];
rawData = readmatrix(fileNameDigitise);
XYZdataF{2} = rawData(:,all(~isnan(rawData)));

fileNameDigitise=[folderPathDigitise,'fp1.csv'];
rawData = readmatrix(fileNameDigitise);
XYZdataF{3} = rawData(:,all(~isnan(rawData)));

FMed=mean(XYZdataF{1}(:,48:50));
FLat=mean(XYZdataF{2}(:,48:50));
FProx=mean(XYZdataF{3}(:,48:50)); 

femurXYZ=mean(XYZdataF{1}(:,8:10)); % femur Y probe rows 8:10
femurQ=mean(XYZdataF{1}(:,4:7));
femurR=quaternion2euler(femurQ);
% femurR=quaternion(femurQ);


% %%% PATELLA AXIS POINTS (Added by Daryl 30/7/2018)
% fileNameDigitise=[folderPathDigitise,'fm.csv'];
% rawData = readmatrix(fileNameDigitise);
% XYZdataP{1} = rawData(:,all(~isnan(rawData)));
% 
% fileNameDigitise=[folderPathDigitise,'fl.csv'];
% rawData = readmatrix(fileNameDigitise);
% XYZdataP{2} = rawData(:,all(~isnan(rawData)));
% 
% fileNameDigitise=[folderPathDigitise,'fl.csv'];
% rawData = readmatrix(fileNameDigitise);
% XYZdataP{3} = rawData(:,all(~isnan(rawData)));
% 
% PMed=mean(XYZdataP{1}(:,48:50));
% PLat=mean(XYZdataP{2}(:,48:50));
% PDis=mean(XYZdataP{3}(:,48:50));
% PIns=PDis;
% 
% patellaXYZ=mean(XYZdataP{1}(:,68:70)); % patella ImpacTrac3 probe
% patellaQ=mean(XYZdataP{1}(:,64:67));
% patellaR=quaternion2euler(patellaQ);
% % patellaR=quaternion(patellaQ);


[gTf0,originF]=defineBodyFixedFrameFemur_v2(FMed,FLat,FProx,right);%The body frame of reference in the global coordiante system for the femur
grf0=[originF,1]';%r is a point, T is a frame of reference.  This point is the location of the origin of the body fixed coordinate system

[gTt0,originT]=defineBodyFixedFrameTibia_v2(TMed,TLat,TDis,right);%The body frame of reference in the global coordiante system for the tibia
grt0=[originT,1]';%r is a point, T is a frame of reference.  This point is the location of the origin of the body fixed coordinate system

% % Analagous line of code for the patella, Daryl 30/7/2018
% [gTp0,originP] = defineBodyFixedFramePatella_v2(PMed,PLat,PDis,right);%The body frame of reference in the global coordiante system for the patella
% grp0=[PIns,1]';%r is a point, T is a frame of reference.  This point is the location of the origin of the body fixed coordinate system
% grtPT0 = [TIns,1]';% This is the position of the patella tendon insertion on the tibia in the global coordinate system (Daryl)


%% Load original points for the trackers

[gTtt0]=defineTrackerFixedFrame_v2(tibiaR,tibiaXYZ);%The tibia tracker frame in global coordinates
[gTft0]=defineTrackerFixedFrame_v2(femurR,femurXYZ);%The femur tracker frame in global coordinates
% [gTpt0]=defineTrackerFixedFrame_v2(patellaR,patellaXYZ);%The patella tracker frame in global coordinates (Daryl)

%% Relate body fixed frames and origin to the tracker rigid body

ftTfc=gTft0\gTf0;%a constant transform of the body fixed frame in the tracker frame of reference (assumes rigid body)
ttTtc=gTtt0\gTt0;%a constant transform of the body fixed frame in the tracker frame of reference (assumes rigid body)
% ptTtc=gTpt0\gTp0;%a constant transform of the body fixed frame in the tracker frame of reference (assumes rigid body) (Daryl)


ftrfc=gTft0\grf0;%relating the origin of the body fixed coordiate system to tracker frame of reference
ttrtc=gTtt0\grt0;%relating the origin of the body fixed coordiate system to tracker frame of reference
% ptrpc=gTpt0\grp0;%relating the origin of the body fixed coordiate system to tracker frame of reference (patella) (Daryl)
% ttrtPaTc=gTtt0\grtPT0;


%% Load tracked points
 
rawData = readmatrix(fileNameData);
rawDataNoNaN = rawData(1:end-1,all(~isnan(rawData(1:end-1,:)))); %Note deletes last row of data as sometime Polaris exports file with last row not complete

TrackedData=rawDataNoNaN(~logical(rawDataNoNaN(1:end-1,11)==0 | rawDataNoNaN(1:end-1,31)==0 | rawDataNoNaN(1:end-1,71)==0),:); % deletes any rows where femoral tibial or patella trackers go missing (error appears to be 0)

tibiaXYZs=TrackedData(:,28:30);% tibia T probe rows 28:30
tibiaQs=TrackedData(:,24:27);
    for i = 1:size(tibiaQs,1)
        tibiaRs(i,:)=quaternion2euler(tibiaQs(i,:));
    end

femurXYZs=TrackedData(:,8:10);% femur Y probe rows 8:10
femurQs=TrackedData(:,4:7);
    for i = 1:size(femurQs,1)
        femurRs(i,:)=quaternion2euler(femurQs(i,:));
    end

% Analagous line of code for the patella
% patellaXYZs=TrackedData(:,68:70);% patella ImpacTrac3 probe 
% patellaQs=TrackedData(:,64:67);
%     for i = 1:size(patellaQs,1)
%         patellaRs(i,:)=quaternion2euler(patellaQs(i,:));
%     end
    
    
[gTfti]=findTrackerFixedFrames_v2(femurRs,femurXYZs);%how the femur tracker moves with time
[gTtti]=findTrackerFixedFrames_v2(tibiaRs,tibiaXYZs);%how the tibia tracker moves with time
% [gTpti]=findTrackerFixedFrames_v2(patellaRs,patellaXYZs);%how the patella tracker moves with time (Daryl)



%% Calculate transformation matricies from body fixed to global fixed frames and motion relative to initial position

for i = 1:length(gTfti)
   
   
    %calculate the body fixed motion relative to the global coordinates
    gTfi{i,1}=gTfti{i,1}*ftTfc;%multiply here instead of multiply by inverse as detailed in Pam's method
    gTti{i,1}=gTtti{i,1}*ttTtc;%multiply here instead of divide in Pam's method
    % gTpi{i,1}=gTpti{i,1}*ptTtc;%multiply here instead of divide in Pam's method
    
    
    %calculate the motion relative to each other
    fTt{i,1}=gTfi{i,1}\gTti{i,1}; % Transformation of Tibia relative to the femur
    fRt{i,1}=fTt{i,1}(1:3,1:3); %Rotations of tibia relative to femur
    % fTp{i,1}=gTfi{i,1}\gTpi{i,1}; % Patella relative to the femur
    
    
    %calculate the position vectors of the origin in the global frame of
    %reference
    grfi{i,1}=gTfti{i,1}*ftrfc; %femur origin in global reference frame
    grti{i,1}=gTtti{i,1}*ttrtc; %tibia origin in global reference frame
    % grpi{i,1}=gTpti{i,1}*ptrpc; % Patellar origin (patellar tendon insertion) in the global frame of reference
    % grtPTi{i,1}=gTtti{i,1}*ttrtPTc; %tibial patella tendon insertion point in global frame of reference
    
    % %convert the points to the femoral reference plane
    % frtPTi{i,1}=gTfi{i,1}\grtPTi{i,1}; %tibial patella tendon insertion point in femoral frame of reference
    % frpi{i,1}=gTfi{i,1}\grpi{i,1}; %patella patella tendon insertion point in femoral frame of reference (equals fTp{i,1}(1:4,4))
    frti{i,1}=gTfi{i,1}\(grti{i,1}-grfi{i,1}); %tibial origin point in the femoral reference frame, note this also equals gTfi{i,1}(1:3,1:3)'*(grti{i,1}(1:3)-grfi{i,1}(1:3); as in Woltring et al. It also equals fTt{i,1}(:,4) and equals gTfi{i,1}\grti{i,1} as gTfi{1,1}\grfi{1,1} = [0,0,0,1]' which makes sense as the femoral origin in the femoral reference frame is 0,0,0;
    
    I_=gTfi{i,1}(1:3,1);%Femoral X axis unit vector, Grood and Suntay definition
    J_=gTfi{i,1}(1:3,2);%Femoral Y axis unit vector, Grood and Suntay definition
    K_=gTfi{i,1}(1:3,3);%Femoral Z axis unit vector, Grood and Suntay definition
    
    i_=gTti{i,1}(1:3,1);%Tibial x axis unit vector, Grood and Suntay definition
    j_=gTti{i,1}(1:3,2);%Tibial y axis unit vector, Grood and Suntay definition
    k_=gTti{i,1}(1:3,3);%Tibial z axis unit vector, Grood and Suntay definition
    
    e1_=I_;%Femoral X axis in global reference frame, Grood and Suntay definition
    e3_=k_;%Tibial z axis in global reference frame, Grood and Suntay definition
    e2_=ucross(e3_,e1_);%Floating axis in global reference frame, Grood and Suntay definition
    
    Flexion(i,1)=asind(dot(-e2_,K_));
    beta(i,1)=acosd(dot(I_,k_));
    if right
        ExtRotation(i,1)=asind(dot(-e2_,i_));
        Varus(i,1)=90-beta(i,1);
    else
        ExtRotation(i,1)=asind(dot(e2_,i_));
        Varus(i,1)=-(90-beta(i,1));
    end
    
%     H_=tibiaOrigin-femurOrigin;
    H_(i,:)=[grti{i,1}(1:3)-grfi{i,1}(1:3)]';%translation vector of from femoral origin to tibial origin (in global coordinate frame)
    if right    
        LatMed(i,1)=dot(H_(i,:),e1_);%projected onto the medial lateral axis e1
    else
        LatMed(i,1)=dot(H_(i,:),-e1_);
    end
    AntPost(i,1)=dot(H_(i,:),e2_);%projected onto the anterior posterior axis e2
    DistComp(i,1)=-dot(H_(i,:),e3_);%projected onto the compression distraction axis e3, minus sign to make distraction +ve
        
    
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


%     fRtCheck{i,1}=[dot(I_,i_) dot(I_,j_) dot(I_,k_)
%                  dot(J_,i_) dot(J_,j_) dot(J_,k_)
%                  dot(K_,i_) dot(K_,j_) dot(K_,k_)];
%     fRt{i,1}-fRtCheck{i,1}
             
end

differenceT=q-[LatMed,AntPost,DistComp];
differenceR=angles-[Flexion,Varus,ExtRotation];

%% Recalculating translation with femoral and tibial origin specified according to Grood and Suntay.

rowExt=find(Flexion==min(Flexion));%position of full extension
rowFlx=find(Flexion==max(Flexion));%position of deep hip flexion

%Screw axis from min to max flexion, using SARA approach (Ehrig 2007)
R1=gTfi{rowFlx}(1:3,1:3);%pose of femoral reference frame in global coordinates when in deep flexion
R0=gTfi{rowExt}(1:3,1:3);%fem reference frame in global coordinates when in extension
S1=gTti{rowFlx}(1:3,1:3);%Tib reference frame in global coordinates in flexion
S0=gTti{rowExt}(1:3,1:3);%Tib reference frame in global coordinates in extension
t1=gTfi{rowFlx}(1:3,4);%location of the femoral reference frame origin in global coordinates in flexion
t0=gTfi{rowExt}(1:3,4);%location of the femoral reference frame origin in global coordinates in extension
d1=gTti{rowFlx}(1:3,4);%location of the tibial reference frame origin in global coordinates in flexion
d0=gTti{rowExt}(1:3,4);%location of the tibial reference frame origin in global coordinates in extension

LHS=R1-S1*S0'*R0;%multiply out line 1 and line 2 of matrix from Ehrig 2007 equation 2.  Then solve simultaneous equations to eliminate c1 or c2.  Collect like terms for remaining of c1 or c2.  Then LHS is the Left hand side of this equation.  RHS is the right hand side of this equation.  See photo in this folder or see Ehrig 2019, equation 13 for simplified example.
RHS=(d1-t1)-S1*S0'*(d0-t0);%see comment above
[U,E,V]=svd(LHS);%solve the equation LHS=RHS using singular value decomposition and the pseudo inverse.
SARAfullROM=V(1:3,3);%helical axis direction in femoral reference frame.  See Ehrig 2019 paragraph below equation 13.
point=V*diag([1/E(1,1),1/E(2,2),0])*U'*RHS;%solving to find c1 Ehrig 2007 equation 2, or cf photo in this folder using psuedoinverse from SVD.  The point is in the femoral reference frame.  For singular values of zero (or very close to zero, set their inverse to 0, rather than infinity, hence why pseudo inverse).

%vector equation of helical axis is r_=point+mu*SARAfullROM.  Need to find
%mu.  Using formula from here https://en.wikipedia.org/wiki/Line–plane_intersection to find mu.
mu=dot(([0,0,0]'-point),[1,0,0])/dot(SARAfullROM,[1,0,0]);%in femoral reference frame noting that sagittal plane normal is just the femoral X axis I.e. [1,0,0] in femoral reference frame,  and noting that 0,0,0 is a point on the mid femoral sagittal plane
isp=point+mu*SARAfullROM;%intersection point in femoral reference frame
gOf0=gTf0*[isp;1];%convert isp from femoral frame to global frame to find the new femoral origin in the global reference frame

%Repeating calc in the global frame to verify the same result
gSARAfullROM=gTf0(1:3,1:3)*SARAfullROM;
gPoint=originF'+gTf0(1:3,1:3)*point;
sagittalNormal=gTf0(1:3,1);%medial-lateral femoral axis is normal to femoral sagittal plane
gMu=dot((originF'-gPoint),sagittalNormal)/dot(gSARAfullROM,sagittalNormal);
gIsp=gPoint+gMu*gSARAfullROM;%intersection point
gOf0Check=[gIsp;1];

ftOfc=gTft0\gOf0;%relating the new femoral origin to femoral tracker frame of reference
gOfExt=gTfti{rowExt,1}*ftOfc;%location of the new femoral origin at terminal extension
gOfFlx=gTfti{rowFlx,1}*ftOfc;%location of the new femoral origin in deep flexion
gOt0=(gOfFlx+gOfFlx)/2;%The tibial origin was taken as the average of the two locations of the femoral origin corresponding to the beginning and the end of the motion
ttOtc=gTtt0\gOt0;%relating the new tibial origin to tibial tracker frame of reference

%re-calculate translation using new origins
for i=1:length(gTfti)
    
    gOfi{i,1}=gTfti{i,1}*ftOfc;
    gOti{i,1}=gTtti{i,1}*ttOtc;
    
    I_=gTfi{i,1}(1:3,1);
    J_=gTfi{i,1}(1:3,2);
    K_=gTfi{i,1}(1:3,3);
    
    i_=gTti{i,1}(1:3,1);
    j_=gTti{i,1}(1:3,2);
    k_=gTti{i,1}(1:3,3);
    
    e1_=I_;%Femoral X axis
    e3_=k_;%Tibial z axis
    e2_=ucross(e3_,e1_);%Floating axis
    
    %GS stands for Grood Suntay Origin
    H_GSO(i,:)=[gOti{i,1}(1:3)-gOfi{i,1}(1:3)]';%translation vector of from femoral origin to tibial origin (in global coordinate frame)
    if right    
        LatMedGSO(i,1)=dot(H_GSO(i,:),e1_);%projected onto the medial lateral axis e1
    else
        LatMedGSO(i,1)=dot(H_GSO(i,:),-e1_);
    end
    AntPostGSO(i,1)=dot(H_GSO(i,:),e2_);%projected onto the anterior posterior axis e2
    DistCompGSO(i,1)=-dot(H_GSO(i,:),e3_);%projected onto the compression distraction axis e3, minus sign to make distraction +ve
end

%% Finding a screw axis: The SARA approach - EHRIG 2007 (notation for S, R, t and d), more details EHRIG 2019

for i = 1:length(gTfi)
    if i==1
        R1=gTfi{i+1}(1:3,1:3);
        R0=gTfi{i}(1:3,1:3);
        S1=gTti{i+1}(1:3,1:3);
        S0=gTti{i}(1:3,1:3);
        t1=gTfi{i+1}(1:3,4);
        t0=gTfi{i}(1:3,4);
        d1=gTti{i+1}(1:3,4);
        d0=gTti{i}(1:3,4);
    elseif i==length(gTfi)
        R1=gTfi{i}(1:3,1:3);
        R0=gTfi{i-1}(1:3,1:3);
        S1=gTti{i}(1:3,1:3);
        S0=gTti{i-1}(1:3,1:3);
        t1=gTfi{i}(1:3,4);
        t0=gTfi{i-1}(1:3,4);
        d1=gTti{i}(1:3,4);
        d0=gTti{i-1}(1:3,4);
    else
        R1=gTfi{i+1}(1:3,1:3);
        R0=gTfi{i-1}(1:3,1:3);
        S1=gTti{i+1}(1:3,1:3);
        S0=gTti{i-1}(1:3,1:3);
        t1=gTfi{i+1}(1:3,4);
        t0=gTfi{i-1}(1:3,4);
        d1=gTti{i+1}(1:3,4);
        d0=gTti{i-1}(1:3,4);
    end
    
    LHS=R1-S1*S0'*R0;
    RHS=(d1-t1)-S1*S0'*(d0-t0);
    [U,E,V]=svd(LHS);
    dSARA{i,1}=V(1:3,3);%helical axis direction in femoral reference frame
    pSARA{i,1}=V*diag([1/E(1,1),1/E(2,2),0])*U'*RHS;%point on helical axis in femoral reference frame
end


%% Finding a screw axis via Numerical Angular Velocity Method

for i = 1:length(fTt)
    R{i,1} = fRt{i,1};
    p{i,1}=frti{i,1}(1:3,1);%equation 16 Woltring et al
    PTinsP{i,1} = frpi{i,1}(1:3,1) ;
    PTinsT{i,1} = frtPTi{i,1}(1:3,1) ;
end

% Numerically differentiate the orientation matrices using the function
% numdiff, in order to later compute the angular velocity tensor omegatens
% and the veloctiy of the tibial origin in the fem reference frame
dt = 1/freq; 
dRdt = numdiff(R,dt); % dRdt is a cell array of rotation matrix derivatives
%find the linear velocity of the tibial origin in the femoral reference
%frame
dpdt=numdiff(p,dt);

% Use the numerical derivative of the orientation matrix to compute angular
% velocity tensor https://en.wikipedia.org/wiki/Angular_velocity
A = {}; % compute the cell array of angular velocity tensors, using notation of A based on Woltring 1994 notation (equation 21)
for i = 1:length(dRdt)
    A{i,1} = dRdt{i,1}*R{i,1}'; %Woltring 1994 equation 21.  Note as rotation matrix orthogonal, this is the same as: dRdt{i,1}*inv(R{i,1});
end

% %Verify: replacing middle values with the equation recommended by Woltring et al. 1994 
% (doesnt really make much difference to the results, but feels right to be consistent with paper so this line exists if want to check the same).
% for i = 2:length(R)-1
%     A{i,1} = 1/(4*dt)*(R{i+1,1}*R{i-1,1}'-R{i-1,1}*R{i+1,1}'); %Equation 25 From Woltring et al. 1994: Instantaneous helical axis estimation from 3-D video data in neck kinematics for whiplash diagnostics
% end

W = {};
for i = 1:length(A)
    W{i,1} = [mean([A{i,1}(3,2),-A{i,1}(2,3)]);mean([-A{i,1}(3,1),A{i,1}(1,3)]);mean([A{i,1}(2,1),-A{i,1}(1,2)])]; %Based on eqution in BOYD 1998, and wikipedia article here: https://en.wikipedia.org/wiki/Angular_velocity
    omega(i,1)=sqrt(W{i,1}'*W{i,1});%note this is just an alternative way to calculate norm(W{i,1},2), just using this notation to match Woltring et all 1994 equation 29
end
    
%Using woltring et al 1994, calculate the IHA (instant helical axis)
%direction (n) and a point on the IHA (s).
for i=1:length(W)
    n_{i,1}=W{i,1}/omega(i,1); %unit vector direction of the IHA
    s{i,1}=p{i,1}+cross(n_{i,1},dpdt{i,1})/omega(i,1); %point on the IHA (a.k.a the position of the IHA in the femoral reference frame)
end
    
%% Calculation of the moment arms 

for i = 1:length(PTinsP)-1

    % MAGNITUDE OF MOMENT ARM USING PANDY 1999 Eq 2
    % calculate unit force vector
    FMhat{i,1} = (PTinsP{i,1}-PTinsT{i,1})/norm(PTinsP{i,1}-PTinsT{i,1},2);
    % Calculate unit omega vectors
    AwBhat{i,1} = W{i,1}/norm(W{i,1},2); 
    ISAtoPT{i,1}=(PTinsP{i,1}-s{i,1});
    rPT{i,1} = dot(AwBhat{i,1},cross(ISAtoPT{i,1},FMhat{i,1}));
    MA{i,1} = norm(rPT{i,1},2);
    
    %NOTE both method of Pandy above, and Boyd below return the same result
    %(for non-noise data)
    
    %MAGNITUDE MOMENT ARM USING BOYD 1998 and Woltring 1994
    loa{i,1}=(PTinsP{i,1}-PTinsT{i,1});
    point1{i,1}=s{i,1}+n_{i,1}*1; %p=rho+omega*alpha, where alpha is a scalar.  s and n comes from Woltring notation, Boyd notation is rho and omega
    point2{i,1}=s{i,1}+n_{i,1}*100;
    iha{i,1}=point1{i,1}-point2{i,1};
    vtv{i,1}=s{i,1}-PTinsP{i,1};
    MA2{i,1}=norm(dot(cross(loa{i,1},iha{i,1}),vtv{i,1}),2)/norm(cross(loa{i,1},iha{i,1}),2);
    
    %MAGNITUDE MOMENT ARM USING BOYD 1998 and SARA results
    loaSARA{i,1}=(PTinsP{i,1}-PTinsT{i,1});
    point1SARA{i,1}=pSARA{i,1}+dSARA{i,1}*1; %p=rho+omega*alpha, where alpha is a scalar, Boyd notation
    point2SARA{i,1}=pSARA{i,1}+dSARA{i,1}*100;
    SARA{i,1}=point1SARA{i,1}-point2SARA{i,1};
    vtvSARA{i,1}=pSARA{i,1}-PTinsP{i,1};
    MASARA{i,1}=norm(dot(cross(loaSARA{i,1},SARA{i,1}),vtvSARA{i,1}),2)/norm(cross(loaSARA{i,1},SARA{i,1}),2);
            
end

MA = cell2mat(MA); 
MA2 = cell2mat(MA2); 
MASARA = cell2mat(MASARA);  %All three methods should return the same result when the noise is low


%MA calculates based on velocity, differential or between two reference frame poses, so results in matrix that is one small than original data set (as needs to points to calc each point, thus truncate other matricies by one)
Varus = Varus(1:end-1); 
ExtRotation = ExtRotation(1:end-1); 
Flexion = Flexion(1:end-1); 
AntPostGSO = AntPostGSO(1:end-1);
LatMedGSO = LatMedGSO(1:end-1);
DistCompGSO = DistCompGSO(1:end-1);

filterON=false;

if filterON 
    
    %first truncate data based on anuglar velocity
    cutOff=30;%degrees per second, set to zero for no cut off angular velocity
    cutOff=cutOff/180*pi;%degrees to radians

    Flexion=Flexion(omega(1:end-1)>cutOff);
    Varus=Varus(omega(1:end-1)>cutOff);
    ExtRotation=ExtRotation(omega(1:end-1)>cutOff);
    AntPost=AntPost(omega(1:end-1)>cutOff);
    MA=MA(omega(1:end-1)>cutOff);
    
    % Filter by applying a low pass filter (lets low frequency singles through, filters out higher frequency)
    Fs = freq; % Sampling Frequency (Hz).  The rate at which you are collecting the data.
    Fc = 1; % Cut-off frequency (Hz, i.e. let through signals with frequency lower than this value)
    Order = 1; % order of filter applied
    [b a] = butter(Order,Fc/(Fs/2),'low'); % Design the filter
    MA=filtfilt(b,a,MA);
    
end 

%%% End of moment arm calculation

%% Plots 

figure
subplot(3,2,1)
plot(Flexion)
ylabel('Flexion')
subplot(3,2,3)
plot(ExtRotation)
ylabel('Tibial External Rotation')
subplot(3,2,5)
plot(Varus)
ylabel('Tibial Varus')
subplot(3,2,2)
plot(LatMed)
ylabel('Lateral Translation')
subplot(3,2,4)
plot(AntPost)
ylabel('Anterior Translation')
subplot(3,2,6)
plot(DistComp)
ylabel('Distraction')
% ylim([0 30])

figure
subplot(3,2,1)
plot(LatMed)
ylabel('Lateral Translation')
subplot(3,2,3)
plot(AntPost)
ylabel('Anterior Translation')
subplot(3,2,5)
plot(DistComp)
ylabel('Distraction')
subplot(3,2,2)
plot(LatMedGSO)
ylabel('Lateral GS Origin')
subplot(3,2,4)
plot(AntPostGSO)
ylabel('Anterior GS Origin')
subplot(3,2,6)
plot(DistCompGSO)
ylabel('Distraction GS Origin')
% ylim([0 30])

figure
hold on
plot(Flexion,'b')
plot(MA,'r')
plot(MA2,'g')
plot(MASARA,'k')
ylim([0 120])
hold off
% 
figure
hold on
plot(Flexion,MA,'r')
plot(Flexion,MA2,'g')
plot(Flexion,MASARA,'k')
% plot(MA,'r')
ylim([0 80])
hold off

%% split peaks code
% 
% results=[Flexion,Varus,ExtRotation,AntPost,MA];
% [pks, locs] = findpeaks(Flexion);
% startP = 1;
% for i = 1:length(locs)
%     endP = locs(i);
%     if endP-startP>10%discards short collections of data, note move line startP = endP + 1 into the if statement to not discard the data, but add it in to the next big peaks worth of data
%         splitResults{i,1} = results(startP:endP, :);
%     end
%     startP = endP + 1;
% end
