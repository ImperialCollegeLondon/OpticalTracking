function R = nonzero_to_one(input)
    R = zeros(size(input)); 
    R(~isnan(input) & input ~= 0) = 1; 
end