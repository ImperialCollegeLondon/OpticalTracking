function output = intraspecimen_postprocess(data, config)
    for lc = 1:numel(data)
        if ~config.average_runs && config.split_flex_ext
            error("separation of flex/ext without averaging is not yet implemented.")
        end
        
        if ~config.average_runs
            output(lc) = data(lc);
            tibiofemoral = setdiff(fieldnames(data(lc)), "name");
            for j = 1:numel(tibiofemoral)
                output(lc).(tibiofemoral{j}) = post_process(data(lc).(tibiofemoral{j}));
            end
        end
        
        if config.average_runs
            output(lc).name = replace(data(lc).name, '_', ' ');
            tibiofemoral = setdiff(fieldnames(data(lc)), "name");
            for j=1:numel(tibiofemoral)
                headers = data(lc).(tibiofemoral{j}).Properties.VariableNames;
                if config.debug
                    loading_condition = data(lc).name;
                    config.loading_condition = loading_condition;
                    fprintf("  %s: %s\n", loading_condition, tibiofemoral{j})
                end
                datum = intraspecimen_mean(data(lc).(tibiofemoral{j}), config);
                output(lc).(tibiofemoral{j}) =  post_process(datum, config, headers);
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
