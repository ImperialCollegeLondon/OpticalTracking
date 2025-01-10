function print_to_file(datum, path)
    tibiofemoral = setdiff(fieldnames(datum), "name");

    for i = 1:numel(tibiofemoral)
        fp = fullfile(path, "Results");
        mkdir(fp, tibiofemoral{i});
        for j = 1:numel(datum)
            loading_condition = datum(j).name;
            tf = datum(j).(tibiofemoral{i});
            if ~isempty(tf)
                tf_filename = fullfile(fp, tibiofemoral{i}, [loading_condition '.csv']);
                writetable(tf, tf_filename);
            end
        end
    end
end
