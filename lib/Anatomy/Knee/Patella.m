classdef Patella < Anatomy
    properties
        tracker
        medial
        lateral
        distal
        inferior
        superior
    end
    methods
        function self = Patella(medial, lateral, distal, inferior, superior, tracker)
            self.medial   = medial;
            self.lateral  = lateral;
            self.distal = distal;
            self.inferior = inferior;
            self.superior = superior;
            self.tracker  = tracker;
        end
    end
end
