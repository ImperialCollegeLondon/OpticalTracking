function [ gTb0T, originT, APAxisT_,PDAxisT_,MLAxisT_ ] = defineBodyFixedFrameTibia(x1,x2,x3)
%planesToAxis Takes points that describe the sagittal and coronal planes and returns
%directions cosines that describe the x,y and z axis according to the
%definition of Grood and Suntay 1983 - adapted from RvA code (defineBodyFixedFrameF) by KA 21/06/17

%my notation, _ implies it is a vector e.g. xa_ is the direction vector of
%the xaxis

%http://www.electromagnetics.biz/DirectionCosines.htm
angle = @(u_,v_) acosd(dot(u_,v_)/(norm(u_,2)*norm(v_,2))); %define a function to calculate the angle between two vectors
ucross=@(u_,v_) cross(u_,v_)/norm(cross(u_,v_),2); %define function to find unit cross product
uvector=@(a,b) (a-b)/norm(a-b,2); %define a function to find a unit vector between two points

%%% KA 21/06
originT = (x1+x2)/2;
PDAxisT_= uvector(originT,x3); % Y-Axis (Z-axis in JCS) passes through centre of ankle (distal rod point) and origin, directed proximally
PDAxisT_=PDAxisT_';

% if sign(ya_(1))==1
%     PDAxisT_=-PDAxisT_;
% end

tibialml = uvector(x1,x2);%LEFT KNEE
% tibialml = uvector(x2,x1);%RIGHT KNEE
APAxisT_ = ucross(PDAxisT_,tibialml); % X- Axis(Y-axis in JCS) is X-product of y-axis and line between tibial eminences, directed anteriorly
APAxisT_=APAxisT_';

% if sign(xa_(1))==1
%     APAxisT_=-APAxisT_;
% end

angle(PDAxisT_,APAxisT_); % to check it is 90 degrees

MLAxisT_=ucross(APAxisT_,PDAxisT_); % Z-axis (X-axis in JCS) is X-product of x and y axes, directed to the right (MEDIALLY in a left knee) 



rot=[APAxisT_,PDAxisT_,MLAxisT_];
% rot=[MLAxisT_,APAxisT_,PDAxisT_];

rot=[rot,[0 0 0]';0 0 0 1];


trans=[1 0 0 originT(1);
       0 1 0 originT(2);
       0 0 1 originT(3)
       0 0 0 1];

% trans=eye(4);   
   
gTb0T=trans*rot;
% angle(APAxisT_,PDAxisT_)
% angle(APAxisT_,MLAxisT_)
% angle(PDAxisT_,MLAxisT_)

end
