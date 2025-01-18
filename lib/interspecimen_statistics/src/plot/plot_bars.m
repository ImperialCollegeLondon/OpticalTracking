function plot_bars(data, ci, truncate_min, truncate_max)
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

    % Truncate data
    n = data.flexion >= truncate_min & data.flexion <= truncate_max;
    idx_truncated = find(n, 1, "last");
    step_size = round(10 + 20*rand(1));
    b = false(size(n));
    b(2:step_size:idx_truncated) = true;
    b(idx_truncated) = true;
    x = n & b;

    headers = setdiff(data.Properties.VariableNames, "flexion");
    for j = 1:numel(headers)
        nexttile(j); hold on; grid on;
        errorbar(data.flexion(x), data.(headers{j})(x), ci.std.lower.(headers{j})(x), ci.std.upper.(headers{j})(x));
    end
end
