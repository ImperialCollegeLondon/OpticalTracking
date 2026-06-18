classdef PassiveStrays
    properties
        Tx
        Ty
        Tz
    end
    methods
        function self = PassiveStrays(tx, ty, tz)
            self.Tx = tx;
            self.Ty = ty;
            self.Tz = tz;
        end
    end
end
