function trimmed = validate(self)
    % Interactively remove samples that are spatially
    % inconsistent with the rest of the digitisation.
    fig = figure('Name', sprintf('Validate: %s', self(1).Name), 'NumberTitle', 'off');

    %% Isolate long from short. Long: tibial surface outline. Short: specific landmarks

    tx = {self.Tx};
    sizes = cellfun(@numel, tx);
    is_long = sizes > 2*median(sizes);

    surface = self(is_long);
    if isempty(surface)
        trimmed = self;
        return
    end
    h = surface.visualise();
    hold on;
    self(~is_long).visualise();


    axis equal; grid on;
    title({'Rotate to isolate bad points (toolbar), then Brush to select them.', ...
           'Click Done when finished.'});

    uicontrol(fig, 'Style', 'pushbutton', 'String', 'Done', ...
              'Units', 'normalized', 'Position', [0.45 0.01 0.1 0.05], ...
              'Callback', 'uiresume(gcbf)');
    brush(fig, 'on');
    uiwait(fig);

    if isvalid(h)
        flagged = get(h, 'BrushData');
    else
        flagged = [];   % window closed instead of pressing Done
    end
    if isvalid(fig)
        close(fig);
    end

    if ~isempty(flagged) || isempty(surface)
        to_remove = logical(flagged(:));
    else
        to_remove = false(size(surface.Tx));
    end

    if ~isempty(surface)
        trimmed = copy(surface);
        trimmed.keep(~to_remove);
        trimmed = [trimmed self(~is_long)];
    else
        trimmed = self(~is_long);
    end
end
