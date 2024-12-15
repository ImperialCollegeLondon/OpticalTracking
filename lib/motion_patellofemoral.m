function result = motion_patellofemoral(relative_position, femur, patella, right)
if isempty(relative_position)
result.flexion = [];
result.medial_rotation = []; % Equivalent to varus
result.lateral_tilt = []; % Equivalent to external
result.medial_shift = []; % Equivalent to lateral
result.anterior = [];
result.superior = [];
    return;
end
e1_=femur.i;%Femoral X axis in global reference frame, Grood and Suntay definition
pe3_=patella.k;
pe2_=ucross(pe3_,e1_);
fTp = relative_position;

[angles, ~] = rotationsAndTranslations(fTp, right);
%                         Flexion(i,1)=asind(-dot(e2_,K_));
%                     Flexion(i,1)=acosd(dot(J_,e2_));
beta = acosd(dot(femur.i,patella.k));
if right
    external = asind(dot(-pe2_,patella.i));
    %                         ExtRotation(i,1)=acosd(dot(j_,e2_));
    varus=90-beta;
else
    external=asind(dot(pe2_,patella.i));
    %                         ExtRotation=acosd(dot(j_,e2_));
    varus=-(90-beta);
end

pH_ = [patella.point(1:3)-femur.point(1:3)]';%translation vector of from femoral origin to tibial origin (in global coordinate frame)
if right
    lateral=dot(pH_,e1_);%projected onto the medial lateral axis e1
else
    lateral=dot(pH_,-e1_);
end
anterior=dot(pH_,pe2_);%projected onto the anterior posterior axis e2
superior=-dot(pH_,pe3_);%projected onto the compression distraction axis e3, minus sign to make distraction +ve

result.flexion = angles(1);
result.medial_rotation = varus; % Equivalent to varus
result.lateral_tilt = external; % Equivalent to external
result.medial_shift = lateral; % Equivalent to lateral
result.anterior = anterior;
result.superior = superior;
end
