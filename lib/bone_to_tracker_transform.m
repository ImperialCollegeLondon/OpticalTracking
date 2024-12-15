function trackers = bone_to_tracker_transform(tibia, femur, patella, right)
%% Define coordinate systems for each bone using digitised points
% For tibia
gTt0 = defineBodyFixedFrameTibia(tibia, right);
grt0 = origins(gTt0);
gTf0 = defineBodyFixedFrameFemur(femur, right);
grf0 = origins(gTf0);
gTp0 = defineBodyFixedFramePatella(patella, right);
grp0 = origins(gTp0);

%% Define frame of reference for each of the trackers in global coordinates
[gTft0] = defineTrackerFixedFrame(femur.tracker.rotations_mean, femur.tracker.translations_mean);
[gTtt0] = defineTrackerFixedFrame(tibia.tracker.rotations_mean, tibia.tracker.translations_mean);
[gTpt0] = defineTrackerFixedFrame(patella.tracker.rotations_mean, patella.tracker.translations_mean);

%% Relate body fixed frames and origin to the tracker rigid body
% A constant transform of the body fixed frame in the tracker frame of reference (assumes rigid body)
% As in, tibia in the tibial tracker's frame of reference.
trackers.tibia.transform = gTtt0\gTt0; %ttTtc
trackers.tibia.origin = gTtt0\grt0; %ttrtc

trackers.femur.transform = gTft0\gTf0; %ftTfc
trackers.femur.origin = gTft0\grf0; %ftrfc

trackers.patella.transform = gTpt0\gTp0; %ttTpc
trackers.patella.origin = gTpt0\grp0; %ptrpc

check_empty_fields(trackers);
end

function empty_fields = check_empty_fields(structure)
field_names = fieldnames(structure);
empty_fields = {};

for i = 1:length(field_names)
    field = structure.(field_names{i}).transform;
    if isempty(field)
        empty_fields{end+1} = field_names{i};
    end
end

% Display results
if ~isempty(empty_fields)
    warning('%s tracker data is empty. If this is correct, ignore this message.\n', empty_fields{:});
end
end

function o = origins(tracker)
if isempty(tracker)
    o = [];
else
    o = tracker(:,4);
end
end
