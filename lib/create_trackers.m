function [trackers, landmarks, config] = create_trackers(fp_digitisation, config, label)
    [root, ~, ~] = fileparts(fp_digitisation);
    % knee_states = get_root_files(root, {'digit', 'calibr'}); % Second argument is a list of folders to exclude.
    % 'digit' covers variations of digitisation, digitize, digitise, etc.
    
    knee_side; % Expects right_knees, left_knees to be created here. Should not be done this way. 
    config.is_right_knee = get_knee_side(root, right_knees, left_knees);
    
    % specimen_name = get_specimen_name(root); % Assign specimen name based on folder name.
    %% Load digitisation
    [digitisation, new_config, ~] = load_data(fp_digitisation, label);
    config = merge_config(config, new_config);
    
    if config.is_polaris
        config.label = label.polaris;
    else
        config.label = label.certus;
    end
    %% Create trackers
    % Clean up headers and create a nicer structure
    landmark_raw = organise_data(digitisation, config);
    % Assign the rigid body landmarks using the probe, and create their respective trackers
    landmarks = create_landmarks(landmark_raw, config);
    % Calculate bone to tracker transforms in global coordinate system
    trackers = bone_to_tracker_transform(landmarks, config);
    % %% Visualisation of Landmarks
    % plot_landmarks(landmarks, config.is_right_knee);
end

function config = merge_config(config, new_config)
    fields = fieldnames(new_config);
    for i = 1:numel(fields)
        field = fields{i};
        if ~isfield(config, field)
            config.(field) = new_config.(field);
        end
    end
end