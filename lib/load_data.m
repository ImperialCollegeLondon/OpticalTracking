function [landmarks, use_quaternion] = load_data(filepath)
csv_files = dir(fullfile(filepath, "*.csv"));
tsv_files = dir(fullfile(filepath, "*.tsv"));
files = [csv_files; tsv_files];

landmarks = struct();

for i = 1:numel(files)
    [~, landmarks(i).name, ~] = fileparts(files(i).name);
    fp = fullfile(files(i).folder, files(i).name);
    data = readtable(fp, "VariableNamingRule","preserve");
    use_quaternion = any(contains(lower(data.Properties.VariableNames), "q0"));
    landmarks(i).probes = load_data_polaris(data, use_quaternion);
end
