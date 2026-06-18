function [origin, direction] = cor_from_tibia(self)
% Relative to a static femur. i.e., in femoral frame of reference.
    get_ml = @(x) squeeze(x(1:2, 1, :));
    get_origin = @(x) squeeze(x(1:2, 4, :));

    transforms = [self.transforms];
    fTts = {transforms.fTts};
    % origin = cellfun(@(x) safe_apply(get_origin, x), fTts, UniformOutput=false);
    % direction = cellfun(@(x) safe_apply(get_ml, x), fTts, UniformOutput=false);

    tsTf = cellfun(@(x) pageinv(x), fTts, UniformOutput=false);
    origin = cellfun(@(x) safe_apply(get_origin, x), tsTf, UniformOutput=false);
    direction = cellfun(@(x) safe_apply(get_ml, x), tsTf, UniformOutput=false);

end

function out = safe_apply(fn, x)
    if isempty(x)
        out = [];
    else
        out = fn(x);
    end
end
