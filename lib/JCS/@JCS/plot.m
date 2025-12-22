function fig = plot(self, idx_interpol)
    trajectories = self.trajectories;
    config = self.config;
    figure; hold off;
    specimens = unique(trajectories.specimen);
    states = unique(trajectories.states);
    signals = unique(trajectories.signals);
    loading_conditions = unique([trajectories.LoadingCondition]);
    for sg = 1:numel(signals)
        signal = signals(sg);
        for sp = 1:numel(specimens)
            specimen = specimens(sp);
            is_specimen = specimen == trajectories.specimen;
            for st = 1:numel(states)
                state = states(st);
                is_state = state == trajectories.states;
                for lc = 1:numel(loading_conditions)
                    loading_condition = loading_conditions(lc);
                    is_lc = loading_condition == [trajectories.LoadingCondition];
                    mask = is_specimen & is_state & is_lc;

                    data = trajectories(mask).Data.(signal);
                    repetitions = numel(data);
                    for r = 1:numel(repetitions)
                        if isempty(data)
                            continue
                        end
                        datum = data(r);
                        headers = datum.Properties.VariableNames;
                        fig = tiledlayout(3, 2);
                        for h = 1:numel(headers)
                            % Plot data
                            nexttile(h);
                            header = headers{h};
                            p = datum.(header);
                            if strcmpi(header, "flexion") & config.show_minima
                                find_minima(p, config);
                            else
                                plot(p);
                            end
                            ylabel(replace(headers{h}, '_', ' '));
                            % Plot the interpolation
                            if isempty(idx_interpol)
                                % Called from calculate_kinematics(). Means there's
                                % insufficient data
                                continue;
                            end
                            interpolated_points = idx_interpol{lc, sg}(:,h);

                            if any(interpolated_points)
                                hold on;
                                scatter(find(interpolated_points), p(interpolated_points), 10, "filled", "red")
                                hold off;
                            end
                        end
                    end

                end
            end
        end
    end
    sgtitle([[config.specimen.name ' ' replace(config.specimen.state, '_', ' ') ' ' config.specimen.loading_condition] signals(sg)]);
    sgt.Interpreter = "latex";

    if isempty(idx_interpol) % Print problematic data
        filename = strjoin(fig.Title.String, '_');
        saveas(fig, fullfile(config.path_missing_data, [filename '.png']))
    end
end
