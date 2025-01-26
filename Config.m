classdef Config
    properties
        cfg
    end
    methods
        function config = Config(cfg)
            config.cfg = cfg;
        end
        function r = label(obj)
            if obj.is_polaris
                r = obj.polaris;
            else
                r = obj.certus;
            end
        end
    end
end