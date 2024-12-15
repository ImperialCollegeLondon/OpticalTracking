function res = ucross(u_,v_)
%define function to find unit cross product
if isempty(u_) || isempty(v_)
    res = [];
    return
end
res = cross(u_,v_)/norm(cross(u_,v_),2);
end
