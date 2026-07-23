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
