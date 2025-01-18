function O = interpolate(specimen, config)
    knee_states = setdiff(fieldnames(specimen), "name");
    flexion_arc = get_flexion_arc();

    for st = 1:numel(knee_states)
        knee_state = specimen.(knee_states{st});
        if isempty(knee_state)
            return
        end
        tibiofemoral = setdiff(fieldnames(knee_state), "name");
        loading_conditions = unique({knee_state.name});

        for c = 1:numel(loading_conditions)
            condition_mask = strcmpi({specimen.(knee_states{st}).name}, loading_conditions{c});
            loading_condition = knee_state(condition_mask);
            new_lc.name = loading_condition.name;
            for i = 1:numel(tibiofemoral)
                if numel({loading_condition.(tibiofemoral{i})}) > 1
                    new_lc.(tibiofemoral{i}) = interpol_multi({loading_condition.(tibiofemoral{i})}, flexion_arc, config.interpolation_algorithm);
                else
                    new_lc.(tibiofemoral{i}) = interpol(loading_condition.(tibiofemoral{i}), flexion_arc, config.interpolation_algorithm);
                end
            end
            O.(knee_states{st})(find(condition_mask, 1)) = new_lc;
        end
        empty_states = cellfun( @isempty, {O.(knee_states{st}).name});
        O.(knee_states{st})(empty_states) = [];
    end
    
    function flexion_arc = get_flexion_arc() % Nested to make reading easier
        quantise = @(x) round(x / config.step_size) * config.step_size;
        for stt = 1:numel(knee_states)
            knee_state = specimen.(knee_states{stt});
            if ~isempty(knee_state)
                loading_conditions = unique({knee_state.name});
                tibiofemoral = setdiff(fieldnames(knee_state), "name");
                for cc = 1:numel(loading_conditions)
                    for ii = 1:numel(tibiofemoral)
                        loading_condition = knee_state(strcmpi({knee_state.name}, loading_conditions{cc}));
                        for lc = 1:numel(loading_condition)
                            if isempty([loading_condition(lc).(tibiofemoral{ii})])
                                tf_flex_all{cc+lc-1,ii} = [];
                            else
                                tf_flex = arrayfun(@(x) x.(tibiofemoral{ii}).flexion, loading_condition, 'UniformOutput', false);
                                tf_flex_all{cc+lc-1,ii} = vertcat(tf_flex{:});
                            end
                        end
                    end
                end

                tf_flex_all = tf_flex_all(~cellfun(@isempty, tf_flex_all));
                max_angle = quantise(cellfun(@max, tf_flex_all));
                min_angle = quantise(cellfun(@min, tf_flex_all));

                flex_common{stt} = max(min_angle):config.step_size:min(max_angle);
            end
        end

        flex_common = flex_common(~cellfun(@isempty, flex_common));
        [~, largest_common_range] = min(cellfun(@numel, flex_common));
        flexion_arc = flex_common{largest_common_range};
    end
end

function new_lc = interpol(loading_condition, flex_arc, interpolation_algorithm)
    if isempty(loading_condition)
        new_lc = loading_condition;
        return
    end
    tf = interpolation_algorithm(loading_condition.flexion, table2array(loading_condition), flex_arc);
    new_lc = array2table(tf, "VariableNames", loading_condition.Properties.VariableNames);
end

function new_lc = interpol_multi(loading_condition, flex_arc, interpolation_algorithm)
    if all(cellfun(@isempty, loading_condition))
        new_lc = array2table(loading_condition{1}, "VariableNames", loading_condition{1}.Properties.VariableNames);
        return
    end

    for j = 1:numel(loading_condition)
        if ~isempty(loading_condition{j})
            lc_tf = table2array(loading_condition{j});
            tf_group(:,:,j) = interpolation_algorithm(loading_condition{j}.flexion, lc_tf, flex_arc);
        end
    end
    tf = squeeze(mean(tf_group, 3));
    new_lc = array2table(tf, "VariableNames", loading_condition{1}.Properties.VariableNames);
end
