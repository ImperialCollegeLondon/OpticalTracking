function r = rotations_mean(self)
if isempty(self.rotations)
    r = [];
    return
end
r = mean(self.rotations(), "omitmissing");
end
