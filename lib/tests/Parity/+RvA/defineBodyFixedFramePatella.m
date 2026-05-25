% defineBodyFixedFramePatella is a function adapted from RvA's and KA's
% code which is analagous to defineBodyFixedFrameFemur and
% defineBodyFixedFrameTibia. Daryl 30/7/2018

function [ gTb0P, originP, APAxisP_,PDAxisP_,MLAxisP_ ] = defineBodyFixedFramePatella(med,lat,dist,right)

%http://www.electromagnetics.biz/DirectionCosines.htm
angle = @(u_,v_) acosd(dot(u_,v_)/(norm(u_3,2)*norm(v_,2))); %define a function to calculate the angle between two vectors
ucross=@(u_,v_) cross(u_,v_)/norm(cross(u_,v_),2); %define function to find unit cross product
uvector=@(a,b) (a-b)/norm(a-b,2); %define a function to find a unit vector between two points

%%% In this function, the origin of the patella is taken to be the
%%% insertion point of the patellar tendon on the patella

originP = x3; % origin taken to be the distal digitised point on the patella
PDAxisP_ = uvector(originP, (x1+x2)/2 ); % points used to define the PD axis are the distal point and the midpoint of the medial and lateral
PDAxisP_ = PDAxisP_';

patellarml = uvector(x1,x2); % left knee
APAxisP_ = ucross(PDAxisP_,patellarml);
APAxisP_ = APAxisP_';

MLAxisP_=ucross(APAxisP_,PDAxisP_);


rot=[APAxisP_,PDAxisP_,MLAxisP_];
% rot=[MLAxisP_,APAxisP_,PDAxisP_];

rot=[rot,[0 0 0]';0 0 0 1];


trans=[1 0 0 originP(1);
       0 1 0 originP(2);
       0 0 1 originP(3)
       0 0 0 1];

% trans=eye(4);   
   
gTb0P=trans*rot;
% angle(APAxisT_,PDAxisT_)
% angle(APAxisT_,MLAxisT_)
% angle(PDAxisT_,MLAxisT_)

end
