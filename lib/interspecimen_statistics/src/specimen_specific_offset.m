function specimens_offset = specimen_specific_offset(specimens, config)
specimens_offset = specimens;
for sp = 1:numel(specimens)
    states = fieldnames(specimens);
    % if strcmp(states{sp}, config.intact_name)
    %     continue
    % end
    for st = 1:numel(states)
        if strcmp(states{st}, "name")
            continue
        end
        % if ~isempty(specimens_offset(sp).(states{st})) & ~strcmp(states{st}, config.intact_name)

        if ~isempty(specimens_offset(sp).(states{st}))
            specimens_offset(sp).(states{st})(2:end) = [];
        end
    end
end
for sp = 1:numel(specimens)
    specimen = specimens(sp);
    specimen = interpolate(specimen, config);
    states = fieldnames(specimen);

    intact = specimen.(config.intact_name);
    for st = 1:numel(states)
        if strcmp(states{st}, "name")
            continue
        end
        stat = states{st};

        tibiofemoral = fieldnames(specimen.(stat)(1));
        tibiofemoral(strcmpi(tibiofemoral, "name")) = [];
        for lc = 1:numel(specimen.(stat))
            for i = 1:numel(tibiofemoral)
                % if strcmp(stat, config.intact_name)
                %     continue
                % end
                new_lc.name = specimen.(stat)(lc).name;
                a = table2array(specimen.(stat)(lc).(tibiofemoral{i}));
                b = table2array(intact(lc).(tibiofemoral{i}));
                if numel(a) ~= numel(b)
                    disp(lc)
                end
                difference = a-b;
                if ~isempty(specimen.(stat)(lc).(tibiofemoral{i}))
                    difference(:,1) = specimen.(stat)(lc).(tibiofemoral{i}).flexion;
                end
                new_lc.(tibiofemoral{i}) = array2table(difference, "VariableNames", specimen.(stat)(lc).(tibiofemoral{i}).Properties.VariableNames);

            end
            specimens_offset(sp).(stat)(lc) = new_lc;
        end
    end
end
end
