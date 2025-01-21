function fig = plot_raw(data, config)
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
            title(tibiofemoral(tf))
            disp(loading_conditions{lc})
            for h = 1:numel(headers)
                nexttile(h);
                plot(datum.(headers{h}))
                ylabel(headers{h});

                % if config.debug
                %     find_minima(datum.flexion, config);
                % else
                %     plot(datum.flexion);
                % end
            end
            % if ~config.debug, figure, end

            
            % title('Rotations');
            % ylabel('Flexion ($\circ$)');

            % 
            % nexttile; title('Translations');
            % plot(datum.lateral);
            % ylabel('Lateral (mm) +ve');
            % 
            % nexttile
            % plot(datum.varus);
            % ylabel('Tibial Varus ($\circ$) +ve');
            % 
            % nexttile
            % plot(datum.anterior);
            % ylabel('Anterior (mm) +ve');
            % 
            % nexttile
            % plot(datum.external);
            % ylabel('Tibial External ($\circ$) +ve');
            % 
            % nexttile
            % plot(datum.superior);
            % ylabel('Distal (mm) +ve');

            sgtitle([[config.specimen_name ' ' replace(config.state, '_', ' ') ' ' config.loading_condition] tibiofemoral(tf)]);
            sgt.Interpreter = "latex";

            if config.debug, keyboard, end
        end
    end

end