classdef JCS
    properties
        trajectories
    end
    properties
        config
    end
    methods (Static)
        function jcs = new(digitisation)
            config = digitisation.config;
            digitisation_transforms = digitisation.transforms;
            states = get_root_files(digitisation.filepath, config.digitisation).unwrap();
            i = 1;
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
                    trajectory = calculate_jcs(trackers(:, lc), loading_condition, digitisation_transforms, config);
                    trajectories(i) = trajectory;
                    i = i + 1;
                end
            end

            jcs = JCS(trajectories, config);
        end
    end
    methods
        function self = JCS(trajectories, config)
            self.trajectories = trajectories;
            self.config = config;
        end
    end
end


% jcs.interpolate(config.fill_missing_raw_data())
%
% signal = setdiff(fieldnames(datum), "name");
% idx_interpol = cell(numel(datum), numel(signal));
% for lc = 1:numel(datum)
%     for sg = 1:numel(signal)
%         [datum(lc).(signal(sg)), idx_interpol{lc, sg}] = config.fill_missing_raw_data(datum(lc).(signal(sg)));
%     end
% end
% if config.enable_raw_plot
%     plot_raw(datum, config, idx_interpol);
% end
%
% if config.print_single_runs, print_to_file(datum, fp_data), end
%
% data.(state_clean) = datum;
function trajectory = calculate_jcs(trackers, loading_condition, digitisation_transforms, config)
    %% Apply the tracker transforms to the data
    input.name = loading_condition;
    config.specimen.loading_condition = loading_condition;

    label = trackers.camera().get_possible_labels(config.camera_labels);

    input.tibia = trackers.with_label(label.tibia);
    input.femur = trackers.with_label(label.femur);
    input.patella = trackers.with_label(label.patella);
    if (input.femur.is_none() && input.tibia.is_none()) || (input.femur.is_none() && input.patella.is_none())
        return
    end
    trajectory = grood_and_suntay(input, digitisation_transforms, config);
end
