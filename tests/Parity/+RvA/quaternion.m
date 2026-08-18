function [R]= quaternion(Qs)

% taken from experimental methods in orthopaedic biomechanics

q0 = Qs(1);
qx = Qs(2);
qy = Qs(3);
qz = Qs(4);

R11 = 1-2*(qy^2)-2*(qz^2);
R12 = 2*qx*qy + 2*q0*qz;
R13 = 2*qx*qz - 2*q0*qy;
R21 = 2*qx*qy - 2*q0*qz;
R22 = 1 - 2*(qx^2)-2*(qz^2);
R23 = 2*qy*qz + 2*q0*qx;
R31 = 2*qx*qz + 2*q0*qy;
R32 = 2*qy*qz - 2*q0*qx;
R33 = 1-2*(qx^2)-2*(qy^2);

R = [R11 R12 R13; R21 R22 R23; R31 R32 R33];

end
