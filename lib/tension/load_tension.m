function load_tension(path, config)
    files = Option(dir(fullfile(path, "*.xlsm")));
    if files.is_none
        Option.None()
        return
    end
    files = files.unwrap();

    for f = 1:numel(files)
        filename = fullfile(files(f).folder, files(f).name);
        data = readtable(filename, "VariableNamingRule","preserve");
        
        new_data = table();
        new_data.force = str2double(erase(data.("Force (N)"), ' N'));
        new_data.z = data.Z;
        new_data.x = data.X;
        new_data.y = data.Y;

        plot(new_data.z, new_data.force)
    end
end