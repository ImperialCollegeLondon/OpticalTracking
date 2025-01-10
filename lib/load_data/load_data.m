function [landmarks, config, idx_interpolation] = load_data(folder_path, labels)
csv_files = dir(fullfile(folder_path, "*.csv"));
csv_files = csv_files(~contains({csv_files.name}, '3d.csv'));
tsv_files = dir(fullfile(folder_path, "*.tsv"));
files = [csv_files; tsv_files];

landmarks = struct();

for i = 1:numel(files)
    [~, parent_path, ~] = fileparts(files(i).name);
    landmarks(i).name = clean_specimen_condition(parent_path);
    fp = fullfile(files(i).folder, files(i).name);
    remove_whitespaces(fp);
    data = readtable(fp, "VariableNamingRule","preserve");
    
    config.is_quaternion = use_quaternion(data.Properties.VariableNames);
    config.is_polaris = use_polaris(data.Properties.VariableNames);
    if config.is_polaris
        landmarks(i).probes = load_data_polaris(data, config.is_quaternion);
        idx_interpolation{i}=[];
    else
            %% Interpolate data to fill out any gaps.
            %Should be moved back to both, but here for now. Solution might
            %be to clean polaris data, or use the filtering after
            %organisation.
        [data, idx_all_interpolation] = fillmissing(data, "movmedian", 50);
        idx_interpolation{i} = any(idx_all_interpolation, 2);
        % data = smoothdata(data, "gaussian", 20);
        landmarks(i).probes = load_data_certus(data);
    end

    if isempty(landmarks(i).probes(1).data)
        [path_warn, filename, ~] = fileparts(folder_path);
        [~, parent_path, ~] = fileparts(path_warn);
        warning("Missing data from %s/%s/%s", parent_path, filename, landmarks(i).name)
    end
    
end

if config.is_polaris
    if isfield(labels, 'polaris')
        lb = labels.polaris;
    else
        lb = labels;
    end
    config.probe_labels = get_probe_labels(lb, landmarks, folder_path);
else
    if isfield(labels, 'certus')
        lb = labels.certus;
    else
        lb = labels;
    end
    % l = struct2array(labels.certus);
    for i = 1:numel(lb)
        config.probe_labels(i).label = struct2cell(lb(i));
        config.probe_labels(i).name = struct2cell(lb(i));
    end
end

end

function remove_whitespaces(filepath)
%% Remove whitespaces, a common cause for matlab to not properly interpret the headers of a csv file.
fid = fopen(filepath, 'r');
file_content = textscan(fid, '%s', 'Delimiter', '\n', 'Whitespace', '');
fclose(fid);

file_content = file_content{1};

% Certus data always starts with Frame 1. We're looking for it to remove
% whitespaces. In the future, maybe just do it for every numeric row.
idx_start = 0;
for i = 1:10
    line = file_content{i};
    if startsWith(strtrim(line), '1')
        idx_start = i;
        break;
    end
end

% If it can't find a Frame 1 in the first 10 lines, then it's probably Polaris data and doesn't need to remove whitespaces
if idx_start == 0
    return;
end

file_content(i:end) = regexprep(file_content(i:end), '\s+', ''); % Remove all whitespace

% write the content back to a new file
fid = fopen(filepath, 'w');
if fid == -1
    error('Could not open the output file.');
end

for i = 1:length(file_content)
    fprintf(fid, '%s\n', file_content{i});
end

fclose(fid);
end