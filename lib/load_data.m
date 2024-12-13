function [landmarks, use_quaternion, probe_labels] = load_data(filepath, labels)
csv_files = dir(fullfile(filepath, "*.csv"));
tsv_files = dir(fullfile(filepath, "*.tsv"));
files = [csv_files; tsv_files];

landmarks = struct();

for i = 1:numel(files)
    [~, landmarks(i).name, ~] = fileparts(files(i).name);
    fp = fullfile(files(i).folder, files(i).name);
    data = readtable(fp, "VariableNamingRule","preserve");
    use_quaternion = any(contains(lower(data.Properties.VariableNames), "q0"));
    is_polaris = any(contains(data.Properties.VariableNames, "Port"));
    
    if is_polaris
        landmarks(i).probes = load_data_polaris(data, use_quaternion);
    else
        landmarks(i).probes = load_data_certus(data);
    end


end

if is_polaris
    probe_labels = get_probe_labels(labels, landmarks, filepath);
    disp("Detected a Polaris camera. If it's not, remove the word 'Port' from your probe!")
else
    l = struct2array(labels);
    for i = 1:numel(l)
        probe_labels(i).label = l(i);
        probe_labels(i).name = l(i);
    end
end

end