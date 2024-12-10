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
end

function result = find_landmark(landmarks, bone_position)
% Looks for file names that include, e.g., "tibia" and "medial".
% If none found, looks for TM (first letters capitalised).
match = contains({landmarks.name}, bone_position{1}, "IgnoreCase",true) & contains({landmarks.name}, bone_position{2}, IgnoreCase=true);
if ~any(match)
    abbreviation = cellfun(@(x) x(1), bone_position);
    result = strcmpi({landmarks.name}, abbreviation);
    disp("Name not found. using abbreviation");
else
    result = match;
end
end
