function trackers = load_data(folder_path, config)
    csv_files = dir(fullfile(folder_path, "*.csv"));
    csv_files = csv_files(~contains({csv_files.name}, {'3d.csv', 'tension', 'sensor'})); % Certus data files that shouldn't be used
    tsv_files = dir(fullfile(folder_path, "*.tsv"));
    files = [csv_files; tsv_files];

    if isempty(files)
        trackers = Option.None;
        return
    end

    % Open the files as tables, use the headers to determine which optical
    % trackin system is being used, then apply any parsing necessary to
    % make data usable.
    % e.g. convert -3.697314E+028 => NaN on the polaris.
    for i = 1:numel(files)
        [~, parent_path, ~] = fileparts(files(i).name);
        path = fullfile(files(i).folder, files(i).name);


        tracker = Camera.load_data(path);
        if isempty(tracker)
            continue
        end
        trackers(:, i) = tracker;
        landmark = clean_specimen_condition(parent_path);
        trackers(:, i).add_landmark(landmark);
    end
    
    trackers.add_labels(config.camera_labels);

    trackers = Option.Some(trackers);
end
