function [output, transforms] = generate_intraspecimen_jcs(data_raw, trackers, config)
    if isempty(data_raw)
        output = [];
        transforms = [];
        return
    end
    
    average_runs = config.average_runs;
    split_flex_ext = config.split_flex_ext;

    %% Organise the raw data into the expected struct. Probably should be implemented as a class instead.
    data_all_probes = organise_data(data_raw, config);
    
    %% Apply the tracker transforms to the data
    % transforms(length(data_all_probes)) = struct('tibia', [], 'femur', [], 'patella', []);
    % transforms(length(data_all_probes)) = struct('in_global', [], 'in_femur', []);
    % data(length(data_all_probes)) = struct('name', '', 'tibiofemoral', [], 'patellofemoral', []);
    for i = 1:numel(data_raw)
        loading_condition = data_all_probes(i).name;
        input.name = loading_condition;
        % Assign the tracker to the right bone.
        input.tibia = extract_from_label(data_all_probes(i).probes, config.label.tibia);
        input.femur = extract_from_label(data_all_probes(i).probes, config.label.femur);
        input.patella = extract_from_label(data_all_probes(i).probes, config.label.patella);
    
        [data(i), transforms(i)] = calculate_joint_kinematics(input, trackers, config);

        if ~config.average_runs && split_flex_ext
            error("separation of flex/ext without averaging is not yet implemented.")
        end

        if ~config.average_runs
            output(i) = data(i);
            tibiofemoral = setdiff(fieldnames(data(i)), "name");
            for j = 1:numel(tibiofemoral)
                output(i).(tibiofemoral{j}) = post_process(data(i).(tibiofemoral{j}));
            end
        end

        if config.average_runs
            output(i).name = replace(input.name, '_', ' ');
            tibiofemoral = setdiff(fieldnames(data(i)), "name");

            for j=1:numel(tibiofemoral)
                headers = data(i).(tibiofemoral{j}).Properties.VariableNames;
                if config.debug
                    fprintf("  %s: %s\n", loading_condition, tibiofemoral{j})
                end
                data_tf = intraspecimen_mean(data(i).(tibiofemoral{j}), config);
                output(i).(tibiofemoral{j}) =  post_process(data_tf, config, headers);
            end
        end
    end
    [transforms.name] = deal(data.name);
end

function R = post_process(data, config, headers)
% POST_PROCESS   Takes a smoothing function `fn_smooth` and a function to
% shift flexion angles `fn_shift_flexion`.
    if isempty(data)
        R = array2table(data, "VariableNames", headers);
        return;
    end
    R = data;
    R(any(R==0, 2),:) = NaN;
    R = config.fill_missing_quantisation(R);
    if config.split_flex_ext
        R.extension =  config.intraspecimen_smoothing(R.extension);
        R.extension.flexion = config.shift_flex([R.extension.flexion]);
    
        R.flexion =  config.intraspecimen_smoothing(R.flexion);
        R.flexion.flexion = config.shift_flex([R.flexion.flexion]);
    else
        R = config.intraspecimen_smoothing(R);
        R(:,1) = config.shift_flex(R(:,1));
    end
    R = array2table(R, "VariableNames", headers);
end
