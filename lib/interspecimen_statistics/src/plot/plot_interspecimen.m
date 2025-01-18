function plot_interspecimen(config, stats, stats_offset, states, truncate_min, truncate_max)
    intact_name = config.intact_name;


    tibiofemoral = setdiff(fieldnames(stats.(intact_name)), "name");

    loading_conditions = {stats.(intact_name).name};
    states_without_intact = setdiff(states, intact_name);

    for i = 1:numel(tibiofemoral)
        n_loading = numel([stats.(intact_name).(tibiofemoral{i})]);
        intact = stats.(intact_name).(tibiofemoral{i});

        for lc = 1:n_loading % Loading conditions
            if all(ismissing(intact.mean), "all")
                continue
            end


            neutral = offset_from_intact(intact, intact, @(x) x);

            figure(lc)
            tiledlayout(2,3); hold on;
            plot_labels();
            sgt = sgtitle(["Tibial motion relative to femur" loading_conditions{lc}]);
            sgt.Interpreter = "latex";
            sgt.FontSize = 20;
            plot_shade(neutral.mean, neutral.ci, truncate_min, truncate_max);
            for s = 1:numel(states_without_intact) % Knee states
                state = states_without_intact{s};
                if strcmp(state, intact_name)
                    continue
                end
                datum = stats_offset.(state)(lc);

                % Find change relative to neutral
                plot_lines(datum.(tibiofemoral{i}).mean, datum.(tibiofemoral{i}).ci, truncate_min, truncate_max);

                % diff_from_intact = offset_from_intact(datum.tibiofemoral, intact_tf, config.interspecimen_smoothing);

                % Find stdev change
                % plot_bars(datum.(tibiofemoral{i}).mean, datum.(tibiofemoral{i}).ci, truncate_min, truncate_max);
                % plot_lines(diff_from_intact.mean, diff_from_intact.ci, truncate_min, truncate_max);
            end
            states_for_legend = replace(states_without_intact, '_', ' ');
            legends = 'Intact 95\% CI';
            if ~isempty(states_for_legend)
                legends = [legends; replace(states_without_intact, '_', ' ')];
            end
            lg = legend(legends, Interpreter="latex");
            lg.FontSize = 14;

        end
    end
end

function R = offset_from_intact(datum, intact, fn_smooth)
R = datum;
h = min(height(intact.mean), height(datum.mean));

% This is so stupid. find where the difference in heights is coming from.
R.mean = R.mean(1:h, :);
R.std = R.std(1:h, :);
R.ci.mean.lower = R.ci.mean.lower(1:h, :);
R.ci.mean.upper = R.ci.mean.upper(1:h, :);
R.ci.std.lower = R.ci.std.lower(1:h, :);
R.ci.std.upper = R.ci.std.upper(1:h, :);

intact.mean = intact.mean(1:h, :);
intact.std = intact.std(1:h, :);
intact.ci.mean.lower = intact.ci.mean.lower(1:h, :);
intact.ci.mean.upper = intact.ci.mean.upper(1:h, :);
intact.ci.std.lower = intact.ci.std.lower(1:h, :);
intact.ci.std.upper = intact.ci.std.upper(1:h, :);

R.mean = fn_smooth(R.mean - intact.mean);
R.mean.flexion = datum.mean.flexion(1:h, :);

R.ci.mean.upper = datum.ci.mean.upper - intact.mean;
R.ci.mean.lower = datum.ci.mean.lower - intact.mean;
end
