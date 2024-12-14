function output = sanitise_data(landmarks, probe_labels, is_quaternion)
warning = false;
for i = 1:numel(landmarks)
    lmk_name = {landmarks.name};
    output(i).name = lmk_name{i};
    n_probes = landmarks.probes;
    for j = 1:numel(n_probes)
        probe_data = landmarks(i).probes(j).data;
        if is_quaternion
            % Requires double checking.
            [rx, ry, rz] = quaternion2euler(probe_data.Q0, probe_data.Qx, probe_data.Qy, probe_data.Qz);
        else
            rx = probe_data.Rx;
            ry = probe_data.Ry;
            rz = probe_data.Rz;
        end

        header = probe_data.Properties.VariableNames;

        tx = probe_data{:, contains(header, "Tx")}(:,1);
        ty = probe_data{:, contains(header, "Ty")}(:,1);
        tz = probe_data{:, contains(header, "Tz")}(:,1);

        probe_name = landmarks(i).probes(j).probe;
        if ischar(probe_name) || isstring(probe_name)
            probes(j).probe = probe_name;
        else
            probes(j).probe = probe_name{:};
        end
        % probes(j).probe = landmarks(i).probes(j).probe{:};
        labels = {probe_labels.label};

        label = labels(strcmp([probe_labels.name], probes(j).probe));
    if isempty(label)
        warning = true;
        warning_probe = probe_name;
        label = '';
    elseif ~ischar(label) || ~isstring(label)
            label = label{:};
        end
        probes(j).label = label;
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
if warning
fprintf("Warning: Undefined label for %s\n", warning_probe);
end

end
