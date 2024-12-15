function [landmarks, use_quaternion, probe_labels, is_polaris] = load_data(filepath, labels)
csv_files = dir(fullfile(filepath, "*.csv"));
tsv_files = dir(fullfile(filepath, "*.tsv"));
files = [csv_files; tsv_files];

landmarks = struct();

for i = 1:numel(files)
    [~, landmarks(i).name, ~] = fileparts(files(i).name);
    fp = fullfile(files(i).folder, files(i).name);
    remove_whitespaces(fp);
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
    probe_labels = get_probe_labels(labels.polaris, landmarks, filepath);
else
    l = struct2array(labels.certus);
    for i = 1:numel(l)
        probe_labels(i).label = l(i);
        probe_labels(i).name = l(i);
    end
end

end

function remove_whitespaces(filepath)
%% Remove whitespaces, a common cause for matlab to not properly interpret the headers of a csv file.
fid = fopen(filepath, 'r');
if fid == -1
    error('Could not open the input file.');
end
fileContent = textscan(fid, '%s', 'Delimiter', '\n', 'Whitespace', '');
fclose(fid);

fileContent = fileContent{1};

% Certus data always starts with Frame 1. We're looking for it to remove
% whitespaces. In the future, maybe just do it for every numeric row.
idx_start = 0;
for i = 1:10
    line = fileContent{i};
    if startsWith(strtrim(line), '1')
        idx_start = i;
        break;
    end
end

% If it can't find a Frame 1 in the first 10 lines, then it's probably Polaris data and doesn't need to remove whitespaces
if idx_start == 0
    return;
end

for i = idx_start:length(fileContent)
    fileContent{i} = regexprep(fileContent{i}, '\s+', ''); % Remove all whitespace
end

% Step 4: Write the processed content back to a new file
fid = fopen(filepath, 'w');
if fid == -1
    error('Could not open the output file.');
end

for i = 1:length(fileContent)
    fprintf(fid, '%s\n', fileContent{i});
end

fclose(fid);
end
