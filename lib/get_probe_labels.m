function probe = get_probe_labels(calibration, root)
files = dir(fullfile(root, "*.tbr"));
config = fullfile(files(1).folder, files(1).name);

probes = {calibration.probes};
names = {probes{1}.probe};
for i = 1:numel(names)
    probe(i).name = names{i};
    probe(i).label = read_config(config, names{i}{1});
end
end
