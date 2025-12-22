classdef Tibia < Anatomy
    properties
        tracker
        medial
        lateral
        distal
    end
    methods
        function self = Tibia(medial, lateral, distal, tracker)
            self.medial   = medial;
            self.lateral  = lateral;
            self.distal = distal;
            self.tracker  = tracker;
        end
    end
end
