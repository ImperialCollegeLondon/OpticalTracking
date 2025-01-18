function statistics = interspecimen_stats(knee_state, config)
    % Calculate interspecimen statistics. Picks the largest common flexion arc available across loading conditions.

    
    tibiofemoral = setdiff(fieldnames(knee_state(1)), "name"); % Patellofemoral or Tibiofemoral, Kinematics or JCS, etc
    headers = arrayfun(@(c) knee_state(1).(c{1}).Properties.VariableNames, tibiofemoral, 'UniformOutput', false); % Flexion, Varus, External, Superior, Lateral (or variations).
    loading_conditions = unique({knee_state.name}); % Neutral, anterior (drawer), SPS, etc
    flexion_arc = get_flexion_arc();
    
    for lc = 1:numel(loading_conditions)
        condition = knee_state(strcmpi({knee_state.name}, loading_conditions{lc}));
        n_condition = numel(condition);

        statistics(lc).name = loading_conditions{lc};
        
        for i = 1:numel(tibiofemoral)
            data = nan([n_condition length(flexion_arc) 6]);

            for n_specimen = 1:n_condition
                datum = condition(n_specimen).(tibiofemoral{i});
                if ~isempty(datum)
                    data(n_specimen, :, :) = config.interpolation_algorithm(datum.flexion, table2array(datum), flexion_arc); % Shorten the range from the current flexion arc (datum.flexion) to the common flexion arc (flexion_arc)
                end
            end
            % This shape lets us do stdev across all specimens. If you want to see the data:
            % permute(data, [2 3 1]);


            smooth = @(x) config.interspecimen_smoothing(reshape(x, [], 6));
            
            avg = smooth(mean(data, 1, "omitmissing"));
            if size(data, 1) == 1 % There is only one specimen, so stdev = 0
                stdev = smooth(zeros(size(data)));
            else
                stdev = smooth(std(data, 0, "omitmissing"));
            end
            statistics(lc).(tibiofemoral{i}).mean = array2table(avg, "VariableNames", headers{i});
            statistics(lc).(tibiofemoral{i}).std = array2table(stdev, "VariableNames", headers{i});
            statistics(lc).(tibiofemoral{i}).ci  = confidence_interval(statistics(lc).(tibiofemoral{i}));
        end
    end    

    %% Nested function to make reading easier
    function flexion_arc = get_flexion_arc
        quantise = @(x) round(x / config.step_size) * config.step_size;
        for c = 1:numel(loading_conditions)
            condition = knee_state(strcmpi({knee_state.name}, loading_conditions{c}));
            for ii = 1:numel(tibiofemoral)
                flex_arc = arrayfun(@(x) x.(tibiofemoral{ii}).flexion, condition, 'UniformOutput', false);
                flex_arc = flex_arc(~cellfun(@isempty, flex_arc));
                flex_arc_all{c,ii} = vertcat(flex_arc{:});
                % tf_flex_all{c,i} = vertcat(tf_flex{:});
            end
        end


        flex_arc_all = flex_arc_all( ~cellfun(@isempty, flex_arc_all) );
        max_angle = quantise(cellfun(@max, flex_arc_all));
        min_angle = quantise(cellfun(@min, flex_arc_all));

        flexion_arc = max(min_angle):config.step_size:min(max_angle);
        % flexion_arc = min(min_angle):config.step_size:max(max_angle);
    end
end

