classdef Femur < Anatomy
    properties
        tracker
        medial
        lateral
        proximal
    end
    methods
        function self = Femur(medial, lateral, proximal, tracker)
            self.medial   = medial;
            self.lateral  = lateral;
            self.proximal = proximal;
            self.tracker  = tracker;
        end
    end
end
