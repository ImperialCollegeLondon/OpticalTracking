function r = with_label(self, label)
    labels = [self.Label];
    has_label = labels.map(@(x) strcmp(x, label)).map(@cell2mat);
    if has_label.is_none()
        r = Option.None;
        return
    end
    labeled = self(has_label.unwrap());
    r = Option(labeled);
end
