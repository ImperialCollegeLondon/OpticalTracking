function gTf0 = defineBodyFixedFrameHip(hip,right)
asis = hip.asis;
psis = hip.psis;
pt = hip.pubic_tubercle;
origin = hip.origin;
if asis.is_none || psis.is_none || pt.is_none
    gTf0 = [];
    return
end
asis = asis.map(@(x) x.translations_mean).unwrap();
psis = psis.map(@(x) x.translations_mean).unwrap();
pt = pt.map(@(x) x.translations_mean).unwrap();
origin = origin.map(@(x) x.translations_mean).unwrap();

ucross=@(u_,v_) cross(u_,v_)/norm(cross(u_,v_),2); %define function to find unit cross product
uvector=@(a,b) (b-a)/norm(b-a,2); %define a function to find a unit vector from a to b

J_ = uvector(psis, asis)';
tempK_= uvector(origin,pt)'; %the pubic_tubercle point is approximate and thus this axis is not necessarily perpendicular to the psis-asis axis.
% This needs to be double checked:
if right
    I_ = ucross(J_, tempK_);
else
    I_ = ucross(tempK_, J_);
end

K_ = ucross(I_,J_);%%recalculate K so perpendicular to give orthogonal coordinate system.

if all(cross(tempK_, I_) == zeros(3,1)) || all(cross(I_, J_) == zeros(3,1))
error("Cross product in Femur is zero. Double check femoral digitisation!!")
end

rot=[I_,J_,K_];
rot=[rot,[0 0 0]';0 0 0 1];

trans=[1 0 0 origin(1);
       0 1 0 origin(2);
       0 0 1 origin(3)
       0 0 0 1];


gTf0=trans*rot; % Note this is the same as gTf0=[rot,origin';0 0 0 1];


%check for orthogonality
% angle = @(u_,v_) acosd(dot(u_,v_)/(norm(u_,2)*norm(v_,2))); %define a function to calculate the angle between two vectors
% angle(I_,J_)
% angle(J_,K_)
% angle(I_,K_)

end
