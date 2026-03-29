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
            trackers = self(d).bone.(bone).surface;
            if trackers.is_none
                continue
            end
            trackers = trackers.unwrap();
    
            for n = 1:numel(trackers)
                tracker = trackers(n);
                figure;
                tracker.visualise
                axis equal;
                sgtitle({self(d).config.specimen.name, tracker.Landmark})
    
            end
        end
    end
end
