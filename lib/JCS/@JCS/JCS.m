classdef JCS
    properties
        trajectories
    end
    properties(Access = private)
        digitisation
        config
    end
    methods (Static)
        function jcs = new(digitisations)
            i = 1;
            for d = 1:numel(digitisations)
                digitisation = digitisations(d);
                config = digitisation.config;
                digitisation_transforms = digitisation.transforms;
                module = digitisation.module;
                states = get_root_files(digitisation.filepath, config.digitisation).unwrap();
                for st = 1:numel(states)
                    state = states(st);
                    fp_data = fullfile(state.folder, state.name);
                    trackers = load_data(fp_data, config);
                    if trackers.is_none()
                        warning('No csv files in %s', fp_data)
                        continue;
                    end
                    trackers = trackers.unwrap();

                    config.specimen.state = clean_specimen_condition(state.name);

                    loading_conditions = unique({trackers.Landmark});
                    for lc = 1:numel(loading_conditions)
                        loading_condition = loading_conditions{lc};
                        switch module
                            case Module.Knee
                                input.name = loading_condition;
                                config.specimen.loading_condition = loading_condition;

                                label = trackers(:, lc).camera().get_possible_labels(config.camera_labels);

                                input.tibia = trackers(:, lc).with_label(label.tibia);
                                input.femur = trackers(:, lc).with_label(label.femur);
                                input.patella = trackers(:, lc).with_label(label.patella);
                                if (input.femur.is_none() && input.tibia.is_none()) || (input.femur.is_none() && input.patella.is_none())
                                    continue
                                end
                                trajectory = Knee.grood_and_suntay(input, digitisation_transforms, config);
                            case Module.Hip
                                error("Not yet implemented");
                        end
                        trajectories(i) = trajectory;
                        i = i + 1;
                    end
                end
            end

            jcs = JCS(trajectories, digitisation, config);
        end
    end
    methods
        function self = JCS(trajectories, digitisation, config)
            self.trajectories = trajectories;
            self.config = config;
            self.digitisation = digitisation;
        end
    end
end

