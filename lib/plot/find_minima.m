function minima = find_minima(input)
distance_threshold = 50;  % Minimum distance between minima
slope_threshold = 0.02;    % Minimum slope between minima

local_minima = islocalmin(input.flexion);

% We get several minima on a long tail where the user forgot to turn off
% the camera. We require a minimum slope to make sure it's actual data.
idx = find(local_minima);
idx_sweep = idx * [1 1 1] + [-100 0 100];
idx_sweep(idx_sweep > numel(local_minima)) = idx(end);
idx_sweep(idx_sweep < 1) = 1;
changes_over_time = diff(input.flexion(idx_sweep), 2, 2) > 1;

large_change = boolean(zeros(size(local_minima)));
large_change(idx(find(changes_over_time))) = true;

close_to_extension = input.flexion < mean(input.flexion, "omitmissing")/4;
reasonable_minima = local_minima & large_change & close_to_extension;

idx_minima = find(reasonable_minima);
% Find the minima that aren't too close to each other:

distances = diff(idx_minima);




% With noisy data you end up with a few local minima. We do 2 passes to
% find true minima: first one to find points that are far away from each
% other, and second to pick a mid point between the leftover close ones.
close_groups = boolean([0; distances < distance_threshold]);
if ~any(close_groups)
    minima = idx_minima;
else
    group = {};          % Cell array to hold groups
current_group = [];   % Temporary holder for the current group
for j = 2:length(close_groups)
    current = close_groups(j);
    previous = close_groups(j-1);
    if current == 0 && previous == 0 %If starting a new group, then flush the previous and start new
        group{end+1} = current_group; 
        current_group = idx_minima(j);
    elseif current == 1 && previous == 0
        current_group = [idx_minima(j-1) idx_minima(j)];
    elseif current == 1
        current_group = [current_group idx_minima(j)];
    elseif current == 0
        group{end+1} = current_group;
        current_group = idx_minima(j);
    end
end

if current
    group{end} = [current_group idx_minima(j)];
else
    group{end+1} = idx_minima(j);
end

       

    % ungrouped_clusters = [find(diff(close_groups) ~= 0); c']; %indices of clustered minima ungrouped
    % % Creates the clusters of minima that are nearby. i.e., if it finds
    % % multiple minima within 100 frames of each other, they are grouped
    % % together to assess which one might be the best minimum.
    % gropings = [true; [0; diff(ungrouped_clusters)] > 1]; %
    % filtered_changes = [ungrouped_clusters(gropings); length(idx_minima)];
    % for i = 2:length(filtered_changes)
    %     start = ungrouped_clusters(i-1);
    %     stop = ungrouped_clusters(i);
    %     ii = start:stop-1;
    %     minima_clusters{:,i-1} = idx_minima(ii);
    % end

    minima = use_midpoint(group);
end

minima = nearby_if_nan(minima, input);
end

function output = use_midpoint(cluster)
for i = 1:length(cluster)
med = median(cluster{i});
men = mean(cluster{i});
output(i) = round(med);
end
end

function minima = nearby_if_nan(minima, input)
% Moves left and right a few times until it finds something that isn't NaN.
for i = 1:length(minima)
    if isnan(input.flexion(minima(i))) 
        left = minima(i) - 1; 
        right = minima(i) + 1;
        
        while (left >= 1 && isnan(input.flexion(left))) && (right <= length(input.flexion) && isnan(input.flexion(right)))
            left = left - 1; 
            right = right + 1;
        end
        
        if left >= 1 && ~isnan(input.flexion(left))
            minima(i) = left; 
        elseif right <= length(input.flexion) && ~isnan(input.flexion(right))
            minima(i) = right;
        end
    end
end
end