function output = organise_data(landmarks, config)
    probe_labels = config.probe_labels;
    
    probe_names = [probe_labels.name];
    if isscalar(probe_names)
        probe_names = {probe_labels.name};
        probe_names = probe_names{:};
    end
    % probe_names = {probe_labels.name};
    
    
    is_quaternion = config.is_quaternion;
    labels = {config.probe_labels.label};
    if isscalar(labels) % Received a single cell instead of an array of cells
        labels = labels{:};
    end
    
    
    active_warning = false;
    for i = 1:numel(landmarks)
            lmk_name = {landmarks.name};
            output(i).name = lmk_name{i};
            n_probes = landmarks.probes;
            for j = 1:numel(n_probes)
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
                mask_tx_ty_tz = contains(header, {'Tx', 'Ty', 'Tz'});
                idx_tx_ty_tz = find(mask_tx_ty_tz, 3); 
                tx = probe_data{:, idx_tx_ty_tz(1)};
                ty = probe_data{:, idx_tx_ty_tz(2)};
                tz = probe_data{:, idx_tx_ty_tz(3)};
        
                probes(j).probe = landmarks(i).probes(j).probe;
                % probe_name = landmarks(i).probes(j).probe;
                % if ischar(probe_name) || isstring(probe_name)
                %     probes(j).probe = probe_name;
                % else
                %     probes(j).probe = probe_name{:};
                % end
                % probes(j).probe = landmarks(i).probes(j).probe{:};
                label = labels{strcmp(probe_names, probes(j).probe)};
                if isempty(label)
                    active_warning = true;
                    warning_probe = probe_name;
                    label = '';
                % elseif (ischar(label) & isstring(label))
                %     label = label{:};
                end
        
                %% Polaris registers NaN as some really big value. here we assign it to NaN properly
                if config.is_polaris
                    rx = error_to_nan(rx);
                    ry = error_to_nan(ry);
                    rz = error_to_nan(rz);
                    tx = error_to_nan(tx);
                    ty = error_to_nan(ty);
                    tz = error_to_nan(tz);
                end
        
                %% Create probes
                probes(j).label = label;
                probes(j).Rx = rx;
                probes(j).Ry = ry;
                probes(j).Rz = rz;
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
    if active_warning
    fprintf("Warning: Undefined label for %s\n", warning_probe);
    end

end

function output = error_to_nan(input)
    output = input;
    diffs = diff(input);
    mean_diff = mean(abs(diffs));
    outlier_mask = [false; abs(diffs) > 20 * mean_diff];
    outlier_mask = outlier_mask | abs(input) > 1e15;
    idx_outlier = find(outlier_mask);

    % There are no NaN.
    if isempty(idx_outlier) 
        return;
    end
    % Set all values between pairs to NaN
    if mod(numel(idx_outlier), 2) == 0
        idx = reshape(idx_outlier, 2, []);
        idx_start = idx(1,:);
        idx_stop = idx(2, :);

        mask = (1:length(input))';
        mask = mask .* ones(size(idx_start));
        outlier_mask = any(mask >= idx_start & mask <= idx_stop, 2);
        output(outlier_mask) = NaN;
    else
        % There's a single NaN
        output(idx_outlier) = NaN;
    end
    
end