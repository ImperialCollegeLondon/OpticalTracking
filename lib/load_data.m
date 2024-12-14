function [landmarks, use_quaternion] = load_data(filepath)
csv_files = dir(fullfile(filepath, "*.csv"));
tsv_files = dir(fullfile(filepath, "*.tsv"));
files = [csv_files; tsv_files];

landmarks = struct();

for i = 1:numel(files)
    [~, landmarks(i).name, ~] = fileparts(files(i).name);
    fp = fullfile(files(i).folder, files(i).name);
    data = readtable(fp, "VariableNamingRule","preserve");
    probe_idx = find(contains(data.Properties.VariableNames, "Port"));
    n = mode(diff(probe_idx));
    use_quaternion = any(contains(data.Properties.VariableNames, "Q0"));
    n_probes = length(probe_idx);
    landmarks(i).probes = struct();
    for k = 1:n_probes
        id = probe_idx(k);

        if contains(table2cell(data(1, id)), "Stray")
            continue
        end

        landmarks(i).probes(k).probe = table2cell(data(1, id));
        landmarks(i).probes(k).data = data(:, 1+id:id+n-1);
        
        headers = landmarks(i).probes(k).data.Properties.VariableNames;
        
        if use_quaternion
            headers = regexprep(headers, '.*Q0.*', 'Q0');
            headers = regexprep(headers, '.*Qx.*', 'Qx');
            headers = regexprep(headers, '.*Qy.*', 'Qy');
            headers = regexprep(headers, '.*Qz.*', 'Qz');
        else
            headers = regexprep(headers, '.*Rx.*', 'Rx');
            headers = regexprep(headers, '.*Ry.*', 'Ry');
            headers = regexprep(headers, '.*Rz.*', 'Rz');
        end
        landmarks(i).probes(k).data.Properties.VariableNames = headers;
    end
end
