function ax = visualise(selves)
    hold on;
    for s = numel(selves)
        self = selves(s);
        x = self.Tx;
        y = self.Ty;
        z = self.Tz;
        ax = scatter3(x,y,z);
    end
end
