function landmarks = load_data(filepath)
files = dir(fullfile(filepath, "*.csv"));
landmarks = struct();

for i = 1:numel(files)
    [~, landmarks(i).name, ~] = fileparts(files(i).name);
    fp = fullfile(files(i).folder, files(i).name);
    data = readtable(fp, "VariableNamingRule","preserve");
    n_probes = data.Tools(1);
    landmarks(i).probes = struct();
    for k = 1:n_probes


        
        if contains(table2cell(data(1, 2 + (k-1)*25)), "Stray")
            continue
            % landmarks(i).probes(k).data = data(:, 3 + (k-1)*25:end);
        else
            landmarks(i).probes(k).probe = table2cell(data(1, 2 + (k-1)*25));
            landmarks(i).probes(k).data = data(:, 3 + (k-1)*25:26+(k-1)*25);
        end

        headers = landmarks(i).probes(k).data.Properties.VariableNames;

        headers = regexprep(headers, '.*Rx.*', 'Rx');
        headers = regexprep(headers, '.*Ry.*', 'Ry');
        headers = regexprep(headers, '.*Rz.*', 'Rz');
        landmarks(i).probes(k).data.Properties.VariableNames = headers;
    end
end