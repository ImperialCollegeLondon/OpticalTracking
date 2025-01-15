function output = intraspecimen_postprocess(data, config)
    for i = 1:numel(data)
        if ~config.average_runs && config.split_flex_ext
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
            output(i).name = replace(data(i).name, '_', ' ');
            tibiofemoral = setdiff(fieldnames(data(i)), "name");
        
            for j=1:numel(tibiofemoral)
                headers = data(i).(tibiofemoral{j}).Properties.VariableNames;
                datum = intraspecimen_mean(data(i).(tibiofemoral{j}), config.step_size, config.split_flex_ext);
                output(i).(tibiofemoral{j}) =  post_process(datum, config, headers);
            end
        end
    end
end

function R = post_process(data, config, headers)
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