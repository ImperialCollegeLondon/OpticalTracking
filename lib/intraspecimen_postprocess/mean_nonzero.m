function M = mean_nonzero(data, D)
% `data` is (recorded data) x (quantised flexion)  x run number x direction (flexion, varus, external,lateral,anterior,superior)
%                  600      x        98            x   3        x    6
% the first 2 dimensions are a big map of how each datum should map to a quantised value
nonzero_sum = sum(data, D);
nonzero_count = sum(data ~= 0, D);
M = nonzero_sum ./ max(nonzero_count, 1); % 98 x 1 x 3 x 6
end