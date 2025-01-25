function output = new_probe(landmarks, config)
    probe_labels = config.probe_labels;
    
    probe_names = [probe_labels.name];
    if isscalar(probe_names)
        probe_names = {probe_labels.name};
        probe_names = probe_names{:};
    end
    
    
    is_quaternion = config.is_quaternion;
    labels = {config.probe_labels.label};
    if isscalar(labels) % Received a single cell instead of an array of cells
        labels = labels{:};
    end

    landmark_names = {landmarks.name};
    for i = 1:numel(landmarks)
        output(i).name = landmark_names{i};
        landmarks_probes = landmarks.probes;
        for j = 1:numel(landmarks_probes)
            probe_data = landmarks(i).probes(j).data;
            if is_quaternion
                [rx, ry, rz] = quaternion2euler(probe_data.Q0, probe_data.Qx, probe_data.Qy, probe_data.Qz);
            else
                rx = probe_data.Rx;
                ry = probe_data.Ry;
                rz = probe_data.Rz;
            end

            % First occurence of Tx, Ty, Tz is the origin of the tracker. The
            % x,y,z fields for Certus are renamed to match this.
            header = probe_data.Properties.VariableNames;
            idx_tx_ty_tz = find(contains(header, {'Tx', 'Ty', 'Tz'}), 3);
            tx = probe_data{:, idx_tx_ty_tz(1)};
            ty = probe_data{:, idx_tx_ty_tz(2)};
            tz = probe_data{:, idx_tx_ty_tz(3)};

            probes(j).probe = landmarks(i).probes(j).probe;
            label = labels{strcmp(probe_names, probes(j).probe)};
            if isempty(label)
                warning("Undefined label for %s\n", label);
            end

            %% Create probes
            probes(j).label = label;
            probes(j).Rx = rx;
            probes(j).Ry = ry;
            probes(j).Rz = rz;
            probes(j).Q0 = probe_data.Q0;
            probes(j).Qx = probe_data.Qx;
            probes(j).Qy = probe_data.Qy;
            probes(j).Qz = probe_data.Qz;
            probes(j).Tx = tx;
            probes(j).Ty = ty;
            probes(j).Tz = tz;
            probes(j).rotations = [rx ry rz];
            probes(j).rotations_mean = mean(probes(j).rotations, "omitmissing");
            probes(j).translations = [tx ty tz];
            probes(j).translations_mean = mean(probes(j).translations, "omitmissing");
        end
        output(i).probes = probes;
    end
end