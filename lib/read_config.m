function label = read_config(file_path, target_string)
    % Open the file for reading
    fileID = fopen(file_path, 'r');

    if fileID == -1
        error('Failed to open the file.');
    end

    % Initialize variables
    line_number = 0;
    found_line = '';
    string_found = false;

    % Read the file line by line and see if line contains target string 
    while ~feof(fileID)
        line = fgetl(fileID);

        % Check if the target string is at the start of the line
        if contains(line, target_string)
            line = fgetl(fileID);
            fprintf('Found "%s" for probe %s\n', line, target_string);
            found_line = strrep(line, target_string, '');  % Remove the target string
            string_found = true;
            break;  % Stop reading the file when the target string is found at the start of the line
        end
    end

    % Close the file
    fclose(fileID);

    % Check if the line was found or not
    if string_found
        % Split the found line into numeric values and convert into a 4x4 matrix
        values = regexp(found_line, '=', 'split');
        label = values(2:end);
    else
        fprintf('Probe: "%s" was not found.\n', target_string);
        label = [];  % Return an empty matrix if the target string is not found at the start of any line
    end
end
