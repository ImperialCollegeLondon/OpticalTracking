function [trackers, landmarks] = create_trackers(digitisation, config)
    %% Create trackers
    % Clean up headers and create a nicer structure
    landmark_raw = new_probe(digitisation, config);
    % Assign the rigid body landmarks using the probe
    landmarks = create_landmarks(landmark_raw, config);
    % Calculate bone to tracker transforms in global coordinate system
    trackers = bone_to_tracker_transform(landmarks, config);
end