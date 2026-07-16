classdef ConfigBuilder
    properties
        module
        postprocess
        file_parser
        camera_labels
        stl
    end

    methods
        function self = ConfigBuilder()
            %% Defaults
            self.file_parser.right = {'rk', 'right', 'r'};
            self.file_parser.left = {'lk', 'left', 'l'};
            self.file_parser.digitisation = {'digit', 'calibr'}; 
            return
        end
        function config = set_module(self, module)
            arguments
                self
                module Module
            end
            config = Config(module, self.postprocess, self.file_parser, self.camera_labels, self.stl);
        end
    end
end
