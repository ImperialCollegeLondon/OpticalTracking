function [out , bones] = assign_tracker_to_bone(trackers, config)
    label = trackers.camera().get_possible_labels(config.camera_labels);

    bones.tibia.medial = trackers.contains({'tibia', 'medial'}).and_then(@(x) x.with_label(label.probe));
    bones.tibia.lateral = trackers.contains({'tibia', 'lateral'}).and_then(@(x) x.with_label(label.probe));
    bones.tibia.distal = trackers.contains({'tibia', 'distal'}).and_then(@(x) x.with_label(label.probe));
    bones.tibia.tracker = trackers(:, 1).with_label(label.tibia);

    %% Femur
    bones.femur.medial = trackers.contains({'femur', 'medial'}).and_then(@(x) x.with_label(label.probe));
    bones.femur.lateral = trackers.contains({'femur', 'lateral'}).and_then(@(x) x.with_label(label.probe));
    bones.femur.proximal = trackers.contains({'femur', 'proximal'}).and_then(@(x) x.with_label(label.probe));
    bones.femur.tracker = trackers(:, 1).with_label(label.femur);

    %% Patella
    bones.patella.medial = trackers.contains({'patella', 'medial'}).and_then(@(x) x.with_label(label.probe));
    bones.patella.lateral = trackers.contains({'patella', 'lateral'}).and_then(@(x) x.with_label(label.probe));
    bones.patella.distal = trackers.contains({'patella', 'distal'}).and_then(@(x) x.with_label(label.probe));
    bones.patella.inferior = trackers.contains({'patella', 'inferior'}).and_then(@(x) x.with_label(label.probe));
    bones.patella.superior = trackers.contains({'patella', 'superior'}).and_then(@(x) x.with_label(label.probe));
    bones.patella.tracker = trackers(:, 1).with_label(label.patella);

    % Calculate bone to tracker transforms in global coordinate system
    out = bone_to_tracker_transform(bones, config);
end

