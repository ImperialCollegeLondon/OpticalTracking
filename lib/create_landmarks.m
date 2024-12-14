function landmarks = create_landmarks(landmark_raw_data, label)


%% Tibia
id = find_landmark(landmark_raw_data, {'tibia', 'medial'});
landmarks.tibia.medial = extract_from_label(landmark_raw_data(id).probes, label.probe);

id = find_landmark(landmark_raw_data, {'tibia', 'lateral'});
landmarks.tibia.lateral = extract_from_label(landmark_raw_data(id).probes, label.probe);

id = find_landmark(landmark_raw_data, {'tibia', 'distal'});
landmarks.tibia.distal = extract_from_label(landmark_raw_data(id).probes, label.probe);

landmarks.tibia.tracker = extract_from_label(landmark_raw_data(1).probes, label.tibia);


%% Femur
id = find_landmark(landmark_raw_data, {'femur', 'medial'});
landmarks.femur.medial = extract_from_label(landmark_raw_data(id).probes, label.probe);

id = find_landmark(landmark_raw_data, {'femur', 'lateral'});
landmarks.femur.lateral = extract_from_label(landmark_raw_data(id).probes, label.probe);

id = find_landmark(landmark_raw_data, {'femur', 'proximal'});
landmarks.femur.proximal = extract_from_label(landmark_raw_data(id).probes, label.probe);

landmarks.femur.tracker = extract_from_label(landmark_raw_data(1).probes, label.femur);


%% Patella
id = find_landmark(landmark_raw_data, {'patella', 'medial'});
if ~any(id)
    %% There's no patella. create a dummy
    landmarks.patella.medial = empty_probe();
    landmarks.patella.lateral = empty_probe();
    landmarks.patella.distal= empty_probe();
    landmarks.patella.tracker = empty_probe();
    return
end
landmarks.patella.medial = extract_from_label(landmark_raw_data(id).probes, label.probe);

id = find_landmark(landmark_raw_data, {'patella', 'lateral'});
landmarks.patella.lateral = extract_from_label(landmark_raw_data(id).probes, label.probe);

id = find_landmark(landmark_raw_data, {'patella', 'distal'});
landmarks.patella.distal = extract_from_label(landmark_raw_data(id).probes, label.probe);

landmarks.patella.tracker = extract_from_label(landmark_raw_data(1).probes, label.patella);

end

function result = find_landmark(landmarks, bone_position)
% Looks for file names that include, e.g., "tibia" and "medial".
% If none found, looks for TM (first letters capitalised).
match = contains({landmarks.name}, bone_position{1}, "IgnoreCase",true) & contains({landmarks.name}, bone_position{2}, IgnoreCase=true);
if ~any(match)
    abbreviation = cellfun(@(x) x(1), bone_position);
    result = strcmpi({landmarks.name}, abbreviation);
else
    result = match;
end
end

function probes = empty_probe()
    probes.label = [];
    probes.Rx = [];
    probes.Ry = [];
    probes.Rz = [];
    probes.Tx = [];
    probes.Ty = [];
    probes.Tz = [];
    probes.rotations = [];
    probes.rotations_mean = [];
    probes.translations = [];
    probes.translations_mean = [];
end
