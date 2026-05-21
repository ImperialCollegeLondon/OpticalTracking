function result = intersect_surface(self)
    result = struct('specimen', [], 'loading_condition', [], 'state', [], 'intersection', []);
    result = repmat(result, numel(self), 1);
    for i = 1:numel(self)
        fTts = self(i).transforms.fTts;
    
        surface_ml    = fTts(1:2, 1, :);
        surface_origin = fTts(1:2, 4, :);
        
    
        femur_ml = zeros(2, 2, size(fTts, 3));
        % tibia ml = [1 0]
        femur_ml(1, 1, :) = 1;

        % Intersection points
        femur_ml(1, 2, :) = -surface_ml(1, 1, :);
        femur_ml(2, 2, :) = -surface_ml(2, 1, :);
        ft = pagemldivide(femur_ml, surface_origin);
    
        result(i).specimen          = self(i).specimen;
        result(i).loading_condition = self(i).loading_condition;
        result(i).state             = self(i).state;
        result(i).intersection      = ft(1) * femur_ml;
    end

end