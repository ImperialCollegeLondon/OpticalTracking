function probes = load_data_certus(data)
probes = struct();
probe_idx = find(contains(data.Properties.VariableNames, "q0"));
if isempty(probe_idx)
error("Matlab was unable to read the headers from the csv. Try removing the spaces before the numbers.");
end

n = mode(diff(probe_idx));

n_probes = length(probe_idx);
names = get_tracker_names(data.Properties.VariableNames(probe_idx));
for k = 1:n_probes
    id = probe_idx(k);
    % If there are multiple words, then it must be the probe.
    % If not, then it's one of the bone trackers.
    if numel(strsplit(names{k}, ' ')) > 1
    probes(k).probe = 'Probe';
    else
        probes(k).probe = names{k};
    end
    probes(k).data = data(:, id:id+n-1);
    
    headers = probes(k).data.Properties.VariableNames;
    
        headers = regexprep(headers, '.*q0.*', 'Q0');
        headers = regexprep(headers, '.*qx.*', 'Qx');
        headers = regexprep(headers, '.*qy.*', 'Qy');
        headers = regexprep(headers, '.*qz.*', 'Qz');
        headers = regexprep(headers, '.* x.*', 'Tx');
        headers = regexprep(headers, '.* y.*', 'Ty');
        headers = regexprep(headers, '.* z.*', 'Tz');
        headers = regexprep(headers, '.* Error.*', 'Error');
    probes(k).data.Properties.VariableNames = headers;
end
end

function trackers = get_tracker_names(headers)
split_names = cellfun(@(x) split(x, ' '), headers, 'UniformOutput', false);
trackers = cellfun(@(x) strjoin(x(1:end-1), ' '), split_names, 'UniformOutput', false);
trackers = lower(trackers);
end
