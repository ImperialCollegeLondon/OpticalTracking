function result = stray_motion(stray, femur, right)
    if isempty(stray)
        result = table('Size', [0 6], 'VariableTypes', repmat("double", 1, 6), 'VariableNames', ...
        {'flexion', 'varus', 'external', 'lateral', 'anterior', 'superior'});
        return;
    end

    result = table();

    n_data = size(stray.i, 2);
    if size(femur.i, 2) ~= n_data
        femur.i = repmat(femur.i', n_data, 1)';
        femur.j = repmat(femur.j', n_data, 1)';
        femur.k = repmat(femur.k', n_data, 1)';
    end

    if size(stray.i, 2) ~= n_data
        stray.i = repmat(stray.i', n_data, 1)';
        stray.j = repmat(stray.j', n_data, 1)';
        stray.k = repmat(stray.k', n_data, 1)';
    end


    e1_=femur.i;%Femoral X axis in global reference frame, Grood and Suntay definition
    e3_=stray.k;%Tibial z axis in global reference frame, Grood and Suntay definition
    e2_=ucross(e3_,e1_);%Floating axis in global reference frame, Grood and Suntay definition

    flexion = asind(dot(-e2_,femur.k));
    beta = acosd(dot(femur.i,stray.k));
    if right
        external = asind(dot(-e2_,stray.i));
        varus = 90-beta;
    else
        external = asind(dot(e2_,stray.i));
        varus = -(90-beta);
    end

    %     H_=tibiaOrigin-femurOrigin;
    H_ = stray.origin(1:3, :) - femur.origin(1:3, :);%translation vector of from femoral origin to tibial origin (in global coordinate frame)
    if right
        lateral = dot(H_,e1_);%projected onto the medial lateral axis e1
    else
        lateral = dot(H_,-e1_);
    end
    anterior = dot(H_,e2_);%projected onto the anterior posterior axis e2
    distal = -dot(H_,e3_);%projected onto the compression distraction axis e3, minus sign to make distraction +ve

    result.flexion = flexion';
    result.varus = varus';
    result.external = external';
    result.lateral = lateral';
    result.anterior = anterior';
    result.superior = distal';
end