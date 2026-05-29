function gTf0 = defineBodyFixedFrameHip(hip,right)
    error("Not correctly implemented");
asis = hip.asis.map(@(x) x.translations_mean);
psis = hip.psis.map(@(x) x.translations_mean);
pt = hip.pubic_tubercle.map(@(x) x.translations_mean);
if asis.is_none || psis.is_none || pt.is_none
    gTf0 = [];
    return
end
asis = asis.unwrap();
psis = psis.unwrap();
pt = pt.unwrap();

angle = @(u_,v_) acosd(dot(u_,v_)/(norm(u_,2)*norm(v_,2))); %define a function to calculate the angle between two vectors
ucross=@(u_,v_) cross(u_,v_)/norm(cross(u_,v_),2); %define function to find unit cross product
uvector=@(a,b) (b-a)/norm(b-a,2); %define a function to find a unit vector from a to b

origin = (asis+psis)/2;
if right
    I_ = uvector(asis,psis)'; %RIGHT KNEE, X Axis
else
    I_ = uvector(psis,asis)'; %LEFT KNEE, X Axis
end

tempK_= uvector(origin,pt)'; %the pubic_tubercle point is approximate and thus this axis is not necessarily perpendicular to epicondylar axis
J_ = ucross(tempK_,I_); % Y-axis
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
% angle(I_,J_)
% angle(J_,K_)
% angle(I_,K_)

end
