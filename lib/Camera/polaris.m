function [trackers, strays] = polaris(raw_headers, lines)
    idx_tracker = find(contains(raw_headers, "Port"));
    names = raw_headers(idx_tracker);
    n_trackers = numel(idx_tracker);
    idx_q0 = find(contains(raw_headers, 'Q0'));
    

    passive_strays_idx = find(strcmp(raw_headers, 'Passive Strays'), 1);
    has_passives = ~isempty(passive_strays_idx);
    if has_passives
        idx_q0 = idx_q0(idx_q0 < passive_strays_idx);

        stray_headers = raw_headers(passive_strays_idx: end);
        stray_tz = find(strcmp(stray_headers, 'Tz'));
        idx_stray = stray_tz(:) - (0:2);
    end

    % Assumes they are sequential and in this order: Q0, Qx, Qy, Qz, Tx, Ty, Tz, Error
    idx = idx_q0(:) + (0:7);

    Q0 = 1;
    QX = 2;
    QY = 3;
    QZ = 4;
    TX = 5;
    TY = 6;
    TZ = 7;
    ERR = 8;

    n_rows = numel(lines) - 1;
    data_tracker = nan(size(idx, 1), size(idx, 2), n_rows);

    if has_passives
        data_stray = nan(size(idx_stray, 1), size(idx_stray, 2), n_rows);
    end

    for n = 1:n_rows
        row = strsplit(lines{n + 1}, ',');

        datum = str2double(row(idx));
        datum(abs(datum) > 1e20) = nan;
        data_tracker(:, :, n) = datum;

        if has_passives
            row_stray = row(passive_strays_idx:end);
            datum_stray = extract_strays(stray_headers, idx_stray, row_stray);
            data_stray(:, :, n) = datum_stray;
        end

    end

    for n = 1:n_trackers
        name = names{n};
        q0 = squeeze(data_tracker(n, Q0, :));
        qx = squeeze(data_tracker(n, QX, :));
        qy = squeeze(data_tracker(n, QY, :));
        qz = squeeze(data_tracker(n, QZ, :));
        tx = squeeze(data_tracker(n, TX, :));
        ty = squeeze(data_tracker(n, TY, :));
        tz = squeeze(data_tracker(n, TZ, :));
        error = squeeze(data_tracker(n, ERR, :));
        trackers(n) = Tracker(name, q0, qx, qy, qz, tx, ty, tz, error);
    end
    strays = [];
end


function datum = extract_strays(headers, idx, row)

    if numel(row) < numel(headers)
        row(length(row)+1:length(headers)) = {nan};
    end

    if numel(row) > numel(headers)
        keyboard
        new_rows = (numel(row) - numel(headers))/4;
        last_tz = max(idx(:));
        extra_idx = last_tz + (4:-1:2);
    end

    datum = str2double(row(idx));
end