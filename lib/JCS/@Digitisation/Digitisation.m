classdef Digitisation < handle
    properties
        config
        trackers Tracker
        filepath
        bone
        transforms
        module
    end
    methods (Static)
        function digitisation = new(root, config, module) % => Option<Digitisation>
            specimen_list = get_root_files(root, {'result', 'problem'}).unwrap(); % Get all files in root and exclude any folders that include `result`
            specimen_folders = fullfile({specimen_list.folder}, {specimen_list.name});
            digitisation = Option.None;
            for i = 1:numel(specimen_folders)
                specimen_name = get_specimen_name(specimen_list(i).name);
                config.specimen.name = specimen_name;
                fprintf("%d. Specimen: %s\n", i, specimen_name);
                filepath = get_root_files(specimen_folders{i}, {});
                if filepath.is_none
                    continue
                end
                filepath = filepath.unwrap();
                folder = get_folder(filepath, config.digitisation);
                root = folder.map(@fileparts);

                if root.is_none()
                    continue
                end
                root = root.unwrap();

                config.is_right_knee = get_knee_side(root, config.right, config.left) ...
                    .expect("Could not determine knee side. Check defaults.m => config.right and config.left for instructions");

                trackers = load_data(folder.unwrap(), config);
                if trackers.is_none()
                    continue
                end
                n_digitisation = Digitisation(trackers.unwrap(), root, config, module);
                switch module
                    case Module.Knee
                        Knee.assign_bone(n_digitisation);
                    case Module.Hip
                        error("Not implemented")
                end

                n_digitisation = Option(n_digitisation);
                if n_digitisation.is_none()
                    warning("Failed to complete digitisation");
                    continue
                end
                digitisation(i) = n_digitisation.unwrap();

            end
        end


    end
    methods
        function path = root(self)
            path = fileparts(self(1).filepath);
        end
    end

    methods (Access = private)
        function self = Digitisation(trackers, filepath, config, module)
            self.trackers = trackers;
            self.config = config;
            self.filepath = filepath;
            self.module = module;
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
