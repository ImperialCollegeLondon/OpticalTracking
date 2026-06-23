classdef Camera
    enumeration
        Certus
        Polaris
        Unknown
    end
    methods (Static)
        function [trackers, strays] = load_data(path)

            fid = fopen(path, 'r');
            if fid == -1
                error('read_ndi_csv:fileNotFound', 'Cannot open file: %s', path);
            end
            header_line = fgetl(fid);
            headers = strsplit(header_line, ',');
            camera = Camera.from_headers(headers);

            switch camera
                case Camera.Certus
                    warning("Requires updating to Camera/certus.m to load from loaded files. Currently opens the file a second time.")
                    trackers = certus(path);
                    if isempty(trackers)
                        trackers = [];
                        return
                    end
                    trackers.add_camera(Camera.Certus);
                    strays = [];
                case Camera.Polaris
                    [trackers, strays] = polaris(headers, fid);
                    if isempty(trackers)
                        error("Problematic camera data. Check that all trackers are being recorded on the Polaris software.\nFile: %s", path)
                    end
                    trackers.add_camera(Camera.Polaris);
                case Camera.Unknown
                    error("Unknown camera")
            end

            fclose(fid);

            if numel(trackers) < 2
                warning("Fewer than two trackers found.");
            end
        end

        function camera = from_headers(headers)
            if strcmpi(headers{1}, 'frame')
                camera = Camera.Certus;
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
                case Camera.Certus
                    labels_cell = labels.certus;
            end
        end


    end
end
