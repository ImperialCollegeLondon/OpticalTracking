classdef Digitisation < handle
    properties
        config
        trackers Tracker
        filepath
        bone
        transforms
    end
    methods (Static)
        function digitisation = new(filepath, config) % => Option<Digitisation>
            digitisation = Option.None;
            folder = get_folder(filepath, config.digitisation);
            root = folder.map(@fileparts);

            if root.is_none()
                return
            end
            root = root.unwrap();

            config.is_right_knee = get_knee_side(root, config.right, config.left) ...
                .expect("Could not determine knee side. Check defaults.m => config.right and config.left for instructions");

            trackers = load_data(folder.unwrap(), config);
            if trackers.is_none()
                return;
            end
            digitisation = Option(Digitisation(trackers.unwrap(), root, config));
        end


    end

    methods (Access = private)
        function self = Digitisation(trackers, filepath, config)
            self.trackers = trackers;
            self.config = config;
            self.filepath = filepath;
        end
    end
end

function path = get_folder(filepath, folders)
    mask = contains({filepath.name}, folders , "IgnoreCase",true);
    if sum(mask) > 1 % There's more than 1 digitisation file
        mask(1:find(mask, 1, "last")-1) = false; % Pick the last one
        warning("Found more than one digitisation folder. Using '%s'", filepath(mask).name);
    end
    path = fullfile(filepath(mask).folder, filepath(mask).name);
    path = Option(path);
end
