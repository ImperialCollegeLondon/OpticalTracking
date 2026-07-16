function res = translations_homogeneous(selves)
    res = cell(numel(selves), 1);
    N = numel(selves(1).Tx);
    T = repmat(eye(4), 1, 1, N);
    for n = 1:numel(selves)
        self = selves(n);
        T(1,4,:) = self.Tx;
        T(2,4,:) = self.Ty;
        T(3,4,:) = self.Tz;
        res{n} = T;
    end
end
