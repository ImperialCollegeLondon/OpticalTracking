function digitisation = assign_bone(digitisation)
    % Uses file names and the config definitions (from defaults.m) to determine which file refers to which bone/location.
    % If you want to create this same setup for another set of bones, modify it as follows:
    % digitisation.bone.humerus.medial = trackers.contains({'humerus', 'medial'}).and_then(@(x) x.with_label(label.probe));
    %                   ^^^^^^^                             ^^^^^^^^^
    % Go into defaults.m and make sure there is a label for each of the new bones you want to introduce.
    arguments
        digitisation Digitisation
    end

    trackers = digitisation.trackers;
    config = digitisation.config;
    label = trackers.camera().get_possible_labels(config.camera_labels);
    %                                             ^^^^^^^^^^^^^^^^^^^^
    %                                        Looks for label definitions here

    %% Femur
    % .contains() takes two arguments: one that describes the bone and one that describes the position. e.g. {'femur', 'medial'}
    % These must be assigned to digitisation.bone.femur.medial, etc. These name definitions are used in Hip.bone_to_tracker_transform
    digitisation.bone.femur.medial = trackers.contains({'femur', 'medial'}).and_then(@(x) x.with_label(label.probe));
    digitisation.bone.femur.lateral = trackers.contains({'femur', 'lateral'}).and_then(@(x) x.with_label(label.probe));
    digitisation.bone.femur.proximal = trackers.contains({'femur', 'proximal'}).and_then(@(x) x.with_label(label.hip)).map(@(x) x.sphere_fit());
    digitisation.bone.femur.tracker = trackers(:, 1).with_label(label.femur);

    % Tibia
    digitisation.bone.tibia.medial = trackers.contains({'tibia', 'medial'}).and_then(@(x) x.with_label(label.probe));
    digitisation.bone.tibia.lateral = trackers.contains({'tibia', 'lateral'}).and_then(@(x) x.with_label(label.probe));
    digitisation.bone.tibia.distal = trackers.contains({'tibia', 'distal'}).and_then(@(x) x.with_label(label.probe));
    digitisation.bone.tibia.tracker = trackers(:, 1).with_label(label.tibia);

    % Hip
    digitisation.bone.hip.asis = trackers.contains({'anterior', 'sis'}).and_then(@(x) x.with_label(label.probe)); %dodgy way to get asis
    digitisation.bone.hip.psis = trackers.contains({'posterior', 'sis'}).and_then(@(x) x.with_label(label.probe)); %dodgy way to get psis
    digitisation.bone.hip.pubic_tubercle = trackers.contains({'pubic', 'tubercle'}).and_then(@(x) x.with_label(label.probe));
    digitisation.bone.hip.origin = digitisation.bone.femur.proximal;
    digitisation.bone.hip.tracker = trackers(:, 1).with_label(label.hip);

    % Calculate bone to tracker transforms in global coordinate system
    digitisation.transforms = Hip.bone_to_tracker_transform(digitisation, config);
end
