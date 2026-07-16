function visualise(self)
    for n = 1:numel(self)
        if isempty(self(n).bone)
            warning("Trackers not assigned to bones yet")
            continue
        end

        landmarks = self(n).bone;
        is_right_knee = self(n).is_right_knee;

        switch self(n).module
            case Module.Knee
                visualise_knee(landmarks, is_right_knee)
            case Module.Hip
                visualise_hip(landmarks, is_right_knee)
        end

        if is_right_knee
            title_str = [self(n).specimen '. Right'];
        else
            title_str = [self(n).specimen '. Left'];
        end
        title(title_str);
        hold off;
    end
end

function visualise_hip(landmarks, is_right_knee)
        % figure
        %% Tibia
        grid;
        h = landmarks.hip;
        fields = fieldnames(h);
        fields(strcmp(fields, 'surface')) = [];
        
        for i = 1:numel(fields)
            h.(fields{i}) = h.(fields{i}).unwrap_or([]);
        end
        plot_h = scatter3(h.asis.Tx(1), h.asis.Ty(1), h.asis.Tz(1), 'b');
        hold on;
        text_mean(calc_means(h.asis), "  ASIS");
        scatter3(h.psis.Tx(1), h.psis.Ty(1), h.psis.Tz(1), 'b');
        text_mean(calc_means(h.psis), "  PSIS");
        for td = 1:numel(h.pot)
            tdis = h.pot(td);
            scatter3(tdis.Tx(1), tdis.Ty(1), tdis.Tz(1), 'k');
        end
        % scatter3(mean(h.pot.Tx, "all", "omitnan"), mean(h.pot.Ty, "all", "omitnan"), mean(h.pot.Tz, "all", "omitnan"), 'b');
        scatter_mean(calc_means(h.pot), 'b');
        text_mean(calc_means(h.pot), "  Pot (sagital plane)");

        % Medial-psis axis
        o = h.origin.translations_mean();
        scatter3(o(1), o(2), o(3), 8, 'b', 'filled')
        if is_right_knee
            med_lat = h.asis.translations_mean - h.psis.translations_mean;
            quiver3(h.psis.Tx(1), h.psis.Ty(1), h.psis.Tz(1), med_lat(1), med_lat(2), med_lat(3), 0, 'b')
        else
            med_lat = h.psis.translations_mean - h.asis.translations_mean;
            quiver3(h.asis.Tx(1), h.asis.Ty(1), h.asis.Tz(1), med_lat(1), med_lat(2), med_lat(3), 0, 'b')
        end
        % Proximal-distal axis
        prox_dist = h.pot.translations_mean - o;
        quiver3(o(1), o(2), o(3), prox_dist(1), prox_dist(2), prox_dist(3), 0, 'b');

        %% Femur
        f = landmarks.femur;
        fields = fieldnames(f);
        fields = setdiff(fields, 'tracker');
        for i = 1:numel(fields)
            f.(fields{i}) = f.(fields{i}).unwrap();
        end

        plot_f = scatter3(f.medial.Tx(1), f.medial.Ty(1), f.medial.Tz(1), 'r');
        text_mean(calc_means(f.medial), '  Medial');
        scatter3(f.lateral.Tx(1), f.lateral.Ty(1), f.lateral.Tz(1), 'r');
        text_mean(calc_means(f.lateral), '  Lateral');


        for td = 1:numel(f.proximal)
            fprox = f.proximal(td);
            scatter3(fprox.Tx(1), fprox.Ty(1), fprox.Tz(1), 'k');
        end
        % scatter3(mean(f.proximal.Tx, "all"), mean(f.proximal.Ty, "all"), mean(f.proximal.Tz, "all"), 'r');
        scatter_mean(calc_means(f.proximal), 'r');

        % scatter3(f.proximal.Tx(1), f.proximal.Ty(1), f.proximal.Tz(1), 'r');
        text_mean(calc_means(f.proximal), "  Proximal");

        % Medial-lateral axis
        o = (f.medial.translations_mean + f.lateral.translations_mean)/2;
        scatter3(o(1), o(2), o(3), 8, 'r', 'filled')
        if is_right_knee
            med_lat = f.lateral.translations_mean - f.medial.translations_mean;
            quiver3(f.medial.Tx(1), f.medial.Ty(1), f.medial.Tz(1), med_lat(1), med_lat(2), med_lat(3), 0, 'r')
        else
            med_lat = f.medial.translations_mean - f.lateral.translations_mean;
            quiver3(f.lateral.Tx(1), f.lateral.Ty(1), f.lateral.Tz(1), med_lat(1), med_lat(2), med_lat(3), 0, 'r')
        end
        % Proximal-distal axis
        prox_dist = f.proximal.translations_mean - o;
        quiver3(o(1), o(2), o(3), prox_dist(1), prox_dist(2), prox_dist(3), 0, 'r');
        % grid;
        axis square;
        legend([plot_h, plot_f], {"Hip", "Femur"})
