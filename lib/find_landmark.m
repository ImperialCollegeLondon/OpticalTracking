function result = find_landmark(landmarks, bone_position)
% Looks for file names that include, e.g., "tibia" and "medial".
% If none found, looks for TM (first letters capitalised).
match_1 = contains({landmarks.name}, bone_position{1}, "IgnoreCase",true) & contains({landmarks.name}, bone_position{2}, IgnoreCase=true);
if ~any(match_1)
    abbreviation = cellfun(@(x) x(1), bone_position);
    result = strcmpi({landmarks.name}, abbreviation);
    disp("Name not found. using abbreviation");
else
    result = match_1;
end
end
