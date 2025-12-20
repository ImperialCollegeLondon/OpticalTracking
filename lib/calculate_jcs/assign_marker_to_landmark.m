function output = assign_marker_to_landmark(landmark)
%% Create landmarks
% Expects the file names to include both the bone and the position, e.g.,
% tibia-medial or femur_proximal. Doesn't care about order or what
% separates the words.
%
% If neither can be found, it looks for the first letter of each word,
% e.g., for tibia medial it looks for TM.
% 
% For Patella, it needs either distal or both inferior and superior.
%% Tibia
    output.tibia.medial = landmark.contains({'tibia', 'medial'});

    output.tibia.lateral = landmark.contains({'tibia', 'lateral'});
    output.tibia.distal = landmark.contains({'tibia', 'distal'});

    output.tibia.tracker = Option(landmark(1));

    %% Femur
    output.femur.medial = landmark.contains({'femur', 'medial'});
    output.femur.lateral = landmark.contains({'femur', 'lateral'});
    output.femur.proximal = landmark.contains({'femur', 'proximal'});

    output.femur.tracker = Option(landmark(1));

    %% Patella
    output.patella.medial = landmark.contains({'patella', 'medial'});
    output.patella.lateral = landmark.contains({'patella', 'lateral'});
    output.patella.distal = landmark.contains({'patella', 'distal'});
    output.patella.inferior = landmark.contains({'patella', 'inferior'});
    output.patella.superior = landmark.contains({'patella', 'superior'});
    output.patella.tracker = Option(landmark(1));
end
