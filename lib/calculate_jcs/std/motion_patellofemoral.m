function result = motion_patellofemoral(relative_position, femur, patella, right)
result = table();
if isempty(relative_position)
    var_type = {'int8', 'int8', 'int8', 'int8', 'int8', 'int8'};
    result = table('Size', [0 6], 'VariableTypes', var_type, 'VariableNames', {'flexion', 'medial_rotation', 'lateral_tilt', 'medial_shift', 'anterior', 'superior'});
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

pH_ = [patella.origin(1:3,:) - femur.origin(1:3,:)];%translation vector of from femoral origin to tibial origin (in global coordinate frame)
if right
    lateral=dot(pH_,e1_);%projected onto the medial lateral axis e1
else
    lateral=dot(pH_,-e1_);
end
anterior=dot(pH_,pe2_);%projected onto the anterior posterior axis e2
superior=-dot(pH_,pe3_);%projected onto the compression distraction axis e3, minus sign to make distraction +ve

result.flexion = angles(:,1);
result.medial_rotation = varus'; % Equivalent to varus
result.lateral_tilt = external'; % Equivalent to external
result.medial_shift = lateral'; % Equivalent to lateral
result.anterior = anterior';
result.superior = superior';
end

