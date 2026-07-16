function ax = visualise(selves)
    hold on;
    for n = 1:numel(selves)
        self = selves(n);
        x = self.Tx;
        y = self.Ty;
        z = self.Tz;
        ax = scatter3(x,y,z);
    end
end
