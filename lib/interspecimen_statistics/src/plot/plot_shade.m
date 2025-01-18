function plot_shade(data, ci, truncate_min, truncate_max)
arguments
    data 
    ci 
    truncate_min = min(data.flexion)
    truncate_max = max(data.flexion)
end
n = data.flexion >= truncate_min & data.flexion <= truncate_max;
x = [data.flexion(n); flip(data.flexion(n))];

headers = setdiff(data.Properties.VariableNames, "flexion");
for j = 1:numel(headers)
nexttile(j); hold on;
confidence_interval = [ci.mean.lower.(headers{j})(n); flip(ci.mean.upper.(headers{j})(n))];
fill(x, confidence_interval, 'r', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
end
% 
% nexttile(1); hold on
% 
% 
% 
% % Varus Plot
% varus_ci = [ci.mean.lower.varus(n); flip(ci.mean.upper.varus(n))]; %
% fill(x, varus_ci, 'r', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
% nexttile(2); hold on;
% 
% % External
% external_ci = [ci.mean.lower.external(n); flip(ci.mean.upper.external(n))]; %
% fill(x, external_ci, 'r', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
% 
% % Lateral
% nexttile(3); hold on; 
% lateral_ci = [ci.mean.lower.lateral(n); flip(ci.mean.upper.lateral(n))]; %
% fill(x, lateral_ci, 'r', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
% 
% % Anterior
% nexttile(4); hold on;
% anterior_ci = [ci.mean.lower.anterior(n); flip(ci.mean.upper.anterior(n))]; %
% fill(x, anterior_ci, 'r', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
% 
% % Superior
% nexttile(5); hold on;
% superior_ci = [ci.mean.lower.superior(n); flip(ci.mean.upper.superior(n))]; %
% fill(x, superior_ci, 'r', 'FaceAlpha', 0.2, 'EdgeColor', 'none');

end