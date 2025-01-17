function [trackers, landmarks] = create_trackers(digitisation, config)
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