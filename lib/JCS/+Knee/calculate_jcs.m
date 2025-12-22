function trajectory = calculate_jcs(trackers, loading_condition, digitisation_transforms, config)
    %% Apply the tracker transforms to the data
    input.name = loading_condition;
    config.specimen.loading_condition = loading_condition;

    label = trackers.camera().get_possible_labels(config.camera_labels);

    input.tibia = trackers.with_label(label.tibia);
    input.femur = trackers.with_label(label.femur);
    input.patella = trackers.with_label(label.patella);
    if (input.femur.is_none() && input.tibia.is_none()) || (input.femur.is_none() && input.patella.is_none())
        return
    end
    trajectory = Knee.grood_and_suntay(input, digitisation_transforms, config);
end
