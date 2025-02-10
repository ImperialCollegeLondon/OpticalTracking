function visualise_landmarks(landmarks, config)
figure(1)
%% Tibia
grid;
    t = landmarks.tibia;
    fields = fieldnames(t);
    for i = 1:numel(fields)
        t.(fields{i}) = t.(fields{i}).unwrap();
    end
    t_med = t.medial.translations_mean();
    plot_t = scatter3(t_med(1), t_med(2), t_med(3), 'b');
    hold on;
    text(t_med(1), t_med(2), t_med(3), "  Medial");

    t_lat = t.lateral.translations_mean();
    scatter3(t_lat(1), t_lat(2), t_lat(3), 'b');
    text(t_lat(1), t_lat(2), t_lat(3), "  Lateral");

    t_dist = t.distal.translations_mean();
    scatter3(t_dist(1), t_dist(2), t_dist(3), 'b');
    text(t_dist(1), t_dist(2), t_dist(3), "  Distal");

    if ~isscalar(t.distal)
        for n = 1:numel(t.distal)
            scatter3(t.distal(n).Tx(1), t.distal(n).Ty(1), t.distal(n).Tz(1), 'k');
        end
    end

    % Medial-lateral axis
    o = (t.medial.translations_mean + t.lateral.translations_mean)/2;
    scatter3(o(1), o(2), o(3), 8, 'b', 'filled')
    if config.is_right_knee
        med_lat = t_lat - t_med;
        quiver3(t_med(1), t_med(2), t_med(3), med_lat(1), med_lat(2), med_lat(3), 0, 'b')
    else
        med_lat = t_med - t_lat;
        quiver3(t_lat(1), t_lat(2), t_lat(3), med_lat(1), med_lat(2), med_lat(3), 0, 'b')
    end
    % Proximal-distal axis
    prox_dist = t_dist - o;
    quiver3(o(1), o(2), o(3), prox_dist(1), prox_dist(2), prox_dist(3), 0, 'b');

%% Femur
    f = landmarks.femur;
    fields = fieldnames(f);
    for i = 1:numel(fields)
        f.(fields{i}) = f.(fields{i}).unwrap();
    end

    f_med = f.medial.translations_mean();
    plot_f = scatter3(f_med(1), f_med(2), f_med(3), 'r');
    text(f_med(1), f_med(2), f_med(3), '  Medial')

    f_lat = f.lateral.translations_mean();
    scatter3(f_lat(1), f_lat(2), f_lat(3), 'r');
    text(f_lat(1), f_lat(2), f_lat(3), '  Lateral');

    f_prox = f.proximal.translations_mean();
    scatter3(f_prox(1), f_prox(2), f_prox(3), 'r');
    text(f_prox(1), f_prox(2), f_prox(3), "  Proximal")

    if ~isscalar(f.proximal)
        for n = 1:numel(f.proximal)
            scatter3(f.proximal(n).Tx(1), f.proximal(n).Ty(1), f.proximal(n).Tz(1), 'k');
        end
    end

    % Medial-lateral axis
    o = (f_med + f_lat)/2;
    scatter3(o(1), o(2), o(3), 8, 'r', 'filled')
    if config.is_right_knee
        med_lat = f_lat - f_med;
        quiver3(f_med(1), f_med(2), f_med(3), med_lat(1), med_lat(2), med_lat(3), 0, 'r')
    else
        med_lat = f_med - f_lat;
        quiver3(f_lat(1), f_lat(2), f_lat(3), med_lat(1), med_lat(2), med_lat(3), 0, 'r')
    end
    % Proximal-distal axis
    prox_dist = f_prox - o;
    quiver3(o(1), o(2), o(3), prox_dist(1), prox_dist(2), prox_dist(3), 0, 'r');
% grid;
if config.is_right_knee
    title_str = [config.specimen.name '. Right knee'];
else
    title_str = [config.specimen.name '. Left knee'];
end
title(title_str);
legend([plot_t, plot_f], {"Tibia", "Femur"})
hold off;


if config.debug
    femur = eye(4);
    femur(1) = f.medial.Rx(1);
    femur(2) = f.medial.Ry(1);
    femur(3) = f.medial.Rz(1);
    tibia = eye(4);
    tibia(1) = t.medial.Rx(1);
    tibia(2) = t.medial.Ry(1);
    tibia(3) = t.medial.Rz(1);
    [f_ang, ~] = rotationsAndTranslations(femur, config.is_right_knee);
    [t_ang, ~] = rotationsAndTranslations(tibia, config.is_right_knee);
    t_ang - f_ang
end

end
