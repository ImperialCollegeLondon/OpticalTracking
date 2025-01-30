classdef Landmark
    properties
        name
        probes % {mustBeA(probes, 'Marker')} = Marker.default("", "");
    end
    methods
        function landmark = Landmark(name, marker)
            landmark.name = name;
            landmark.probes = marker;
        end
        function result = contains(obj, bone_position)
            % Looks for file names that include, e.g., "tibia" and "medial".
            % If none found, looks for TM (first letters capitalised).
            filenames = {obj.name};

            % Match filename to whole word.
            bone = contains(filenames, bone_position{1}, "IgnoreCase",true);
            pos = contains(filenames, bone_position{2}, "IgnoreCase",true);
            if any(bone & pos)
                result = Option(obj(bone & pos));
                return
            end

            one_letter = cellfun(@(x) x(1), bone_position);
            match_one_letter = strcmpi(filenames, one_letter);
            if any(match_one_letter)
                result = Option(obj(match_one_letter));
                return
            end

            % Attempt increasing lengths of the words
            substrings = @(word) arrayfun(@(n) word(1:n), length(word):-1:2, 'UniformOutput', false);
            all_substrings = cellfun(substrings, bone_position, 'UniformOutput', false);


            bone = contains(filenames, all_substrings{1}, "IgnoreCase",true);
            pos = contains(filenames, all_substrings{2}, "IgnoreCase",true);
            result = Option(obj(bone & pos));
        end
    end
end