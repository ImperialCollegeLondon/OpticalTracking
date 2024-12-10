function [landmarks, use_quaternion] = load_data(filepath)
csv_files = dir(fullfile(filepath, "*.csv"));
tsv_files = dir(fullfile(filepath, "*.tsv"));
files = [csv_files; tsv_files];

landmarks = struct();

for i = 1:numel(files)
    [~, landmarks(i).name, ~] = fileparts(files(i).name);
    fp = fullfile(files(i).folder, files(i).name);
    data = readtable(fp, "VariableNamingRule","preserve");
    use_quaternion = any(contains(data.Properties.VariableNames, "Q0"));
    n_probes = data.Tools(1);
    landmarks(i).probes = struct();
    for k = 1:n_probes
        if use_quaternion
            id = 2 + (k-1)*26;
            last = 25;
        else
            id = 2 + (k-1)*25;
            last = 24;
        end
        if contains(table2cell(data(1, id)), "Stray")
            continue
            % landmarks(i).probes(k).data = data(:, 3 + (k-1)*25:end);
        else
            landmarks(i).probes(k).probe = table2cell(data(1, id));
            landmarks(i).probes(k).data = data(:, 1+id:id+last);
        end
        
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
