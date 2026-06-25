function r = rotations_mean(self)
if isempty(self.rotations) || all(isnan(self.rotations), "all")
    r = [];
    return
end
r = mean(self.rotations(), 1, "omitmissing");
end
