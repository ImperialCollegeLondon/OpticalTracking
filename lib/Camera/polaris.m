function [trackers, strays] = polaris(headers, fid)
    % Manually reading files because strays caused malformed CSVs
    fgetl(fid); % Discard the first empty line
    first_line = fgetl(fid);

    [fmt, is_numeric] = tokeniser(first_line);

    frewind(fid);
    fgetl(fid); % Skip header again
    data = textscan(fid, fmt, 'Delimiter', ',', 'EmptyValue', NaN);
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
        error = data(:, idx(n, ERR));
        trackers(n) = Tracker(name, q0, qx, qy, qz, tx, ty, tz, error);
    end

    has_strays = ~isempty(stray_idx);
    if has_strays
        data_strays = data(:, idx_stray_data+1:end);
        header_stray = headers_numeric(idx_stray_data+1:end);
        stray_tz = find(strcmp(header_stray, 'Tz'));
        idx_stray = stray_tz(:) - (0:2);

        strays(length(stray_tz)) = PassiveStrays();
        for n = 1:length(idx_stray)
            tz = data_strays(:, idx_stray(n, 1));
            ty = data_strays(:, idx_stray(n, 2));
            tx = data_strays(:, idx_stray(n, 3));
            strays(n) = PassiveStrays(tx, ty, tz);
        end

    else
        strays = [];
    end



end

function [fmt, is_numeric] = tokeniser(line)
        tokens = strsplit(line, ',');
        fmt_parts = cell(1, numel(tokens));
        is_numeric = true(1, numel(tokens));
        for k = 1:numel(tokens)
            v = str2double(tokens{k});
            if isnan(v) && ~strcmpi(strtrim(tokens{k}), 'nan')
                fmt_parts{k} = '%*s';
                is_numeric(k) = false;
            else
                fmt_parts{k} = '%f';
            end
        end
        fmt = strjoin(fmt_parts, '');
    end
