function [data, transforms] = get_jcs(data_raw, trackers, config)
    if isempty(data_raw)
        data = [];
        transforms = [];
        return
    end
    
    all_probes = organise_data(data_raw, config);
    
    %% Apply the tracker transforms to the data
    for i = 1:numel(data_raw)
        loading_condition = all_probes(i).name;
        input.name = loading_condition;
        config.loading_condition = loading_condition;
        % Assign the tracker to the right bone based on their labels
        % defined in `defaults`
        input.tibia = extract_from_label(all_probes(i).probes, config.label.tibia);
        input.femur = extract_from_label(all_probes(i).probes, config.label.femur);
        input.patella = extract_from_label(all_probes(i).probes, config.label.patella);
    
        [data(i), transforms(i)] = calculate_joint_kinematics(input, trackers, config);
        
    end
    [transforms.name] = deal(data.name);
end