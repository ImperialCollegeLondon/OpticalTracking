function quantised_runs = quantise(data, arc, step_size)
% Quantise flexion
data = reshape(data, [1 size(data)]); % 1 x 620 x 3 x 6
flex_max = round(max(arc));
flex_min = round(min(arc));
flex_deg = flex_min:step_size:flex_max;
flexion_quantised = (round(arc / step_size) * step_size == flex_deg)';

% Find the mean across the quantisations
quantised_runs = mean_nonzero(flexion_quantised .* data, 2);
quantised_runs = squeeze(quantised_runs); % 98 x 3 x 6
% To visualise the empty flexion angles. Each page is one run:
% permute(quantised_runs, [1 3 2]);
end