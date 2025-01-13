function [data, transforms, idx_interpolation] = read_run_print_to_file(fp_digitisation, trackers, config)
    [root, ~, ~] = fileparts(fp_digitisation);
    knee_states = get_root_files(root, {'digit', 'calibr'}); % Second argument is a list of folders to exclude.
    % 'digit' covers variations of digitisation, digitize, digitise, etc.

    
    %% Load experiment data
    for k = 1:numel(knee_states)
        state = knee_states(k);
        state_clean = clean_specimen_condition(state.name);
        fp_data = fullfile(state.folder, state.name);
        try
            [data_raw, ~, idx_interpolation] = load_data(fp_data, config.label);
        catch ME
            if any(contains({ME.stack.name}, "label", "IgnoreCase",true))
                warning("Insufficient tracker data recorded. Check that you are recording all trackers.");
                continue;
            end
        end
    
        %% Run

        if config.debug
            fprintf("%s:\n", state_clean);
        end
        [datum, transforms.(state_clean)] = generate_intraspecimen_jcs(data_raw, trackers, config);

        if config.print_single_runs
            print_to_file(datum, fp_data)
        end
    
        % Clean the names a little bit
        data.(state_clean) = datum;
    end
end