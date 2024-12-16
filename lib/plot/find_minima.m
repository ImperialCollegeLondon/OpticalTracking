function minima = find_minima(input)
distance_threshold = 100;  % Minimum distance between minima
slope_threshold = 0.02;    % Minimum slope between minima

local_minima = islocalmin(input.flexion);

% We get several minima on a long tail where the user forgot to turn off
% the camera. We require a minimum slope to make sure it's actual data.
idx = find(local_minima);
idx_sweep = idx * [1 1 1] + [-100 0 100];
idx_sweep(idx_sweep > numel(local_minima)) = idx(end);
changes_over_time = diff(input.flexion(idx_sweep), 2, 2) > 1;

large_change = boolean(zeros(size(local_minima)));
large_change(idx(find(changes_over_time))) = true;

close_to_extension = input.flexion < mean(input.flexion, "omitmissing")/2;
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
    changes = find(diff(close_groups) ~= 0);
    filtered_changes = [changes([true; [0; diff(changes)] > 1]); length(idx_minima)];
    for i = 2:length(filtered_changes)
        start = filtered_changes(i-1);
        stop = filtered_changes(i);
        ii = start:stop-1;
        minima_clusters{:,i-1} = idx_minima(ii);
    end

    minima = use_midpoint(minima_clusters);
end

minima = nearby_if_nan(minima, input);
end

function output = use_midpoint(cluster)
for i = 1:length(cluster)
med = median(cluster{i});
men = mean(cluster{i});
output(i) = med;
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