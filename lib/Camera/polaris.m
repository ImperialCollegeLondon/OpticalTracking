function [trackers, strays] = polaris(headers, fid)
    % Manually reading files because strays caused malformed CSVs
    fgetl(fid); % Discard the first empty line
    first_line = fgetl(fid);

    [fmt, is_numeric] = tokeniser(first_line, headers);

    frewind(fid);
    fgetl(fid); % Skip header again

    raw_text = fread(fid, '*char')';
    lines = splitlines(raw_text);
    n_fields = numel(headers);

    for i = 1:numel(lines)
        if isempty(lines{i})
            continue
        end

        n = sum(lines{i} == ',') + 1;
        if n < n_fields
            lines{i} = [lines{i}, repmat(',', 1, n_fields - n)];
        elseif n > n_fields
            comma_pos = find(lines{i} == ',', n_fields);
            lines{i} = lines{i}(1:comma_pos(end));
        end
    end

    data = textscan(strjoin(lines,newline), fmt, 'Delimiter', ',', 'EndOfLine', '\n', 'EmptyValue', NaN, 'ReturnOnError', false);
    data = [data{:}];
    data(abs(data) > 1e20) = nan;

    stray_idx = find(strcmp(headers, 'Passive Strays'), 1);
    
    if isempty(stray_idx)
        sentinel = numel(headers) + 1;
        idx_stray_data = width(data);
    else
        sentinel = stray_idx;
        idx_stray_data = sum(is_numeric(1:stray_idx-1)) + 1;
    end

    idx_markers = find(contains(headers, 'Port'));
    idx_tracker = idx_markers;
    idx_markers(end+1) = sentinel;

    for k = 1:numel(idx_markers) - 1
        in_port = false(1, numel(headers));
        in_port(idx_markers(k)+1 : idx_markers(k+1)-1) = true;
        tracker_mask{k} = in_port(is_numeric);
    end

    names = headers(idx_tracker);
    headers_numeric = headers(is_numeric);
    idx_q0 = find(contains(headers_numeric(1:idx_stray_data), 'Q0'));
    
    %% Assumes they are sequential and in this order: Q0, Qx, Qy, Qz, Tx, Ty, Tz, Error
    Q0 = 1;
    QX = 2;
    QY = 3;
    QZ = 4;
    TX = 5;
    TY = 6;
    TZ = 7;
    ERR = 8;
    idx = idx_q0(:) + (0:7);

    for n = 1:numel(idx_tracker)
        name = names{n};
        q0 = data(:, idx(n, Q0));
        qx = data(:, idx(n, QX));
        qy = data(:, idx(n, QY));
        qz = data(:, idx(n, QZ));
        tx = data(:, idx(n, TX));
        ty = data(:, idx(n, TY));
        tz = data(:, idx(n, TZ));
        err = data(:, idx(n, ERR));
        trackers(n) = Tracker(name, q0, qx, qy, qz, tx, ty, tz, err);
    end

    has_strays = ~isempty(stray_idx);
    if has_strays
        data_strays = data(:, idx_stray_data+1:end);
        header_stray = headers_numeric(idx_stray_data+1:end);
        stray_tz = find(strcmp(header_stray, 'Tz'));
        idx_stray = stray_tz(:) - (0:2);

        strays(numel(stray_tz)) = PassiveStrays();
        for n = 1:numel(stray_tz)
            tz = data_strays(:, idx_stray(n, 1));
            ty = data_strays(:, idx_stray(n, 2));
            tx = data_strays(:, idx_stray(n, 3));
            strays(n) = PassiveStrays(tx, ty, tz);
        end

    else
        strays = [];
    end

end

function [fmt, is_numeric] = tokeniser(line, headers)
    % Determines whether each column contains a string or float
    tokens = strsplit(line, ',');
    n = min([numel(tokens) numel(headers)]);
    tokens = tokens(1:n);

    vals = str2double(tokens);
    is_numeric = ~isnan(vals) | strcmpi(strtrim(tokens), 'nan');
    fmt_parts = repmat({'%*s'}, 1, n);
    fmt_parts(is_numeric) = {'%f'};
    fmt = strjoin(fmt_parts, '');
end
