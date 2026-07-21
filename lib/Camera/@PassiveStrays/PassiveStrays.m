classdef PassiveStrays
    properties
        Tx
        Ty
        Tz
        Timestamp
    end
    methods
        function self = PassiveStrays(tx, ty, tz, time)
            arguments
                tx = []
                ty = []
                tz = []
                time = []
            end
            self.Tx = tx;
            self.Ty = ty;
            self.Tz = tz;
            self.Timestamp = time;
        end
    end
end
