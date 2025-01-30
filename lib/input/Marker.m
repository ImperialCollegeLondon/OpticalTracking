classdef Marker
    properties
        probe {mustBeText} = ""
        label {mustBeText} = ""
        Rx {mustBeNumeric}
        Ry {mustBeNumeric}
        Rz {mustBeNumeric}
        Tx {mustBeNumeric}
        Ty {mustBeNumeric}
        Tz {mustBeNumeric}
    end
    methods(Static)
        function marker = default(probe, label)
            marker = Marker(probe, label, [], [], [], [], [], []);
        end
    end
    methods
        function marker = Marker(probe, label, rx, ry, rz, tx, ty, tz)
            marker.probe = probe;
            marker.label = label;
            marker.Rx = rx;
            marker.Ry = ry;
            marker.Rz = rz;
            marker.Tx = tx;
            marker.Ty = ty;
            marker.Tz = tz;
        end
        function r = rotations(obj)
            r = [obj.Rx obj.Ry obj.Rz];
        end
        function r = rotations_mean(obj)
            if isempty(obj.rotations)
                r = [];
                return
            end
                r = mean(obj.rotations(), "omitmissing");
        end
        function r = translations(obj)
            r = [obj.Tx obj.Ty obj.Tz];
        end
        function r = translations_mean(obj)
            if isempty(obj.translations)
                r = [];
                return
            end
            r = mean(obj.translations(), "omitmissing");
        end
        function r = with_label(obj, label)
            has_label = strcmp([obj.label], label);
            r = Option(obj(has_label));
        end
    end
end