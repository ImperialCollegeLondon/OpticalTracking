function print_mean_std_to_file(stats, states, root)
    tibiofemoral = setdiff(fieldnames([stats.(states{1})]), "name");
    
    for i = 1:numel(tibiofemoral)
    results{i} = fullfile(root, "Results", tibiofemoral{i});
    mkdir(results{i});
    end

    for s = 1:numel(states)
        state = states{s};
        datum = stats.(state);
        for lc = 1:numel(datum)
            for i = 1:numel(tibiofemoral)
                loading_condition = datum(lc).name;
                mkdir(fullfile(results{i}, loading_condition));

                % Save tibiofemoral data separated by Loading Condition/knee state
                % e.g. ./Anterior drawer/ACL_cut.csv
                [avg, stdev] = get_and_name_tables(datum(lc).(tibiofemoral{i}));
                filepath = fullfile(results{i}, loading_condition);
                writetable(avg, fullfile(filepath, [state '.csv']) )
                writetable(stdev, fullfile(filepath, [state '_std' '.csv']) )
            end
        end
    end
end

function [avg, stdev] = get_and_name_tables(datum)
    ci_mean_low = datum.ci.mean.lower;
    ci_mean_low.Properties.VariableNames = "ci_lower_" + ci_mean_low.Properties.VariableNames;
    ci_mean_up = datum.ci.mean.upper;
    ci_mean_up.Properties.VariableNames = "ci_upper_" + ci_mean_up.Properties.VariableNames;
    avg = [datum.mean ci_mean_low ci_mean_up];

    ci_std_low = datum.ci.std.lower;
    ci_std_low.Properties.VariableNames = "ci_lower_" + ci_std_low.Properties.VariableNames;
    ci_std_up = datum.ci.std.upper;
    ci_std_up.Properties.VariableNames = "ci_upper_" + ci_std_up.Properties.VariableNames;
    stdev = [datum.std ci_std_low ci_std_up];
end
