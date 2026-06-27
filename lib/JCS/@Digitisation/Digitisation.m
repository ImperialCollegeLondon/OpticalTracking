classdef Digitisation < handle
    properties
        specimen
        config
        trackers Tracker
        is_right_knee
        filepath
        bone
        transforms
        module
        angle_offset
        surface
        optimisation
    end
    methods (Static)
        function digitisations = new(root, config, module) % => Digitisation
            arguments
                root
                config
                module Module
            end

            specimen_list = get_root_files(root, {'result', 'problem'}).unwrap(); % Get all files in root and exclude any folders that include `result`
            specimen_list = specimen_list([specimen_list.isdir]);
            specimen_folders = fullfile({specimen_list.folder}, {specimen_list.name});
            prev_specimen = [];
            for i = 1:numel(specimen_folders)
                % digitisations(i) = Option.None;
                specimen_name = get_specimen_name(specimen_list(i).name);
                fprintf("%d. Specimen: %s\n", i, specimen_name);

                digitisation = from_specimen(specimen_name, specimen_folders{i}, config, module);
                switch module
                    case Module.Knee
                        if strcmp(specimen_name, prev_specimen)
                            prev_digit = digitisations(i-1);
                            Knee.assign_bone(digitisation, prev_digit);
                        else
                            Knee.assign_bone(digitisation);
                        end

                    case Module.Hip
                        Hip.assign_bone(digitisation);
                end

                if isempty(digitisation)
                    warning("Failed to complete digitisation");
                    continue
                end
                digitisations(i) = digitisation;

                prev_specimen = specimen_name;
            end


        end


    end
    methods
        function path = root(self) % => [&str]
            paths = {self.filepath};
            path = fileparts(paths{1});
        end
    end

    methods (Access = private)
        function self = Digitisation(specimen, trackers, filepath, config, module)
            self.specimen = string(specimen);
            self.trackers = trackers;
            self.config = config;
            self.filepath = filepath;
            self.module = module;
            self.optimisation = eye(4);
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

function digitisation = from_specimen(specimen_name, path_folder, config, module)
    filepath = get_root_files(path_folder, {});
    if filepath.is_none, return; end
    filepath = filepath.unwrap();
    folder = get_folder(filepath, config.digitisation);
    root = folder.map(@fileparts);

    if root.is_none(), return; end

    trackers = load_data(folder.unwrap(), config);
    if trackers.is_none(), return; end
    digitisation = Digitisation(specimen_name, trackers.unwrap(), root.unwrap(), config, module);

    digitisation.is_right_knee = get_knee_side(root.unwrap(), config.right, config.left) ...
        .expect("Could not determine knee side. Check defaults.m => config.right and config.left for instructions");
end
