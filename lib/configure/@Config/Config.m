classdef Config < handle
    properties
        module
        postprocess
        file_parser
        camera_labels
        stl
    end

    methods
        function self = Config(module, postprocess, file_parser, camera_labels, stl)
            self.module = module;
            self.postprocess = postprocess;
            self.file_parser = file_parser;
            self.camera_labels = camera_labels;
            self.stl = stl;
        end

        function digit_str = digitisation_files(self)
            digit_str = self.file_parser.digitisation;
        end

        function [right, left] = sides(self)
            right = self.file_parser.right;
            left = self.file_parser.left;
        end
        function label = labels(self)
            switch self.module
                case Module.Knee
                    label = self.camera_labels.knee;
                case Module.Hip
                    label = self.camera_labels.hip;
            end
        end
    end
end
