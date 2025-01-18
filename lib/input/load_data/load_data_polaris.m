function probes = load_data_polaris(data, config)
probes = struct();
probe_idx = find(contains(data.Properties.VariableNames, "Port"));

n = mode(diff(probe_idx));

n_probes = length(probe_idx);
if n_probes == 1
    n = 0;
else
    n = mode(diff(probe_idx));
end
for k = 1:n_probes
    id = probe_idx(k);
    if contains(table2cell(data(1, id)), "Stray")
        continue
    end
    probes(k).probe = table2cell(data(1, id));
    probes(k).data = data(:, 1+id:id+n-1);
    headers = probes(k).data.Properties.VariableNames;
    
    if config.is_quaternion
        headers = regexprep(headers, '.*Q0.*', 'Q0');
        headers = regexprep(headers, '.*Qx.*', 'Qx');
        headers = regexprep(headers, '.*Qy.*', 'Qy');
        headers = regexprep(headers, '.*Qz.*', 'Qz');
        headers = regexprep(headers, '.*State*', "State");
    else
        headers = regexprep(headers, '.*Rx.*', 'Rx');
        headers = regexprep(headers, '.*Ry.*', 'Ry');
        headers = regexprep(headers, '.*Rz.*', 'Rz');
    end
    probes(k).data.Properties.VariableNames = headers;
end
end
