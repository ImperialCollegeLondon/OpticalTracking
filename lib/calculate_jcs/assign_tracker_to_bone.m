function [out , bones] = assign_tracker_to_bone(trackers, config)
    label = trackers.camera().get_possible_labels(config.camera_labels);
    bones.tibia.medial = trackers.contains({'tibia', 'medial'});
    bones.tibia.lateral = trackers.contains({'tibia', 'lateral'});
    bones.tibia.distal = trackers.contains({'tibia', 'distal'});
    bones.tibia.tracker = Option(trackers(1));

    %% Femur
    bones.femur.medial = trackers.contains({'femur', 'medial'});
    bones.femur.lateral = trackers.contains({'femur', 'lateral'});
    bones.femur.proximal = trackers.contains({'femur', 'proximal'});
    bones.femur.tracker = Option(trackers(1));

    %% Patella
    bones.patella.medial = trackers.contains({'patella', 'medial'});
    bones.patella.lateral = trackers.contains({'patella', 'lateral'});
    bones.patella.distal = trackers.contains({'patella', 'distal'});
    bones.patella.inferior = trackers.contains({'patella', 'inferior'});
    bones.patella.superior = trackers.contains({'patella', 'superior'});
    bones.patella.tracker = Option(trackers(1));

    % Calculate bone to tracker transforms in global coordinate system
    out = bone_to_tracker_transform(bones, config);
end
