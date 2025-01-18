function plot_lines(data, ci, truncate_min, truncate_max)
    arguments
        data 
        ci 
        truncate_min = min(data.flexion)
        truncate_max = max(data.flexion)
    end
    % Expects `data` to be a table with headers:
    % {flexions, varus, external, lateral, anterior, superior}
    %
    % Expects `ci` to be a struct that contains the fields `std.lower` and `std.upper`
    % These fields should have tables that have the same headers as `data`.
    % See: INTERSPECIMEN_STATS for how these are created.

    x = data.flexion >= truncate_min & data.flexion <= truncate_max;

    % all_y = [data.varus(x); data.external(x); data.lateral(x); data.anterior(x); data.superior(x)];
    % y_range = [min(all_y) max(all_y)];
    % y_range = [min(y_range(1), -5) max(y_range(2), 5)];
    % y_pad = 0.1 * range(y_range);
    % y_limits = y_range + [-y_pad y_pad];
    % 

    headers = setdiff(data.Properties.VariableNames, "flexion");
    for j = 1:numel(headers)
        nexttile(j); hold on; grid on;
        plot(data.flexion(x), data.(headers{j})(x));
    % ylim(y_limits)
    end
end
