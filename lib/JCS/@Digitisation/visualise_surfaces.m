function visualise_surfaces(self)
    arguments
        self Digitisation
    end
    
    for d = 1:numel(self)
        switch self(d).module
            case Module.Knee
                bones = {'tibia', 'femur', 'patella'};
            case Module.Hip
                error("Not yet implemented")
        end
    
        for i = 1:numel(bones)
            bone = bones{i};
            if self(d).surface.(bone).is_none()
                continue
            end

            % figure
            outline = self(d).surface.(bone).unwrap();
            % outline = self(d).transforms.(bone).width.map(@(l) outline/l).expect("This cannot fail");
            if self(d).is_right_knee
                outline(:,2) = -outline(:,2);
                outline(:,1) = -outline(:,1);
            end
            scatter(outline(:, 1), outline(:, 2), 5, 'k', 'filled', 'HandleVisibility', 'off');
        end
    end
end
