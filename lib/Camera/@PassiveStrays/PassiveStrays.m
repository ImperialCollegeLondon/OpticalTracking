classdef PassiveStrays
    properties
        Tx
        Ty
        Tz
    end
    methods
        function self = PassiveStrays(tx, ty, tz)
            arguments
                tx = []
                ty = []
                tz = []
            end
            self.Tx = tx;
            self.Ty = ty;
            self.Tz = tz;
        end
    end
end
