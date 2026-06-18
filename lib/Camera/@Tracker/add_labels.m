function self = add_labels(self, labels)
    names = {self.Name};
    for i = 1:numel(names)
        name = names{i};
        labels_cell = self(i).Camera.get_possible_labels(labels);
        labels_cell = struct2cell(labels_cell);

        found_label_cells = cellfun(@(x) any(strcmp(x, strsplit(name, ' '))), labels_cell, 'UniformOutput',false);
        label_idx = cell2mat(found_label_cells);
        if sum(label_idx) > 1
            error("Tracker labels must be unique. Check defaults.m to assign them.")
        end
        label = Option(labels_cell{label_idx});

        if label.is_none()
            non_empty = labels_cell(~cellfun(@isempty,labels_cell));
            idx = cellfun(@(x) any(contains(name, x)) , non_empty, 'UniformOutput',false);
            idx = [idx{:}];
            label = Option(non_empty(idx));
        end
        self(i).Label = label;
    end
end
