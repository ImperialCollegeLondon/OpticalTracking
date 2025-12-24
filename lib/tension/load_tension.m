function output = load_tension(path, config)
    files = Option(dir(fullfile(path, "*.xlsm")));
    if files.is_none
        output = Option.None();
        return
    end
    files = files.unwrap();

    for f = 1:numel(files)
        % Load data
        filename = fullfile(files(f).folder, files(f).name);
        [~, loading_condition, ~] = fileparts(filename);
        data = readtable(filename, "VariableNamingRule","preserve");
        
        % Get the force and z (flexion)
        new_data = table();
        z = rad2deg(unwrap(deg2rad(data.Z)));
        z(z > 400) = NaN; % Sometimes unwrap thinks it's 2 phases away, so this just removes them.
        z = z - 267;
        new_data.flexion = smoothdata(z, "gaussian", 8); % Fairly low number, but found it to copy the max/min best.
        new_data.force = str2double(erase(data.("Force (N)"), ' N'));
        headers = new_data.Properties.VariableNames;

        % Splits runs
        [split_runs, no_tails] = split_run(new_data.flexion, config, 30);
        split_runs_idx = nonzero_to_one(split_runs); % Don't use logical() because it gives an error on NaN. Don't use ~isnan() because we need to maintain all the time points.
        config.split_flex_ext = true;
        flex_ext = get_split_runs(table2array(new_data), split_runs_idx, no_tails, config);
        config.split_flex_ext = false;

        % Average across runs
        mean_flex = squeeze(mean_nonzero(flex_ext.flexion, 2));
        mean_ext = squeeze(mean_nonzero(flex_ext.extension, 2));

        % Clear the missing quantised values
        mean_flex(all(mean_flex == 0, 2), :) = NaN;
        mean_ext(all(mean_ext == 0, 2), :) = NaN;

        % Fill missing(?)
        mean_ext = fillmissing(mean_ext, "makima");
        mean_flex = fillmissing(mean_flex, "makima");

        % Smooth
        mean_ext = smoothdata(mean_ext, "gaussian", 8);
        mean_flex = smoothdata(mean_flex, "gaussian", 8);
        
        output(f).name = loading_condition;
        output(f).flexion = array2table(mean_flex, "VariableNames", headers);
        output(f).extension = array2table(mean_ext, "VariableNames", headers);
        if config.enable_raw_plot
            % Plot
            figure(1); tiledlayout(2,1); sgtitle("Raw data");
            nexttile; plot(new_data.flexion);grid on;
            hold on;
            plot(smoothdata(new_data.flexion, "gaussian", 8))
            legend("z", "smooth z")
            nexttile; plot(new_data.force);
            grid on;
            hold off;
        end
        if config.enable_tension_plot
            figure(2);
            plot(mean_flex(:,1), mean_flex(:,2)); hold on;
            plot(mean_ext(:,1), mean_ext(:,2)); hold off;
            ylabel("Tension (N)");
            xlabel("Flexion Angle (Bad shift. Validate it!!)");
            legend("Flexion", "Extension");
            grid on;
            fig_title = string([config.specimen.name ' ' config.specimen.state]);
            sgtitle(replace([fig_title loading_condition], '_', ' '));
    
    
            figure(3);
            [x_arrowed, y_arrowed] = arrowed_line([mean_flex(:,1); mean_ext(:,1)], [mean_flex(:,2); mean_ext(:,2)], 10, 100, 100);
            plot(x_arrowed, y_arrowed);
            fig_title = string([config.specimen.name ' ' config.specimen.state]);
            sgtitle(replace([fig_title loading_condition], '_', ' '));
            ylabel("Tension (N)");
            xlabel("Flexion Angle (Bad shift. Validate it!!)");
            legend("Flexion-extension");
            grid on;
            
            keyboard;
        end
    end
    output = Option(output);
end
