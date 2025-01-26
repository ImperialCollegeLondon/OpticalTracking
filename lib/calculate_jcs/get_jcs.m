function [data, transforms] = get_jcs(data_raw, trackers, config)
    if isempty(data_raw)
        data = [];
        transforms = [];
        return
    end
    
    landmarks = new_landmark(data_raw, config);
    
    %% Apply the tracker transforms to the data
    for i = 1:numel(data_raw)
        loading_condition = landmarks(i).name;
        input.name = loading_condition;
        config.loading_condition = loading_condition;
        % Assign the tracker to the right bone based on their labels
        % defined in `defaults`
        if config.is_polaris
            label = config.polaris;
        else
            label = config.certus;
        end


        input.tibia = landmarks(i).probes.and_then(@(x) x.with_label(label.tibia));
        input.femur = landmarks(i).probes.and_then(@(x) x.with_label(label.femur));
        input.patella = landmarks(i).probes.and_then(@(x) x.with_label(label.patella));
        if (input.femur.is_none() && input.tibia.is_none()) || (input.femur.is_none() && input.patella.is_none())
            continue
        end
        [data(i), transforms(i)] = calculate_joint_kinematics(input, trackers, config);
        
    end
    mask = cellfun(@isempty, {data.name});
    data(mask) = [];
    transforms(mask) = [];
    [transforms.name] = deal(data.name);
end