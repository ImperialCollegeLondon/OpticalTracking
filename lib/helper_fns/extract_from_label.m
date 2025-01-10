function output = extract_from_label(landmark, label)
idx = strcmp([landmark.label], label) | strcmp({landmark.label}, label);
output = landmark(idx);
if isempty(label)
    return;
else
    if ~any(idx)
        disp("Could not determine the probes from the labels provided. Check that label in matlab matches the data.");
    end
    if ischar(output.label)
        output.label = output.label;
    else
        output.label = output.label{:};
    end
end
end
