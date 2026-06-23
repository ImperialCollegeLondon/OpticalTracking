function ax = visualise_mean(selves)
hold on;
for s = 1:numel(selves)
    self = selves(s);
    x = mean(self.Tx, "omitmissing");
    y = mean(self.Ty, "omitmissing");
    z = mean(self.Tz, "omitmissing");
    ax = scatter3(x,y,z);
end
end
