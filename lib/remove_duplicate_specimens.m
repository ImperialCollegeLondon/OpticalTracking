function specimen = remove_duplicate_specimens(specimen_with_duplicates)
specimen_names = string({specimen_with_duplicates.name});

% creates a n x n matrix of from n specimen names. Identity matrix => all unique specimen names.
% Values outside the diagonal mean, for example, that folder 3 and 4 have the same specimen name.
% This is symmetrical about the diagonal, so folders 4 and 3 also have the same name.
% tril(A, -1) removes the diagonal (name equal to itself) and one of the symmetric pair
duplicate_name = tril(specimen_names' == specimen_names, -1);

[idx_first, idx_second] = find(duplicate_name);

specimen = specimen_with_duplicates;
fields = fieldnames(specimen);

% Condenses rows of the struct when two rows have the same `name`. 
for j = 1:numel(idx_first)
    for f = 1:numel(fields)
        if strcmp(fields{f}, 'name')
            continue
        end

        field = fields(strcmpi(fields, fields{f})); % Tries to compensate for case differences. Best is to add a renaming regex in configure/clean_specimen_condition()
        if isscalar(field)
            field = field{:};
            both = [specimen(idx_first(j)).(field), specimen(idx_second(j)).(field) ];
        else
            len = length(field);
            fields{f} = field{1};
            both = [];
            % Sometimes the same loading condition is present in two different folders for the same specimen.
            % In that case, it just combines them.
            for ll = 1:len
                both = [both, specimen(idx_first(j)).(field{ll}), specimen(idx_second(j)).(field{ll}) ];
            end
        end
        specimen(idx_first(j)).(fields{f}) = both;
    end
end
specimen(idx_second) = []; % Clear out the row that has been moved over