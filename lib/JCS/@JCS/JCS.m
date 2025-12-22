classdef JCS
    properties
        trajectories
    end
    methods (Static)
        function data = new(digitisation)
            config = digitisation.config;
            knee_states = get_root_files(digitisation.filepath, config.digitisation).unwrap();
            % try
            for k = 1:numel(knee_states)
                state = knee_states(k);
                fp_data = fullfile(state.folder, state.name);
                trackers = load_data(fp_data, config);
                if trackers.is_none()
                    warning('No csv files in %s', fp_data)
                    continue;
                end
                trackers = trackers.unwrap();

                state_clean = clean_specimen_condition(state.name);
                config.specimen.state = state_clean;

                self  = JCS(trackers, digitisation.transforms, config);

                signal = setdiff(fieldnames(datum), "name");
                idx_interpol = cell(numel(datum), numel(signal));
                for lc = 1:numel(datum)
                    for sg = 1:numel(signal)
                        [datum(lc).(signal(sg)), idx_interpol{lc, sg}] = config.fill_missing_raw_data(datum(lc).(signal(sg)));
                    end
                end
                if config.enable_raw_plot
                    plot_raw(datum, config, idx_interpol);
                end

                if config.print_single_runs, print_to_file(datum, fp_data), end

                data.(state_clean) = datum;
            end
        end
    end
    methods
        function self = JCS(trackers, digitisation_transforms, config)
            %% Apply the tracker transforms to the data
            loading_conditions = unique({trackers.Landmark});
            for i = 1:numel(loading_conditions)
                loading_condition = loading_conditions{i};
                input.name = loading_condition;
                config.specimen.loading_condition = loading_condition;

                label = trackers.camera().get_possible_labels(config.camera_labels);

                input.tibia = trackers(:, i).with_label(label.tibia);
                input.femur = trackers(:, i).with_label(label.femur);
                input.patella = trackers(:, i).with_label(label.patella);
                if (input.femur.is_none() && input.tibia.is_none()) || (input.femur.is_none() && input.patella.is_none())
                    continue
                end
                trajectory = grood_and_suntay(input, digitisation_transforms, config);
                trajectories(i) = trajectory;
            end
            self.trajectories = trajectories;
        end


    end
end
