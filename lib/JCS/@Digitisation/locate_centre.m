function locate_centre(self)
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
            trackers = self(d).bone.(bone).surface;
            if trackers.is_none
                continue
            end
            trackers = trackers.unwrap();

            for n = 1:numel(trackers)
                figure
                tracker = trackers(n);
                X = [tracker.Tx tracker.Ty tracker.Tz];

                %% Project all collected points onto the same superior-inferior plane
                [coeff,~,~,~,~,mu] = pca(X);
                % The largest axis must always be ML and smallest must always be SI.
                medial_lateral = coeff(:,1);
                anterior_posterior = coeff(:,2);
                superior_inferior  = coeff(:,3); % Normal to plane

                % perpendicular distance to plane's centroid
                d = (X - mu) * superior_inferior;
                X_projected = X - d .* superior_inferior';
                hold on;grid on;axis equal;
                plot3(X_projected(:, 1), X_projected(:, 2), X_projected(:, 3), 'r');
                Xp = X_projected - mu;

                u = Xp * medial_lateral;   % ML coordinate
                v = Xp * anterior_posterior;   % AP coordinate

                % Use medial-lateral midpoint as threshold for the two circles fit
                u_mid = (max(u) + min(u))/2;

                idx_med = u < u_mid;
                [c_med, r_med] = circle_fit(u, v, u < u_mid);
                [c_lat, r_lat] = circle_fit(u, v, u >= u_mid);


                scatter(u, v, 10, 'k', 'filled')
                plot_circle = @(x,y,r) fplot(@(t) r*sin(t)+x, @(t) r*cos(t)+y);
                plot_circle(c_med(1), c_med(2), r_med)
                plot_circle(c_lat(1), c_lat(2), r_lat)
            end
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

