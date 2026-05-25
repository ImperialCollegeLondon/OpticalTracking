function [ gTb0F, originF, APAxisF_,PDAxisF_,MLAxisF_ ] = defineBodyFixedFrameFemur(med,lat,prox,right)
%defines a body fixed frame for the femur.  The coordinate system uses the

%my notation, _ implies it is a vector e.g. xa_ is the direction vector of
%the x-axis

angle = @(u_,v_) acosd(dot(u_,v_)/(norm(u_,2)*norm(v_,2))); %define a function to calculate the angle between two vectors
ucross=@(u_,v_) cross(u_,v_)/norm(cross(u_,v_),2); %define function to find unit cross product
uvector=@(a,b) (b-a)/norm(b-a,2); %define a function to find a unit vector from a to b

%X, Y and Z notation of grood and suntay 1983, however the body frame is
%one decided upon by RvA for a particular experiment in Nov 2018 rather
%than the body frame defined by Grood and Sunray (as the points necessary
%to contructs G&S body frame such as the femoral head centre were not
%available)

%X = Medial lateral = epicondylar axis, positive to the right, thus is
%orientated laterally in right knee, and medially in the left knee
%Y = Anterior posterior, anterior is positive
%Z = Proximal Distal, proximal is positive
%I,J,K correspond to unit base vectors in the X, Y and Z direactions

originF = (med+lat)/2;
if right
    I_ = uvector(med,lat)'; %RIGHT KNEE, X Axis
else
    I_ = uvector(lat,med)'; %LEFT KNEE, X Axis
end

tempK_= uvector(originF,prox)'; %the proximal point is approximate and thus this axis is not necessarily perpendicular to epicondylar axis
J_ = ucross(tempK_,I_); % Y-axis


MLAxisF_=I_;
% MLAxisF_=ucross(APAxisF_,PDAxisF_); % Z-axis (X-axis in JCS) is X-product of x and y axes, directed to the right (MEDIALLY in a left knee) 
PDAxisF_=ucross(MLAxisF_,APAxisF_);


rot=[APAxisF_,PDAxisF_,MLAxisF_];
% rot=[MLAxisF_,APAxisF_,PDAxisF_];
rot=[rot,[0 0 0]';0 0 0 1];


trans=[1 0 0 originF(1);
       0 1 0 originF(2);
       0 0 1 originF(3)
       0 0 0 1];

% trans=eye(4);   
   
gTb0F=trans*rot;
% angle(APAxisF_,PDAxisF_)
% angle(APAxisF_,MLAxisF_)
% angle(PDAxisF_,MLAxisF_)

end
