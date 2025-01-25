function fig = plot_raw(data, config, idx_interpol)
    figure(1); hold off;
    loading_conditions = {data.name};
    for lc = 1:numel(loading_conditions)
        tibiofemoral = setdiff(fieldnames(data), "name");
        config.loading_condition = loading_conditions{lc};
        for tf = 1:numel(tibiofemoral)
            if isempty(data(lc).(tibiofemoral(tf)))
                continue
            end
            datum = data(lc).(tibiofemoral(tf));
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
                ylabel(headers{h});
                % Plot the interpolation
                if isempty(idx_interpol)
                    % Called from calculate_kinematics(). Means there's
                    % insufficient data
                    continue;
                end
                interpolated_points = idx_interpol{lc, tf}(:,h);

                if any(interpolated_points)
                    hold on;
                    scatter(find(interpolated_points), p(interpolated_points), 10, "filled", "red")
                    hold off;
                end
               
            end

            sgtitle([[config.specimen_name ' ' replace(config.state, '_', ' ') ' ' config.loading_condition] tibiofemoral(tf)]);
            sgt.Interpreter = "latex";

            if isempty(idx_interpol) % Print problematic data
                filename = strjoin(fig.Title.String, '_');
                saveas(fig, fullfile(config.path_missing_data, [filename '.png']))
            end


            if config.enable_raw_plot
                keyboard
            end
        end
    end

end