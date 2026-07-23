function trackers = generic(path)
    try
        data = readtable(path, "VariableNamingRule","preserve");
    catch
        warning("Unable to read file. Removing white spaces and trying again: %s", path)
        remove_whitespaces(path);
        data = readtable(path, "VariableNamingRule", "preserve");
    end

    headers = data.Properties.VariableNames;

    time_col = contains('time', headers, 'IgnoreCase', true);
    time = data(:, time_col);

    is_q0 = contains(headers, "q0", "IgnoreCase",true);
    labels = get_tracker_names(headers(is_q0));

    for k = 1:numel(labels)
        label = labels{k};
        is_datum = contains(headers, label);
        datum = data(:, is_datum);
        datum.Properties.VariableNames = clean_headers(headers(is_datum));

        q0 = datum.Q0;
        qx = datum.Qx;
        qy = datum.Qy;
        qz = datum.Qz;
        tx = datum.Tx;
        ty = datum.Ty;
        tz = datum.Tz;
        trackers(k) = Tracker(label, q0, qx, qy, qz, tx, ty, tz, time);
    end
end

function headers = clean_headers(headers)
        headers = regexprep(headers, '.*q0.*', 'Q0');
        headers = regexprep(headers, '.*qx.*', 'Qx');
        headers = regexprep(headers, '.*qy.*', 'Qy');
        headers = regexprep(headers, '.*qz.*', 'Qz');

        headers = regexprep(headers, '.*tx.*', 'Tx');
        headers = regexprep(headers, '.*ty.*', 'Ty');
        headers = regexprep(headers, '.*tz.*', 'Tz');

        headers = regexprep(headers, '.* x.*', 'Tx');
        headers = regexprep(headers, '.* y.*', 'Ty');
        headers = regexprep(headers, '.* z.*', 'Tz');
end
    
function trackers = get_tracker_names(headers)
    split_names = cellfun(@(x) split(x, ' '), headers, 'UniformOutput', false);
    trackers = cellfun(@(x) strjoin(x(1:end-1), ' '), split_names, 'UniformOutput', false);
    trackers = lower(trackers);
end