classdef JCS
    properties
        specimen
        loading_condition
        state
        transforms
        bones
        config
        module Module
        digitisation
    end
    properties(Access = private)
    end
    methods
        function jcs_solved = solve(self)
            % Alias for grood and suntay
            jcs_solved = [self.grood_and_suntay()];
        end
        function trajectories = grood_and_suntay(self)
            trajectories(numel(self)) = Trajectory();

            % if unique([self.module]) == Module.Knee
            %     [origin, direction] = self.cor_from_tibia();
            % end
            % [centre_of_rotation, direction] = self.cor_from_femur();

            for i = 1:numel(self)
                switch self(i).module
                    case Module.Knee
                        right = self(i).digitisation.is_right_knee;
                        fTt  = self(i).transforms.fTt;
                        hTf  = self(i).transforms.fTp;
                        femur = self(i).bones.femur;
                        tibia = self(i).bones.tibia;
                        patella = self(i).bones.patella;

                        trajectory = Trajectory(self(i).specimen, self(i).state, self(i).loading_condition, false, right);

                        [tf, pf] = Knee.grood_and_suntay(femur, tibia, patella, fTt, hTf, right);
                        % if ~isempty(tf)
                        %     tf.flexion = tf.flexion - self(i).digitisation.angle_offset.tf;
                        % end
                        % if ~isempty(pf)
                        %     pf.flexion = pf.flexion - self(i).digitisation.angle_offset.pf;
                        % end

                        trajectory.add_data('tibiofemoral', tf);
                        trajectory.add_data('patellofemoral', pf);

                        % trajectory.add_transforms('origin', origin{i});
                        % trajectory.add_transforms('direction', direction{i});

                        trajectory.add_transforms('gTfi', self(i).transforms.gTfi);
                        trajectory.add_transforms('gTti', self(i).transforms.gTti);
                        trajectory.add_transforms('gTpi', self(i).transforms.gTpi);
                        trajectory.add_transforms('fTt', self(i).transforms.fTt);
                        trajectory.add_transforms('fTp', self(i).transforms.fTp);
                        trajectory.add_transforms('fTts', self(i).transforms.fTts);

                        trajectories(i) = trajectory;
                    case Module.Hip
                        right = self(i).digitisation.is_right_knee;
                        % These are knee definitions. Update to hip
                        fTt  = self(i).transforms.fTt;
                        hTf  = self(i).transforms.hTf;
                        femur = self(i).bones.femur;
                        tibia = self(i).bones.tibia;
                        hip = self(i).bones.hip;
                        strays = self(i).bones.strays;

                        trajectory = Trajectory(self(i).specimen, self(i).state, self(i).loading_condition, false, right);

                        [tf, fa] = Hip.grood_and_suntay(femur, tibia, hip, fTt, hTf, right);
                        trajectory.add_data('tibiofemoral', tf);
                        trajectory.add_data('femoracetabular', fa);

                        if ~isempty(tf)
                            flexion = tf.flexion;
                        else
                            flexion = fa.flexion;
                        end

                        if strays.is_some
                            strays = strays.unwrap();
                            for n = 1:numel(strays)
                                str = strjoin(['stray_' string(n)], '');
                                tab = stray_motion(strays(n), femur, right);
                                trajectory.add_data(str, tab);
                            end
                        end

                        trajectory.add_transforms('gTfi', self(i).transforms.gTfi);
                        trajectory.add_transforms('gTti', self(i).transforms.gTti);
                        trajectory.add_transforms('gThi', self(i).transforms.gThi);
                        trajectory.add_transforms('fTt', self(i).transforms.fTt);
                        trajectory.add_transforms('hTf', self(i).transforms.hTf);

                        trajectories(i) = trajectory;
                end
            end
        end
        function jcs_solved = helical_axis(self)
            error("Not yet implemented")
        end
        function jcs_solved = sara(self)
            error("Not yet implemented")
        end
    end

    methods (Static)
        function jcs = new(digitisations)
            i = 1;
            for d = 1:numel(digitisations)
                digitisation = digitisations(d);
                config = digitisation.config;
                digitisation_transforms = digitisation.transforms;
                module = digitisation.module;
                states = get_root_files(digitisation.filepath, config.digitisation_files()).unwrap();
                states = states([states.isdir]);
                for st = 1:numel(states)
                    state = states(st);
                    fp_data = fullfile(state.folder, state.name);
                    [trackers, strays] = load_dir(fp_data, config);
                    if trackers.is_none()
                        warning('No csv files in %s', fp_data)
                        continue;
                    end
                    trackers = trackers.unwrap();

                    loading_conditions = unique({trackers.Landmark});
                    for lc = 1:numel(loading_conditions)
                        loading_condition = loading_conditions{lc};
                        switch module
                            case Module.Knee
                                [transforms, bones] = Knee.calculate_transforms(trackers(:, lc), strays{lc}, digitisation_transforms, config);
                            case Module.Hip
                                [transforms, bones] = Hip.calculate_transforms(trackers(:, lc), strays{lc}, digitisation_transforms, config);
                        end

                        jcs(i) = JCS(transforms, bones, digitisation, config);
                        jcs(i).module = module;
                        jcs(i).state = string(clean_specimen_condition(state.name));
                        jcs(i).specimen = digitisation.specimen;
                        jcs(i).loading_condition = string(loading_condition);
                        i = i + 1;
                    end
                end
            end

            

        end
    end
    methods
        function self = JCS(transforms, bones, digitisation, config)
            self.bones = bones;
            self.transforms = transforms;
            self.config = config;
            self.digitisation = digitisation;
        end
    end
end
