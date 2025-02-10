function output = get_split_runs(input, split_runs_idx, no_tails, config)    
    data_reshaped = reshape(input, [height(input), 1, width(input)]); % time, empty, column (flexion, varus, etc). 634 x 1 x 6
    data_masked = data_reshaped .* split_runs_idx .* no_tails; % 634 x 5 x 6 time, runs, column (flexion, varus, etc).
    data = data_masked(:, no_tails, :);
    has_datum = any(data_masked,2);
    has_datum = has_datum(:,1);
    data = data(has_datum, :, :); % 620 x 3 x 6
    flex_ext = input(:,1);
    arc = flex_ext(has_datum); % Flexion-extension arc excluding tails

    if ~config.split_flex_ext
        output = quantise(data, arc, config.step_size);
        return
    end
    % Find the flexion/extension arcs and remove any tails
    is_flexion_extension_arc = split_runs_idx(:, no_tails);
    is_flexion_extension_arc = is_flexion_extension_arc(has_datum, :);

    [~, idx_peak] = max(data);
    idx_peak_flexion = idx_peak(:,:, 1);

    % Everything from the start up to peak flexion is 'not extension'. We set
    % them all to zero. The values left are flexion.
    not_extension = (1:length(is_flexion_extension_arc))' <= idx_peak_flexion;
    extension_arc = is_flexion_extension_arc;
    extension_arc(not_extension) = 0;
    flexion_arc = is_flexion_extension_arc - extension_arc; % Could use xor(), but logical operations when you have NaN tend to cause trouble.
    flex_ext_split = data(:,:,1);

    output.extension = flip(quantise(data.*extension_arc, arc, config.step_size));
    output.flexion = quantise(data.*flexion_arc, arc, config.step_size);
end