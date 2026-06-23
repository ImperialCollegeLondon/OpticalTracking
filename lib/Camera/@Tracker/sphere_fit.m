function tracker = sphere_fit(self)
    x = self.Tx(:);
    y = self.Ty(:);
    z = self.Tz(:);

    n = numel(x);
    assert(n >= 4, 'Need at least 4 points for a sphere fit');

    %% --- Normalise to improve conditioning ---
    cx_raw = mean(x);  cy_raw = mean(y);  cz_raw = mean(z);
    scale  = std([x; y; z]);                  % single scale factor keeps aspect ratio
    xn = (x - cx_raw) / scale;
    yn = (y - cy_raw) / scale;
    zn = (z - cz_raw) / scale;

    %% --- Robust linear estimate (Algebraic fit in normalised space) ---
    A = [2*xn, 2*yn, 2*zn, ones(n,1)];
    b = xn.^2 + yn.^2 + zn.^2;

    % Use least-squares with QR for numerical stability
    p = A \ b;
    c0n = p(1:3);
    r0n = sqrt(max(p(4) + sum(c0n.^2), 0));   % guard sqrt of negative

    %% --- Iteratively Reweighted Least Squares (IRLS) linear pass ---
    % Down-weights outliers before handing off to nonlinear solver
    c_irls = c0n;
    for iter = 1:5
        dists  = sqrt((xn-c_irls(1)).^2 + (yn-c_irls(2)).^2 + (zn-c_irls(3)).^2);
        r_irls = median(dists);                % median is robust to outliers
        resid  = abs(dists - r_irls);
        mad    = median(resid);
        sigma  = max(mad / 0.6745, 1e-9);     % MAD -> robust sigma estimate
        w      = 1 ./ (1 + (resid / (3*sigma)).^2);  % Cauchy weights

        Aw = bsxfun(@times, A, w);
        bw = b .* w;
        p  = Aw \ bw;
        c_irls = p(1:3);
    end
    r_irls = sqrt(max(p(4) + sum(c_irls.^2), 0));

    %% --- Nonlinear refinement in normalised space ---
    p0   = [c_irls; r_irls];
    fun  = @(p) sqrt((xn-p(1)).^2 + (yn-p(2)).^2 + (zn-p(3)).^2) - p(4);

    % Bounds: centre within data range, radius must be positive
    data_range = max([xn;yn;zn]) - min([xn;yn;zn]);
    lb = [min(xn), min(yn), min(zn), 0           ];
    ub = [max(xn), max(yn), max(zn), data_range  ];

    opts = optimoptions('lsqnonlin', ...
        'Display',       'off',   ...
        'FunctionTolerance', 1e-10, ...
        'StepTolerance',     1e-10, ...
        'MaxIterations', 2000);

    p = lsqnonlin(fun, p0, lb, ub, opts);

    %% --- Denormalise back to original coordinates ---
    tx   = p(1) * scale + cx_raw;
    ty   = p(2) * scale + cy_raw;
    tz   = p(3) * scale + cz_raw;
    r    = p(4) * scale;

    residuals = fun(p);
    rmse_norm = sqrt(mean(residuals.^2));
    rmse      = rmse_norm * scale;              % RMSE in original units

    tracker = Tracker(self.Name, 1, 0, 0, 0, tx, ty, tz, rmse);
end
