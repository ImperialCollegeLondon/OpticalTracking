classdef testImplementationParity < matlab.unittest.TestCase

    properties
        angleTol = 1e-10
        translationTol = 1e-10
        matrixTol = 1e-10
    end

    methods (Test)

        %% ============================================================
        % Identity transform
        %==============================================================

        function testIdentityTransform(testCase)

            angles = [0 0 0];
            xyz = [0 0 0];

            T_ref = RvA.defineTrackerFixedFrame_v2(angles, xyz);
            T_new = defineTrackerFixedFrame(angles, xyz);

            testCase.verifyEqual( ...
                T_new, T_ref, ...
                'AbsTol', testCase.matrixTol);

        end


        %% ============================================================
        % Canonical rotations
        %==============================================================

        function testPureRotations(testCase)

            testAngles = [
                 10   0    0
                  0  10    0
                  0   0   10
                -30  45   60
                180   0    0
                  0  89    0
            ];

            xyz = [0 0 0];

            for i = 1:size(testAngles,1)

                angles = testAngles(i,:);

                T_ref = RvA.defineTrackerFixedFrame_v2(angles, xyz);
                T_new = defineTrackerFixedFrame(angles, xyz);

                testCase.verifyEqual( ...
                    T_new, T_ref, ...
                    'AbsTol', testCase.matrixTol, ...
                    sprintf('Rotation mismatch at case %d', i));

            end

        end


        %% ============================================================
        % Pure translations
        %==============================================================

        function testPureTranslations(testCase)

            translations = [
                 1   2   3
                -5   0   8
                 0   0   0
                10 -10  20
            ];

            angles = [0 0 0];

            for i = 1:size(translations,1)

                xyz = translations(i,:);

                T_ref = RvA.defineTrackerFixedFrame_v2(angles, xyz);
                T_new = defineTrackerFixedFrame(angles, xyz);

                testCase.verifyEqual( ...
                    T_new, T_ref, ...
                    'AbsTol', testCase.matrixTol);

            end

        end


        %% ============================================================
        % Randomized parity test
        %==============================================================

        function testRandomizedParity(testCase)

            rng(0);

            nTests = 1000;

            for i = 1:nTests

                angles = -180 + 360*rand(1,3);
                xyz = -100 + 200*rand(1,3);

                %% Build transforms

                T_ref = RvA.defineTrackerFixedFrame_v2(angles, xyz);
                T_new = defineTrackerFixedFrame(angles, xyz);

                %% Compare transforms

                testCase.verifyEqual( ...
                    T_new, T_ref, ...
                    'AbsTol', testCase.matrixTol, ...
                    sprintf('Transform mismatch at iteration %d', i));

                %% Extract transforms

                [angles_ref, xyz_ref] = ...
                    RvA.rotationsAndTranslations(T_ref, true);

                [angles_new, xyz_new] = ...
                    rotationsAndTranslations(T_new, true);

                %% Compare extracted quantities

                testCase.verifyEqual( ...
                    angles_new, angles_ref, ...
                    'AbsTol', testCase.angleTol, ...
                    sprintf('Angle mismatch at iteration %d', i));

                testCase.verifyEqual( ...
                    xyz_new, xyz_ref, ...
                    'AbsTol', testCase.translationTol, ...
                    sprintf('Translation mismatch at iteration %d', i));

            end

        end


        %% ============================================================
        % Left/right convention handling
        %==============================================================

        function testLeftRightConvention(testCase)

            angles = [20 -15 35];
            xyz = [5 10 15];

            T = defineTrackerFixedFrame(angles, xyz);

            [anglesRight, xyzRight] = ...
                rotationsAndTranslations(T, true);

            [anglesLeft, xyzLeft] = ...
                rotationsAndTranslations(T, false);

            %% Translation invariant

            testCase.verifyEqual( ...
                xyzRight, xyzLeft, ...
                'AbsTol', testCase.translationTol);

            %% Sign convention

            testCase.verifyEqual( ...
                anglesLeft(1), anglesRight(1), ...
                'AbsTol', testCase.angleTol);

            testCase.verifyEqual( ...
                anglesLeft(2), -anglesRight(2), ...
                'AbsTol', testCase.angleTol);

            testCase.verifyEqual( ...
                anglesLeft(3), -anglesRight(3), ...
                'AbsTol', testCase.angleTol);

        end


        %% ============================================================
        % Near-singular configurations
        %==============================================================

        function testNearGimbalLock(testCase)

            testAngles = [
                 0   89.9    0
                 0  -89.9    0
                45   89.99  30
            ];

            xyz = [1 2 3];

            for i = 1:size(testAngles,1)

                angles = testAngles(i,:);

                T_ref = RvA.defineTrackerFixedFrame_v2(angles, xyz);
                T_new = defineTrackerFixedFrame(angles, xyz);

                testCase.verifyEqual( ...
                    T_new, T_ref, ...
                    'AbsTol', 1e-8);

            end

        end

    end
end
