function O = clean_specimen_condition(input)
% Defines the functions used to clean up the knee state.
% Necessary because naming of the files is inconsistent,
% "repair", "recon" and "reconstruction" would be considered different
% runs.
%
% You should name your folders better, but this allows you to post-process
% common mistakes.

%% Consistency of case
    O = replace(input, 'reconstruction', 'recon');
    O = replace(O, "int", "Int");
    O = replace(O, "ant", "Ant");
    O = replace(O, "ext", "Ext");
    O = replace(O, "neut", "Neut");
    O = replace(O, "sps", "SPS");
    O = replace(O, " ", "_");
    O = replace(O, "COR_", "COR");
    O = replace(O, "Ld", "LD");  % Correct case for ACLd to ACLD
    O = replace(O, "Lr", "LR");  % Correct case for ACLr to ACLR
    O = replace(O, "Sd", "SD");  % Correct case for ALSd to ALSD
    O = replace(O, "Sr", "SR");  % Correct case for ALSr to ALSR
    % O = replace(O, "Cut", "cut");
    % O = replace(O, 'repair', 'recon');
    % O = replace(O, 'every', 'Every');
    O = replace(O, 'varus', 'Varus');
    O = replace(O, 'External Anterior', 'Anterior External');
    O = replace(O, 'Internal Anterior', 'Anterior Internal');

    %% Corrections of the stupid mistakes
    % O = replace(O, 'All_states', 'Everything_recon');
    O = regexprep(O, '_\d$', ''); % Removes _2, for example.
    % O = regexprep(O, 'internal .*', 'Internal', 'ignorecase');
    % O = regexprep(O, 'external .*', 'External', 'ignorecase');
    % O = regexprep(O, '[ _][rR]otation.*', '');
    % O = regexprep(O, 'ante[rior]*', 'Anterior', 'ignorecase');
    % O = regexprep(O, '\..*', ''); % A literal dot followed by anything, like a file being called "name.csv.csv".
    % O = regexprep(O, '[se][sp][sp]', 'Sps', 'ignorecase'); % This one is so stupid. makes ESP match Sps.
    % O = regexprep(O, 'int[ern].*[ _]ant', 'Ant Int', 'ignorecase');
    % O = regexprep(O, 'int[ _]ant', 'Ant Int', 'ignorecase'); %
end
