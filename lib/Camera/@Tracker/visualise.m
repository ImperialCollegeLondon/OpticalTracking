function ax = visualise(self)
    x = vertcat(self.Tx);
    y = vertcat(self.Ty);
    z = vertcat(self.Tz);
    ax = scatter3(x,y,z);
end
