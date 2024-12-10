% function output = extract_from_label(landmark_raw_data, label)
% for i = 1:numel(landmark_raw_data)
%     output(i).name = landmark_raw_data(i).name;
% 
%     idx = strcmp({landmark_raw_data(i).probes.label}, label);
%     if any(idx) % Check if a match was found
%         probeData = landmark_raw_data(i).probes(idx); % Get the matching probe
%         fields = fieldnames(probeData); % Get all field names
% 
%         for f = 1:numel(fields)
%             % Assign each field to output(i)
%             output(i).(fields{f}) = probeData.(fields{f});
%         end
%     end
% end
function output = extract_from_label(landmark, label)
idx = strcmp([landmark.label], label);
if ~any(idx)
disp("Could not extract any data given the labels");
end
output = landmark(idx);
output.label = output.label{:};
end
