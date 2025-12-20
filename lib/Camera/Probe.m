classdef Probe
    properties
        label
        name
    end
    methods (Access = private)
        function self = Probe(label, name)
            self.label = label;
            self.name = name;
        end
    end
    methods (Static)
        function probe = from_names(labels, names)
            for i = 1:numel(names)
                probe(i).name = names{i};
                name = names{i}{1};

                labels_cell = struct2cell(labels);
                found_label_cells = cellfun(@(x) any(strcmp(x, strsplit(name, ' '))), labels_cell, 'UniformOutput',false);
                label_idx = cell2mat(found_label_cells);
                label = Option(labels_cell{label_idx});

                if label.is_none()
                    non_empty = labels_cell(~cellfun(@isempty,labels_cell));
                    idx = cellfun(@(x) any(contains(name, x)) , non_empty, 'UniformOutput',false);
                    idx = [idx{:}];
                    label = Option(non_empty(idx));
                end

                probe(i).label = label;
            end
        end

        function self = from_config()
        end
        function self = from()
        end
    end
end
