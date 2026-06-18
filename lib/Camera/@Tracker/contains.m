function result = contains(self, bone_position)
% Looks for file names that include, e.g., "tibia" and "medial".
% If none found, looks for TM (first letters capitalised).
    landmarks = {self.Landmark};


    % Attempt increasing lengths of the words
    substrings = @(word) arrayfun(@(n) word(1:n), length(word):-1:1, 'UniformOutput', false);
    all_substrings = cellfun(substrings, bone_position, 'UniformOutput', false);
    % all_substrings = cellfun(@(x) x(2:end-1), all_substrings, 'UniformOutput', false);


    bones_and_positions = split(landmarks, {'_', ' ', '-'});

    if size(bones_and_positions, 3) > 2
        error("Unable to automatically assign digitisation files to landmark.\nNaming convention for multiple digitisations of same landmark is off. Check it's something like 'femur_proximal1'")
    end

    if size(bones_and_positions, 3) == 2
        bones = bones_and_positions(:, :, 1);
        positions = bones_and_positions(:, :, 2);
        bone = contains(bones, all_substrings{1}, "IgnoreCase",true);
        pos = contains(positions, all_substrings{2}, "IgnoreCase",true);
    elseif size(bones_and_positions, 3) == 1
        % Should only be reachable if the files are named "td1",
        % "td2", etc.
        % Could be reached if files are 'tibiadistal'. Untested
        bone = contains(bones_and_positions, all_substrings{1}, "IgnoreCase", true);
        pos = contains(bones_and_positions, all_substrings{2}, "IgnoreCase", true);
    else
        error("Uh-oh. This should be unreachable. Something is terribly wrong with digitisation file names!")
    end

    result = Option(self(bone & pos));
end
