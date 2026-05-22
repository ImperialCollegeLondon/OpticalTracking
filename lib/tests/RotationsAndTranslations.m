classdef RotationsAndTranslations < matlab.unittest.TestCase
    properties (TestParameter)
        side = struct('right', true, 'left', false)
    end

    methods (Test)
        function zeros(self, side)
            motion.rotations = [0, 0, 0];
            motion.translations    = [0, 0, 0];
            self.verify_round_trip(motion, side);
        end

        function flexion(self, side)
            motion.rotations = [30, 0, 0];
            motion.translations    = [0, 0, 0];
            self.verify_round_trip(motion, side);
        end

        function vv(self, side)
            motion.rotations = [0, -5, 0];
            motion.translations    = [0, 0, 0];
            self.verify_round_trip(motion, side);
        end
        function ie(self, side)
            motion.rotations = [0, 0, 20];
            motion.translations    = [0, 0, 0];
            self.verify_round_trip(motion, side);
        end
        function ie_vv(self, side)
            motion.rotations = [0, -5, 20];
            motion.translations    = [0, 0, 0];
            self.verify_round_trip(motion, side);
        end
        function flex_ie(self, side)
            motion.rotations = [10, 0, 20];
            motion.translations    = [0, 0, 0];
            self.verify_round_trip(motion, side);
        end
        function flex_vv(self, side)
            motion.rotations = [10, -5, 0];
            motion.translations    = [0, 0, 0];
            self.verify_round_trip(motion, side);
        end

        function rotations(self, side)
            motion.rotations = [10, -5, 20];
            motion.translations    = [0, 0, 0];
            self.verify_round_trip(motion, side);
        end

        function translations(self, side)
            motion.rotations = [0, 0, 0];
            motion.translations    = [1.5, -2.3, 0.8];
            self.verify_round_trip(motion, side);
        end

        function combined(self, side)
            motion.rotations = [10, -5, 20];
            motion.translations    = [1.5, -2.3, 0.8];
            self.verify_round_trip(motion, side);
        end

    end

    methods (Access = private)
        function verify_round_trip(self, motion, is_right_knee)
            tol = 1e-5;
            T = findTrackerFixedFrames(Option(motion));
            [rxryrz,xyz] = rotationsAndTranslations(T, is_right_knee);
            self.verifyEqual(-rxryrz(1), motion.rotations(1), 'AbsTol', tol)
        end
    end
end

