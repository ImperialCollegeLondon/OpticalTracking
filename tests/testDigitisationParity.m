classdef testDigitisationParity < matlab.unittest.TestCase

    properties
        angleTol = 1e-10
        translationTol = 1e-10
        matrixTol = 1e-10
    end

    methods (Test)
        function testIdentityTransform(testCase)
            config = create_default_config().set_module(Module.Knee);
            path = fullfile("lib", "tests", "data");
            digitisation = Digitisation.new(path, config);

            %% Set up RvA's code
            right = digitisation.is_right_knee;
            femur = digitisation.bone.femur;
            FMed = femur.medial.unwrap().translations_mean();
            FLat = femur.lateral.unwrap().translations_mean();
            FProx = femur.proximal.unwrap().translations_mean();

            tibia = digitisation.bone.tibia;
            TMed = tibia.medial.unwrap().translations_mean();
            TLat = tibia.lateral.unwrap().translations_mean();
            TDis = tibia.distal.unwrap().translations_mean();

            % Rva 131:161
            [gTf0,originF]=defineBodyFixedFrameFemur_v2(FMed,FLat,FProx,right);%The body frame of reference in the global coordiante system for the femur
            grf0=[originF,1]';%r is a point, T is a frame of reference.  This point is the location of the origin of the body fixed coordinate system

            [gTt0,originT]=defineBodyFixedFrameTibia_v2(TMed,TLat,TDis,right);%The body frame of reference in the global coordiante system for the tibia
            grt0=[originT,1]';%r is a point, T is a frame of reference.  This point is the location of the origin of the body fixed coordinate system

            %% Load original points for the trackers

            [gTtt0]=defineTrackerFixedFrame_v2(tibiaR,tibiaXYZ);%The tibia tracker frame in global coordinates
            [gTft0]=defineTrackerFixedFrame_v2(femurR,femurXYZ);%The femur tracker frame in global coordinates

            %% Relate body fixed frames and origin to the tracker rigid body

            ftTfc=gTft0\gTf0;%a constant transform of the body fixed frame in the tracker frame of reference (assumes rigid body)
            ttTtc=gTtt0\gTt0;%a constant transform of the body fixed frame in the tracker frame of reference (assumes rigid body)


            ftrfc=gTft0\grf0;%relating the origin of the body fixed coordiate system to tracker frame of reference
            ttrtc=gTtt0\grt0;%relating the origin of the body fixed coordiate system to tracker frame of reference


            % end RvA 131:161
            testCase.verifyEqual(ttTtc, digitisation.transforms.tibia.transform.unwrap(), 'AbsTol', testCase.matrixTol);
            testCase.verifyEqual(ftTfc, digitisation.transforms.femur.transform.unwrap(), 'AbsTol', testCase.matrixTol);

            testCase.verifyEqual(ttrtc, digitisation.transforms.tibia.origin.unwrap(), 'AbsTol', testCase.matrixTol);
            testCase.verifyEqual(ftrfc, digitisation.transforms.femur.origin.unwrap(), 'AbsTol', testCase.matrixTol);
        end
    end
end
