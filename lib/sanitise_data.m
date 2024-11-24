function output = sanitise_data(landmarks, probe_labels)
for i = 1:numel(landmarks)
    lmk_name = {landmarks.name};
    output(i).name = lmk_name{i};
    n_probes = landmarks.probes;
    for j = 1:numel(n_probes)
        probe_data = landmarks(i).probes(j).data;
        rx = probe_data.Rx;
        ry = probe_data.Ry;
        rz = probe_data.Rz;

        header = probe_data.Properties.VariableNames;
        tx = mean(probe_data{:, contains(header, "Tx")}, 2);
        ty = mean(probe_data{:, contains(header, "Ty")}, 2);
        tz = mean(probe_data{:, contains(header, "Tz")}, 2);
        % tx = probe_data{:, contains(header, "Tx")}(:,1);
        % ty = probe_data{:, contains(header, "Ty")}(:,1);
        % tz = probe_data{:, contains(header, "Tz")}(:,1);

        % output.name(i).probes(j) = landmarks(i)
        probes(j).probe = landmarks(i).probes(j).probe{:};
        labels = [probe_labels.label];

        probes(j).label = labels{strcmp([probe_labels.name], probes(j).probe)};
        probes(j).Rx = rx;
        probes(j).Ry = ry;
        probes(j).Rz = rz;
        probes(j).Tx = tx;
        probes(j).Ty = ty;
        probes(j).Tz = tz;
        probes(j).rotations = [rx ry rz];
        probes(j).rotations_mean = mean(probes(j).rotations);
        probes(j).translations = [tx ty tz];
        probes(j).translations_mean = mean(probes(j).translations);

    end
    output(i).probes = probes;

end

end
