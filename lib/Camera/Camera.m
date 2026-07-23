classdef Camera
    enumeration
        Generic
        Polaris
        Unknown
    end
    methods (Static)
        function [trackers, strays] = load_data(path)

            fid = fopen(path, 'r');
            header_line = fgetl(fid);
            headers = strsplit(header_line, ',');
            camera = Camera.from_headers(headers);

            switch camera
                case Camera.Generic
                    fclose(fid);
                    warning("Requires updating to Camera/generic.m to load from loaded files. Currently opens the file a second time.")
                    trackers = generic(path);
                    if isempty(trackers)
                        trackers = [];
                        return
                    end
                    trackers.add_camera(Camera.Generic);
                    strays = Option.None;
                case Camera.Polaris
                    try
                    [trackers, strays] = polaris(headers, fid);
                    catch ME
                        error("%s\nIn file: %s", ME.message, path)
                    end
                    if isempty(trackers)
                        error("Problematic camera data. Check that all trackers are being recorded on the Polaris software.\nFile: %s", path)
                    end
                    trackers.add_camera(Camera.Polaris);
                    fclose(fid);
                case Camera.Unknown
                    error("Unknown camera")
            end
        end

        function camera = from_headers(headers)
            if ismember(lower(headers{1}), {'time', 'frame'})
                camera = Camera.Generic;
            elseif strcmpi(headers{1}, 'tools')
                camera = Camera.Polaris;
            else
                camera = Camera.Unknown;
            end
        end
    end

    methods
        function labels_cell = get_possible_labels(self, labels)
            switch self
                case Camera.Polaris
                    labels_cell = labels.polaris;
                case Camera.Generic
                    labels_cell = labels.generic;
            end
        end


    end
end
