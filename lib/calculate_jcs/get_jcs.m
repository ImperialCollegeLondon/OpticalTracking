function [data, transforms] = get_jcs(trackers, tracker_transforms, config)
    if isempty(trackers)
        data = [];
        transforms = [];
        return
    end
    
    %% Apply the tracker transforms to the data
    loading_conditions = unique({trackers.Name});
    for i = 1:numel(loading_conditions)
        loading_condition = loading_condition{i};
        input.name = loading_condition;
        config.specimen.loading_condition = loading_condition;

        label = trackers.camera().get_possible_labels(config.camera_labels);

        input.tibia = trackers(i).with_label(label.tibia);
        input.femur = trackers(i).with_label(label.femur);
        input.patella = trackers(i).with_label(label.patella);
        if (input.femur.is_none() && input.tibia.is_none()) || (input.femur.is_none() && input.patella.is_none())
            continue
        end
        [data(i), transforms(i)] = calculate_joint_kinematics(input, tracker_transforms, config);
        
    end
    mask = cellfun(@isempty, {data.name});
    data(mask) = [];
    transforms(mask) = [];
    [transforms.name] = deal(data.name);
end
