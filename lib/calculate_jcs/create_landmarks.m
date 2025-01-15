function landmarks = create_landmarks(landmark_raw_data, config)
%% Create landmarks
% Expects the file names to include both the bone and the position, e.g.,
% tibia-medial or femur_proximal. Doesn't care about order or what
% separates the words.
%
% If neither can be found, it looks for the first letter of each word,
% e.g., for tibia medial it looks for TM.
% 
% For Patella, it needs either distal or both inferior and superior.

label = config.label;
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
try
    id = find_landmark(landmark_raw_data, {'patella', 'medial'});
catch
    id = false;
end
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

try
    id = find_landmark(landmark_raw_data, {'patella', 'distal'});
    landmarks.patella.distal = extract_from_label(landmark_raw_data(id).probes, label.probe);
catch
    id = find_landmark(landmark_raw_data, {'patella', 'inferior'});
    landmarks.patella.inferior = extract_from_label(landmark_raw_data(id).probes, label.probe);

    id = find_landmark(landmark_raw_data, {'patella', 'superior'});
    landmarks.patella.superior = extract_from_label(landmark_raw_data(id).probes, label.probe);
end

landmarks.patella.tracker = extract_from_label(landmark_raw_data(1).probes, label.patella);

end

function result = find_landmark(files, bone_position)
% Looks for file names that include, e.g., "tibia" and "medial".
% If none found, looks for TM (first letters capitalised).
filenames = {files.name};

% Match filename to whole word.
bone = contains(filenames, bone_position{1}, "IgnoreCase",true);
pos = contains(filenames, bone_position{2}, "IgnoreCase",true);
if any(bone & pos)
    result = bone & pos;
    return
end

one_letter = cellfun(@(x) x(1), bone_position);
match_one_letter = strcmpi(filenames, one_letter);
if any(match_one_letter)
    result = match_one_letter;
    return
end

% Attempt increasing lengths of the words
substrings = @(word) arrayfun(@(n) word(1:n), length(word):-1:2, 'UniformOutput', false);
all_substrings = cellfun(substrings, bone_position, 'UniformOutput', false);


bone = contains(filenames, all_substrings{1}, "IgnoreCase",true);
pos = contains(filenames, all_substrings{2}, "IgnoreCase",true);
result = bone & pos;

if ~any(result)
    error("Unable to determine landmarks from file names.")
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
