function CI = confidence_interval(data)
n = height(data.mean);
standard_error = data.std ./ sqrt(n);

% Don't generate both tails at once, otherwise the code needs to handle
% each one individually or not multiply with the table
t_score = tinv(0.975, n - 1);
margin_of_error = t_score .* standard_error;
CI.mean.lower = data.mean - margin_of_error;
CI.mean.upper = data.mean + margin_of_error;

% Based on https://www.youtube.com/watch?v=w__TNyXH_xA
CI.std.upper = sqrt((n-1) / chi2inv(0.25, n-1)) .* data.std;
CI.std.lower = sqrt((n-1) / chi2inv(0.975, n-1)) .* data.std;
end