function r = translations_mean(self)
if isempty(self.translations)
    r = [];
    return
end
r = mean(self.translations(), "omitmissing");
end
