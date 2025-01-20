function plot_raw(data, config)
    loading_conditions = {data.name};
    for lc = 1:numel(loading_conditions)
        tibiofemoral = setdiff(fieldnames(data), "name");
        config.loading_condition = loading_conditions{lc};
        for tf = 1:numel(tibiofemoral)
            if isempty(data(lc).(tibiofemoral(tf)))
                continue
            end
            datum = data(lc).(tibiofemoral(tf));
            if ~config.debug, figure, end
            tiledlayout(3, 2);

            nexttile; title('Rotations');
            ylabel('Flexion ($\circ$)');
            if config.debug
                find_minima(datum.flexion, config);
            else
                plot(datum.flexion);
            end

            nexttile; title('Translations');
            plot(datum.lateral);
            ylabel('Lateral (mm) +ve');

            nexttile
            plot(datum.varus);
            ylabel('Tibial Varus ($\circ$) +ve');

            nexttile
            plot(datum.anterior);
            ylabel('Anterior (mm) +ve');

            nexttile
            plot(datum.external);
            ylabel('Tibial External ($\circ$) +ve');

            nexttile
            plot(datum.superior);
            ylabel('Distal (mm) +ve');

            sgtitle([[config.specimen_name ' ' replace(config.state, '_', ' ') ' ' config.loading_condition] "Tibia motion relative to Femur"]);
            sgt.Interpreter = "latex";

            if config.debug, keyboard, end
        end
    end

end