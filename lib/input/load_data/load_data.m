function [landmarks, config] = load_data(folder_path, labels, config)
    csv_files = dir(fullfile(folder_path, "*.csv"));
    csv_files = csv_files(~contains({csv_files.name}, '3d.csv')); % Certus data files that shouldn't be used
    tsv_files = dir(fullfile(folder_path, "*.tsv"));
    files = [csv_files; tsv_files];

    landmarks = struct();
    
    % Open the files as tables, use the headers to determine which optical
    % trackin system is being used, then apply any parsing necessary to
    % make data usable.
    % e.g. convert -3.697314E+028 => NaN on the polaris.
    for i = 1:numel(files)
        [~, parent_path, ~] = fileparts(files(i).name);
        landmarks(i).name = clean_specimen_condition(parent_path);
        fp = fullfile(files(i).folder, files(i).name);
        remove_whitespaces(fp);
        try
            data = readtable(fp, "VariableNamingRule","preserve");
        catch
            data = readtable(fp, "VariableNamingRule","preserve", "FileType","text", "Delimiter", '\t');
        end
        
        if ~any(contains(fieldnames(config), "quaternion"))
            config.is_quaternion = use_quaternion(data.Properties.VariableNames);
            config.is_polaris = use_polaris(data.Properties.VariableNames);
        end

        if config.is_polaris
            landmarks(i).probes = load_data_polaris(data, config);
        else
            landmarks(i).probes = load_data_certus(data);
        end
    
        if numel(landmarks(i).probes) < 2
            [~, filename, ~] = fileparts(folder_path);
            warning("Missing data from %s %s", filename, landmarks(i).name)
        end
        
    end
    
    % Necessary to use the same load_data() for landmarks and data. Handles switching from generic labels to optical tracker specific. 
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
        for i = 1:numel(lb)
            config.probe_labels(i).label = struct2cell(lb(i));
            config.probe_labels(i).name = struct2cell(lb(i));
        end
    end

end

function remove_whitespaces(filepath)
%% Remove whitespaces, a common cause for matlab to not properly interpret the headers of a csv file.
% This is chatgpt stuff. Worth making sure it can't be done less painfully.
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