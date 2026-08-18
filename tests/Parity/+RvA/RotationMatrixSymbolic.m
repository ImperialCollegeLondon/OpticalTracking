%% For method validation, it can be useful to show the ideal rotation matrix
% as defined in Capozzo et al 2005

syms Rx Ry Rz

% Qx=[1   0         0
%     0   cos(Rx)  -sin(Rx)
%     0   sin(Rx)  cos(Rx)];
% 
% Qy=[cos(Ry)    0   sin(Ry)
%     0           1   0
%     -sin(Ry)   0   cos(Ry)];
% 
% Qz=[cos(Rz)    -sin(Rz)   0
%     sin(Rz)    cos(Rz)    0
%     0           0           1];

Qx=[1   0         0
    0   cos(Rx)  sin(Rx)
    0   -sin(Rx)  cos(Rx)];

Qy=[cos(Ry)    0   -sin(Ry)
    0           1   0
    sin(Ry)   0   cos(Ry)];

Qz=[cos(Rz)    sin(Rz)   0
    -sin(Rz)    cos(Rz)    0
    0           0           1];

% For the Hip, thinking in terms of how Rotation matrix influences a point,
% Int, Ext moves with the femur, which position depends on the amount of FE and Ab/Ad
% The Abd/Add axis position also varies with hip flexion
% Thefore, need to account for IE first, before its axis moves, then
% account for Ab/Ad before its axis moves, then finally FE thus:
rotationMatrixHip=Qz*Qx*Qy %Qy is internal/external, Qx is abduction/adduction (or varus/valgus at the knee) and Qz is flexion/extension

% Alternatively, when multiplying by a proximal body, pre multiply, and a
% distal body post multiply.  The temporal order of rotations is FE, then
% Ab/Ad, then IE, hence, which is the same as above:
rotationMatrixHip2=((Qz*eye(3))*Qx)*Qy %as written by Cappozzo et al 2005, equation (9)

% For the Knee
% FE occurs about the X axis, VarVal about the y and IE about the z.
% Hence:
rotationMatrixKnee=((Qx*eye(3))*Qy)*Qz
% %check
% rotationMatrixKnee2=Qx*Qy*Qz
%This is the same as in Grood and Suntay 1983, noting that R is the bottom
%right quandrant of 16b, and that the trig definition that sin(Ry)=cos(Ry-90)

RT=simplify(rotationMatrixKnee')


Rx=30.5630;
Ry= 36.1142;
Rz=-21.1694;

RxRyRz=[Rx Ry Rz]

Rx=Rx*pi/180;
Ry=Ry*pi/180;
Rz=Rz*pi/180;

evaluatedForRxRyRz=eval(rotationMatrixHip)