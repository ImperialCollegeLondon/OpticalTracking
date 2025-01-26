function output = new_landmark(landmarks, config)
    probe_labels = config.probe_labels;
    
    probe_names = [probe_labels.name];
    % if isscalar(probe_names)
    %     probe_names = {probe_labels.name};
    %     probe_names = probe_names{:};
    % end
    
    
    is_quaternion = config.is_quaternion;
    labels = [config.probe_labels.label];
    labels = labels.unwrap();
    % if isscalar(labels) % Received a single cell instead of an array of cells
    %     labels = labels{:};
    % end

    landmark_names = {landmarks.name};
    for i = 1:numel(landmarks)
        
        landmarks_probes = [landmarks(i).probes];
        for j = 1:numel(landmarks_probes)
            probe_data = landmarks(i).probes(j).data;
            probe_name = string(landmarks(i).probes(j).probe);
            label = string(labels{strcmp(probe_names, probe_name)});

            %% Safety checks
            if isempty(label)
                warning("Undefined label for %s\n", label);
            end

            if isempty(probe_data)
                probes(j) = Option.None;
                continue
            end

            %% Create the marker
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



            %% Create probes
            probes(j) = Option(Marker(probe_name, label, rx, ry, rz, tx, ty, tz));

        end
        output(i) = Landmark(landmark_names{i}, probes);
    end
end