end

function visualise_knee(landmarks, is_right_knee)
        % figure
        %% Tibia
        grid;
        t = landmarks.tibia;
        fields = fieldnames(t);
        fields(strcmp(fields, 'surface')) = [];
        
        for i = 1:numel(fields)
            t.(fields{i}) = t.(fields{i}).unwrap();
        end
        plot_h = scatter3(t.medial.Tx(1), t.medial.Ty(1), t.medial.Tz(1), 'b', 'DisplayName', 'Hip');
        hold on;
        text_mean(calc_means(t.medial), "  Medial");
        scatter3(t.lateral.Tx(1), t.lateral.Ty(1), t.lateral.Tz(1), 'b');
        text_mean(calc_means(t.lateral), "  Lateral");
        for td = 1:numel(t.distal)
            tdis = t.distal(td);
            scatter3(tdis.Tx(1), tdis.Ty(1), tdis.Tz(1), 'k');
        end
        % scatter3(mean(t.distal.Tx, "all", "omitnan"), mean(t.distal.Ty, "all", "omitnan"), mean(t.distal.Tz, "all", "omitnan"), 'b');
        scatter_mean(calc_means(t.distal), 'b');
        text_mean(calc_means(t.distal), "  Distal");

        % Medial-lateral axis
        o = (t.medial.translations_mean + t.lateral.translations_mean)/2;
        scatter3(o(1), o(2), o(3), 8, 'b', 'filled')
        if is_right_knee
            med_lat = t.lateral.translations_mean - t.medial.translations_mean;
            quiver3(t.medial.Tx(1), t.medial.Ty(1), t.medial.Tz(1), med_lat(1), med_lat(2), med_lat(3), 0, 'b')
        else
            med_lat = t.medial.translations_mean - t.lateral.translations_mean;
            quiver3(t.lateral.Tx(1), t.lateral.Ty(1), t.lateral.Tz(1), med_lat(1), med_lat(2), med_lat(3), 0, 'b')
        end
        % Proximal-distal axis
        prox_dist = t.distal.translations_mean - o;
        quiver3(o(1), o(2), o(3), prox_dist(1), prox_dist(2), prox_dist(3), 0, 'b');

        %% Femur
        f = landmarks.femur;
        fields = fieldnames(f);
        for i = 1:numel(fields)
            f.(fields{i}) = f.(fields{i}).unwrap();
        end

        plot_f = scatter3(f.medial.Tx(1), f.medial.Ty(1), f.medial.Tz(1), 'r', 'DisplayName', 'Femur');
        text_mean(calc_means(f.medial), '  Medial');
        scatter3(f.lateral.Tx(1), f.lateral.Ty(1), f.lateral.Tz(1), 'r');
        text_mean(calc_means(f.lateral), '  Lateral');


        for td = 1:numel(f.proximal)
            fprox = f.proximal(td);
            scatter3(fprox.Tx(1), fprox.Ty(1), fprox.Tz(1), 'k');
        end
        % scatter3(mean(f.proximal.Tx, "all"), mean(f.proximal.Ty, "all"), mean(f.proximal.Tz, "all"), 'r');
        scatter_mean(calc_means(f.proximal), 'r');

        % scatter3(f.proximal.Tx(1), f.proximal.Ty(1), f.proximal.Tz(1), 'r');
        text_mean(calc_means(f.proximal), "  Proximal");

        % Medial-lateral axis
        o = (f.medial.translations_mean + f.lateral.translations_mean)/2;
        scatter3(o(1), o(2), o(3), 8, 'r', 'filled')
        if is_right_knee
            med_lat = f.lateral.translations_mean - f.medial.translations_mean;
            quiver3(f.medial.Tx(1), f.medial.Ty(1), f.medial.Tz(1), med_lat(1), med_lat(2), med_lat(3), 0, 'r')
        else
            med_lat = f.medial.translations_mean - f.lateral.translations_mean;
            quiver3(f.lateral.Tx(1), f.lateral.Ty(1), f.lateral.Tz(1), med_lat(1), med_lat(2), med_lat(3), 0, 'r')
        end
        % Proximal-distal axis
        prox_dist = f.proximal.translations_mean - o;
        quiver3(o(1), o(2), o(3), prox_dist(1), prox_dist(2), prox_dist(3), 0, 'r');
        % grid;
        axis square;
        legend([plot_h, plot_f], {"Tibia", "Femur"})


end

function y = calc_means(x)
    find_mean = @(c) mean(c, "omitmissing");
    y.Tx = find_mean(vertcat(x.Tx));
    y.Ty = find_mean(vertcat(x.Ty));
    y.Tz = find_mean(vertcat(x.Tz));
end

function h = text_mean(y, name)
    h = text(y.Tx, y.Ty, y.Tz, name);
end
function h = scatter_mean(y, colour)
    h = scatter3(y.Tx, y.Ty, y.Tz, colour);
end
