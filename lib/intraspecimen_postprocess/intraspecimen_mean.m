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
%   config      - must include fields `step_size: float` and `split_flex_ext: bool`

    
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
    quantised_flex_ext = get_split_runs(data_arr, split_runs_idx, no_tails, config);
    
    %% Don't separate flexion from extension
    if ~config.split_flex_ext
        if ndims(quantised_flex_ext) == 3
            quantised_means = clean_mean(mean_nonzero(quantised_flex_ext, 2)); % 98 x 1 x 6 => 98 x 6 and remove empty quanta
        else
            quantised_means = quantised_flex_ext;
        end
        specimen_mean = quantised_means;
        return
    end

    %% Separate flexion from extension
    quantised_extension = quantised_flex_ext.extension;
    quantised_flexion = quantised_flex_ext.flexion;
    if ndims(quantised_extension) == 3 || ndims(quantised_flexion) == 3
        quantised_extension_means = clean_mean(mean_nonzero(quantised_extension, 2));
        quantised_flexion_means = clean_mean(mean_nonzero(quantised_flexion, 2));
    else
        quantised_extension_means = quantised_extension;
        quantised_flexion_means = quantised_flexion;
    end

    specimen_mean.extension = quantised_extension_means;
    specimen_mean.flexion = quantised_flexion_means;
end