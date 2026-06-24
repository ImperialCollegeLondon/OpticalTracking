function output = pick_labels(input, module)
    % Pick labels from the config based off MODULE.
    % i.e. use Knee labels when the current module is Knee.
    output = input;
    switch module
        case Module.Knee
            output.camera_labels = input.knee.camera_labels;
        case Module.Hip
            output.camera_labels = input.hip.camera_labels;
    end
end
