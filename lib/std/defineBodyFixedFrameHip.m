function gTf0 = defineBodyFixedFrameHip(hip,right)
ucross=@(u_,v_) cross(u_,v_)/norm(cross(u_,v_),2); %define function to find unit cross product
uvector=@(a,b) (b-a)/norm(b-a,2); %define a function to find a unit vector from a to b

asis = hip.asis;
psis = hip.psis;
% pt = hip.pubic_tubercle;
origin = hip.origin;
pot = hip.pot;
if asis.is_none || psis.is_none || pot.is_none
    gTf0 = Option.None;
    return
end
asis = asis.map(@(x) x.translations_mean).unwrap();
psis = psis.map(@(x) x.translations_mean).unwrap();
% pt = pt.map(@(x) x.translations_mean).unwrap();
origin = origin.map(@(x) x.translations_mean).unwrap();


%% Create plane from pot digitisation. Make asis-asis axis the normal to this plane
pts_c = pot.map(@(x) -x.translations_mean + x.translations).unwrap();
[~, ~, V] = svd(pts_c, 0);
normal = V(:, end)';
normal = normal/norm(normal);

centroid = pot.map(@translations_mean).unwrap();
if dot(normal, asis - centroid) < 0
    normal = -normal;
end

t_foot = dot(centroid - asis, normal);
axis_origin = asis + t_foot * normal;

if right
    I_ = uvector(axis_origin, asis);
else
    I_ = uvector(asis, axis_origin);
end


tempJ_ = uvector(psis, asis)'; % Is this approximate? Don't think so
K_ = ucross(I_,tempJ_);
J_ = ucross(K_, I_); % Make psis-asis orthogonal

rot=[I_',J_',K_'];
rot=[rot,[0 0 0]';0 0 0 1];

trans=[1 0 0 origin(1);
       0 1 0 origin(2);
       0 0 1 origin(3)
       0 0 0 1];


gTf0=trans*rot; % Note this is the same as gTf0=[rot,origin';0 0 0 1];

gTf0 = Option(gTf0);

%check for orthogonality
% angle = @(u_,v_) acosd(dot(u_,v_)/(norm(u_,2)*norm(v_,2))); %define a function to calculate the angle between two vectors
% angle(I_,J_)
% angle(J_,K_)
% angle(I_,K_)

end
