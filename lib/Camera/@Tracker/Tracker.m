classdef Tracker < handle & matlab.mixin.Copyable
    properties
        Landmark
        Name
        Label
        Q0, Qx, Qy, Qz
        Rx, Ry, Rz,
        Tx, Ty, Tz,
        Error
    end
    properties (Access = private)
        Camera
    end
    methods (Static)
        function tracker = default(name, label)
            tracker = Tracker(name, [], [], [], [], [], [], []);
            tracker.Label = label;
        end
    end
    methods
        function self = Tracker(name, q0, qx, qy, qz, tx, ty, tz, error)
            self.Name  = name;

            self.Tx    = tx;
            self.Ty    = ty;
            self.Tz    = tz;

            self.Q0  = q0;
            self.Qx  = qx;
            self.Qy  = qy;
            self.Qz  = qz;

            [rx, ry, rz] = quaternion2euler(q0, qx, qy, qz);

            self.Rx    = rx;
            self.Ry    = ry;
            self.Rz    = rz;

            self.Error = error;
        end
    end

    methods (Access = private)
        function keep(self, mask)
            % Mutates self in place - only ever called on a copy.
            self.Q0    = self.Q0(mask);
            self.Qx    = self.Qx(mask);
            self.Qy    = self.Qy(mask);
            self.Qz    = self.Qz(mask);
            self.Rx    = self.Rx(mask);
            self.Ry    = self.Ry(mask);
            self.Rz    = self.Rz(mask);
            self.Tx    = self.Tx(mask);
            self.Ty    = self.Ty(mask);
            self.Tz    = self.Tz(mask);
            self.Error = self.Error(mask);
        end
    end

end

