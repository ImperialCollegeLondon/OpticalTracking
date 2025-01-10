function R = use_polaris(header)
% The csvs for Polaris always include: Port xxxx TrackerName
R = any(contains(header, "Port"));
end