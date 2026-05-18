function self = digitise_surfaces(self)
arguments
    self Digitisation
end

for d = 1:numel(self)
    digitisation = self(d);
    %% Find files with tibia perimeter data
    root = digitisation.filepath;
    % Find folders that contain tibia and surface or surface in the name
    folders = dir(root);
    folders = folders([folders.isdir]);
    is_surface = contains({folders.name}, 'surf', 'IgnoreCase', true);
    folders = folders(is_surface);

    if isempty(folders)
        warning("No surface folders found. Make sure folder name includes 'surf'");
        return
    elseif numel(folders) > 1
        warning("Multiple surface folders found. Make sure only one folder name includes 'tib' and 'surf'");
        return
    end

    fp_surface = fullfile(folders.folder, folders.name);

    trackers = load_data(fp_surface, digitisation.config);
    if trackers.is_none
        warning("Couldn't associate any trackers from folder")
        return
    end
    trackers = trackers.unwrap();

    labels = trackers.camera().get_possible_labels(digitisation.config.camera_labels);

    switch digitisation.module
        case Module.Knee
            bones = {'tibia', 'femur', 'patella'};
        case Module.Hip
            error("Not yet implemented")
    end

    for i = 1:numel(bones)
        bone = bones{i};

        self(d).bone.(bone).surface = trackers.contains({bone, 'surface'}).and_then(@(x) x.with_label(labels.probe));
        if self(d).bone.(bone).surface.is_none
            warning("No surfaces found. Check that file's name is `%s surface`", bone)
            return
        end
        % if numel(self(d).bone.(bone).surface.value) > 1
        %     warning("There are multiple %s surface digitisations. call visualise_surfaces() to pick the best one.", bone)
        % end

        track = self(d).bone.(bone).surface.value;
        if is_range_too_large(track)
            warning("Unexpectedly large range of values for surface. Check that tracker was not still recording when moved away from surface.")
        end

    end
end
end

function range_too_large = is_range_too_large(trackers, threshold)
arguments
    trackers
    threshold = 150
end
for n = 1:numel(trackers)
    tracker = trackers(n);
    range_too_large = range(tracker.Tx) > threshold || range(tracker.Ty) > threshold || range(tracker.Tz) > threshold;

    if range_too_large
        return
    end
end
end
