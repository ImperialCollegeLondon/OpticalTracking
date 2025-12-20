classdef Landmark
    properties
        name
        probes % {mustBeA(probes, 'Marker')} = Marker.default("", "");
    end
    methods
        function landmark = Landmark(name, tracker)
            landmark.name = name;
            landmark.probes = tracker;
        end

    end
end
