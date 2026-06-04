function optimise(self, trajectories)
    arguments
        self Digitisation
        trajectories Trajectory
    end

    if isempty(trajectories)
        warning("No trajectories ")
        return
    end

    specimens = unique([self.specimen]);
    for sp = 1:numel(specimens)
        is_specimen = [trajectories.SpecimenName] == specimens(sp);
        trajectory = trajectories(is_specimen);

        for d = 1:numel(self)
            digitisation = self(d);

            switch digitisation.module
                case Module.Knee
                    optimise_knee(digitisation, trajectory)
                case Module.Hip
                    error("not yet implemented");
            end
        end
    end

end

function optimised = optimise_knee(digitisation, trajectory)
    optimised = digitisation;
    flexion = trajectory.Kinematics.tibiofemoral.flexion;
    gTfi = trajectory.Transform.gTfi;
    gTti = trajectory.Transform.gTti;

[~, flex] = max(flexion);
[~, ext] = min(flexion);

    %Screw axis from min to max flexion, using SARA approach (Ehrig 2007)
    R1=gTfi(1:3,1:3,flex);%pose of femoral reference frame in global coordinates when in deep flexion
    R0=gTfi(1:3,1:3,ext);%fem reference frame in global coordinates when in extension
    S1=gTti(1:3,1:3,flex);%Tib reference frame in global coordinates in flexion
    S0=gTti(1:3,1:3,ext);%Tib reference frame in global coordinates in extension
    t1=gTfi(1:3,4,flex);%location of the femoral reference frame origin in global coordinates in flexion
    t0=gTfi(1:3,4,ext);%location of the femoral reference frame origin in global coordinates in extension
    d1=gTti(1:3,4,flex);%location of the tibial reference frame origin in global coordinates in flexion
    d0=gTti(1:3,4,ext);%location of the tibial reference frame origin in global coordinates in extension

    LHS=R1-S1*S0'*R0;%multiply out line 1 and line 2 of matrix from Ehrig 2007 equation 2.  Then solve simultaneous equations to eliminate c1 or c2.  Collect like terms for remaining of c1 or c2.  Then LHS is the Left hand side of this equation.  RHS is the right hand side of this equation.  See photo in this folder or see Ehrig 2019, equation 13 for simplified example.
    RHS=(d1-t1)-S1*S0'*(d0-t0);%see comment above
    [U,E,V]=svd(LHS);%solve the equation LHS=RHS using singular value decomposition and the pseudo inverse.
    SARAfullROM=V(1:3,3);%helical axis direction in femoral reference frame.  See Ehrig 2019 paragraph below equation 13.
    point=V*diag([1/E(1,1),1/E(2,2),0])*U'*RHS;%solving to find c1 Ehrig 2007 equation 2, or cf photo in this folder using psuedoinverse from SVD.  The point is in the femoral reference frame.  For singular values of zero (or very close to zero, set their inverse to 0, rather than infinity, hence why pseudo inverse).

    %vector equation of helical axis is r_=point+mu*SARAfullROM.  Need to find
%mu.  Using formula from here https://en.wikipedia.org/wiki/Lineplane_intersection to find mu.
    mu=dot(([0,0,0]'-point),[1,0,0])/dot(SARAfullROM,[1,0,0]);%in femoral reference frame noting that sagittal plane normal is just the femoral X axis I.e. [1,0,0] in femoral reference frame,  and noting that 0,0,0 is a point on the mid femoral sagittal plane
    isp=point+mu*SARAfullROM;%intersection point in femoral reference frame
    gTf0 = defineBodyFixedFrameFemur(optimised.bone.femur, optimised.config.is_right_knee);
    gOf0=gTf0*[isp;1];%convert isp from femoral frame to global frame to find the new femoral origin in the global reference frame
end
