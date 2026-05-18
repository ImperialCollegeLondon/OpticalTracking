function centre = locate_centre(self)
arguments
    self Digitisation
end

for d = 1:numel(self)
    switch self(d).module
        case Module.Knee
            bones = {'tibia', 'femur', 'patella'};
        case Module.Hip
            error("Not yet implemented")
    end

    for i = 1:numel(bones)
        bone = bones{i};
        
        has_field_surface = any(contains(fields(self(d).bone.(bone)), 'surface'));
        if ~has_field_surface
            continue
        end
        trackers = self(d).bone.(bone).surface;
        if trackers.is_none
            continue
        end
        hold on;
        trackers = trackers.unwrap();

        X = trackers.translations;

        %% Project all collected points onto the same superior-inferior plane
        [coeff,~,~,~,~,mu] = pca(X);
        % The largest axis must always be ML and smallest must always be SI.
        medial_lateral = coeff(:,1);
        anterior_posterior = coeff(:,2);
        superior_inferior  = coeff(:,3); % Normal to plane

        scatter3(X(:, 1), X(:, 2), X(:, 3), 'k');
        % perpendicular distance to plane's centroid
        dist = (X - mu) * superior_inferior;
        X_projected = X - dist .* superior_inferior';
        scatter3(X_projected(:, 1), X_projected(:, 2), X_projected(:, 3), 'b');
        Xp = X_projected - mu;

        u = Xp * medial_lateral;   % ML coordinate
        v = Xp * anterior_posterior;   % AP coordinate

        % Use medial-lateral midpoint as threshold for the two circles fit
        u_mid = (max(u) + min(u))/2;


        [c_med, r_med] = circle_fit(u, v, u < u_mid);
        [c_lat, r_lat] = circle_fit(u, v, u >= u_mid);

        t = linspace(0, 2*pi, 200)';

        % 2D points on each circle
        pts_med = [c_med(1) + r_med*cos(t),  c_med(2) + r_med*sin(t)];  % 200×2
        pts_lat = [c_lat(1) + r_lat*cos(t),  c_lat(2) + r_lat*sin(t)];

        % Back to 3D: each row is mu + u*ml + v*ap
        circle_med_3d = mu + pts_med * [medial_lateral, anterior_posterior]';
        circle_lat_3d = mu + pts_lat * [medial_lateral, anterior_posterior]';

        plot3(circle_med_3d(:,1), circle_med_3d(:,2), circle_med_3d(:,3), '--', 'LineWidth', 2);
        plot3(circle_lat_3d(:,1), circle_lat_3d(:,2), circle_lat_3d(:,3), '--', 'LineWidth', 2);

        centre_med_3d = mu + c_med * [medial_lateral, anterior_posterior]';
        centre_lat_3d = mu + c_lat * [medial_lateral, anterior_posterior]';

        plot3(centre_med_3d(1), centre_med_3d(2), centre_med_3d(3), 'b+', 'MarkerSize', 12, 'LineWidth', 2);
        plot3(centre_lat_3d(1), centre_lat_3d(2), centre_lat_3d(3), 'b+', 'MarkerSize', 12, 'LineWidth', 2);
        centre.medial = centre_med_3d;
        centre.lateral = centre_lat_3d;
    end
end
end

function [centre, radius] = circle_fit(x, y, mask)
circleResidual = @(c,x,y) sqrt((x-c(1)).^2 + (y-c(2)).^2) - c(3);
x_side = x(mask);
y_side = y(mask);

[~, idx_edge] = min(x_side);

p_edge = [x_side(idx_edge), y_side(idx_edge)];
c0 = [mean(x, "omitmissing"), mean(y, "omitmissing")];
r0 = norm(p_edge - c0);
% Medial plateau
c = lsqnonlin(@(c) circleResidual(c,x_side,y_side),[c0 r0]);


centre = c(1:2);
radius = c(3);
end