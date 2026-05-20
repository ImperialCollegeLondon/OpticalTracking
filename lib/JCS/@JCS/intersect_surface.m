function result = intersect_surface(self)
    result = struct('specimen', [], 'loading_condition', [], 'state', [], 'intersection', []);
    result = repmat(result, numel(self), 1);
    for i = 1:numel(self)
        tTts = self(i).transforms.tTts;
    
        surface_ml    = tTts(1:2, 1, :);
        surface_origin = tTts(1:2, 4, :);
        
    
        tibia_ml = zeros(2, 2, size(tTts, 3));
        % tibia ml = [1 0]
        tibia_ml(1, 1, :) = 1;

        % Intersection points
        tibia_ml(1, 2, :) = -surface_ml(1, 1, :);
        tibia_ml(2, 2, :) = -surface_ml(2, 1, :);
        st = pagemldivide(tibia_ml, surface_origin);
    
        result(i).specimen          = self(i).specimen;
        result(i).loading_condition = self(i).loading_condition;
        result(i).state             = self(i).state;
        result(i).intersection      = st(1) * tibia_ml;
    end

end