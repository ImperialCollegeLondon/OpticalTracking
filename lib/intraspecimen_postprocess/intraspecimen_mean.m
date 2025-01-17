function specimen_mean = intraspecimen_mean(input, config)
% INTRASPECIMEN_MEAN   Splits dataset into runs and calculates their mean.
%
% Splits the dataset into individual runs by identifying
% the minima (using the function `find_minima()`) and removing the start
% and end tails of the data. The values are then quantised based on the 
% specified `step_size`, and the mean is computed across runs.
%
% INPUTS:
%   `input`     - input data.
%                table | matrix
%                Tables are expected to have a column named "flexion".
%                If "flexion" is not found, assumes the first column is flexion.
%   config      - must include fields `step_size` and `split_flex_ext`

    step_size = config.step_size;
    separate = config.split_flex_ext;
    
    if isempty(input)
        specimen_mean = input;
        return;
    end
    
    try
        flex_ext = input.flexion;
    catch
        warning("Did not find flexion header in input table. Assuming the first column is flexion.")
        flex_ext = input(:,1);
    end
    
    if istable(input)
        data_arr = table2array(input);
        headers = input.Properties.VariableNames;
    else
        data_arr = input;
    end
    

    
    %% Split runs
    [split_runs, no_tails] = split_run(flex_ext, config);
    split_runs_idx = nonzero_to_one(split_runs); % Don't use logical() because it gives an error on NaN. Don't use ~isnan() because we need to maintain all the time points.
    
    
    data_reshaped = reshape(data_arr, [height(data_arr), 1, width(data_arr)]); % time, empty, column (flexion, varus, etc). 634 x 1 x 6
    data_masked = data_reshaped .* split_runs_idx .* no_tails; % 634 x 5 x 6 time, runs, column (flexion, varus, etc).
    data = data_masked(:, no_tails, :);
    has_datum = any(data_masked,2);
    has_datum = has_datum(:,1);
    data = data(has_datum, :, :); % 620 x 3 x 6
    
    arc = flex_ext(has_datum); % Flexion-extension arc excluding tails
    
    %% Separate flexion from extension
    if separate
        % Find the flexion/extension arcs and remove any tails
        flexion_extension_arc = split_runs_idx(:, no_tails);
        flexion_extension_arc = flexion_extension_arc(has_datum, :);
    
        [~, idx_peak] = max(data);
        idx_peak_flexion = idx_peak(:,:, 1);
    
        % Everything from the start up to peak flexion is 'not extension'. We set
        % them all to zero. The values left are flexion.
        not_extension = (1:length(flexion_extension_arc))' <= idx_peak_flexion;
        extension_arc = flexion_extension_arc;
        extension_arc(not_extension) = 0;
        flexion_arc = flexion_extension_arc - extension_arc; % Could use xor(), but logical operations when you have NaN tend to cause trouble.
    
        quantised_extension = flip(quantise(data.*extension_arc, arc, step_size));
        quantised_flexion = quantise(data.*flexion_arc, arc, step_size);
        if ndims(quantised_extension) == 3 || ndims(quantised_flexion) == 3
        quantised_extension_means = clean(mean_nonzero(quantised_extension, 2)); 
        quantised_flexion_means = clean(mean_nonzero(quantised_flexion, 2));
        else
            quantised_extension_means = quantised_extension;
            quantised_flexion_means = quantised_flexion;
        end

    else
        quantised_flex_ext = quantise(data, arc, step_size);
        if ndims(quantised_flex_ext) == 3
            quantised_means = clean(mean_nonzero(quantised_flex_ext, 2)); % 98 x 1 x 6 => 98 x 6 and remove empty quanta
        else
            quantised_means = quantised_flex_ext;
        end
    end
    
    if separate
        specimen_mean.extension = quantised_extension_means;
        specimen_mean.flexion = quantised_flexion_means;
    else
        specimen_mean = quantised_means;
    end
end


function R = clean(data)
% Squeeze and remove empty quanta. If they are not removed, later on we end
% up with weird values where the gaps were.
    R = squeeze(data);
    % R = R(any(R, 2), :); % Maybe we should leave the gaps.
end
function quantised_runs = quantise(data, arc, step_size)
% Quantise flexion
data = reshape(data, [1 size(data)]); % 1 x 620 x 3 x 6
flex_max = round(max(arc));
flex_min = round(min(arc));
flex_deg = flex_min:step_size:flex_max;
flexion_quantised = (round(arc / step_size) * step_size == flex_deg)';

% Find the mean across the quantisations
quantised_runs = mean_nonzero(flexion_quantised .* data, 2);
quantised_runs = squeeze(quantised_runs); % 98 x 3 x 6
% To visualise the empty flexion angles. Each page is one run:
% permute(quantised_runs, [1 3 2]);
end

function M = mean_nonzero(data, D)
% `data` is (recorded data) x (quantised flexion)  x run number x direction (flexion, varus, external,lateral,anterior,superior)
%                  600      x        98            x   3        x    6
% the first 2 dimensions are a big map of how each datum should map to a quantised value
nonzero_sum = sum(data, D);
nonzero_count = sum(data ~= 0, D);
M = nonzero_sum ./ max(nonzero_count, 1); % 98 x 1 x 3 x 6
end

function R = nonzero_to_one(input)
    R = zeros(size(input)); 
    R(~isnan(input) & input ~= 0) = 1; 
end
