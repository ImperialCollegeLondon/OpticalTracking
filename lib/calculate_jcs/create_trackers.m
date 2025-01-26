function [trackers, assigned_markers] = create_trackers(digitisation, config)
    %% Create trackers
    % Clean up headers and create a nicer structure
    landmark = new_landmark(digitisation, config);
    
    % Assign the rigid body landmarks using the probe
    if config.is_polaris
        label = config.polaris;
    else
        label = config.certus;
    end
    assigned_markers = assign_marker_to_landmark(landmark, label);
    % Calculate bone to tracker transforms in global coordinate system
    trackers = bone_to_tracker_transform(assigned_markers, config);
end