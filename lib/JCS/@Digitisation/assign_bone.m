function self = assign_bone(self)
    trackers = self.trackers;
    config = self.config;
    label = trackers.camera().get_possible_labels(config.camera_labels);

    t_medial = trackers.contains({'tibia', 'medial'}).and_then(@(x) x.with_label(label.probe));
    t_lateral = trackers.contains({'tibia', 'lateral'}).and_then(@(x) x.with_label(label.probe));
    t_distal = trackers.contains({'tibia', 'distal'}).and_then(@(x) x.with_label(label.probe));
    t_tracker = trackers(:, 1).with_label(label.tibia);
    self.bone.tibia = Tibia(t_medial, t_lateral, t_distal, t_tracker);
    %% Femur
    f_medial = trackers.contains({'femur', 'medial'}).and_then(@(x) x.with_label(label.probe));
    f_lateral = trackers.contains({'femur', 'lateral'}).and_then(@(x) x.with_label(label.probe));
    f_proximal = trackers.contains({'femur', 'proximal'}).and_then(@(x) x.with_label(label.probe));
    f_tracker = trackers(:, 1).with_label(label.femur);
    self.bone.femur = Femur(f_medial, f_lateral, f_proximal, f_tracker);

    %% Patella
    p_medial   = trackers.contains({'patella', 'medial'}).and_then(@(x) x.with_label(label.probe));
    p_lateral  = trackers.contains({'patella', 'lateral'}).and_then(@(x) x.with_label(label.probe));
    p_distal   = trackers.contains({'patella', 'distal'}).and_then(@(x) x.with_label(label.probe));
    p_inferior = trackers.contains({'patella', 'inferior'}).and_then(@(x) x.with_label(label.probe));
    p_superior = trackers.contains({'patella', 'superior'}).and_then(@(x) x.with_label(label.probe));
    p_tracker  = trackers(:, 1).with_label(label.patella);
    self.bone.patella = Patella(p_medial, p_lateral, p_distal, p_inferior, p_superior, p_tracker);

    % Calculate bone to tracker transforms in global coordinate system
    self.transforms = bone_to_tracker_transform(self.bone, config);
end

