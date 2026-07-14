function res = translations_homogeneous(selves)
    r(numel(selves), :, :, :) = repmat(eye(4), 1, 1, numel(vertcat(selves(1).Tx)));
    for n = 1:numel(selves)
        self = selves(n);
        tx = self.Tx;
        ty = self.Ty;
        tz = self.Tz;
        r(1:3, 4, n, :) = [tx ty tz]';
        res{n} = squeeze(r(:, :, n, :));
    end
end
