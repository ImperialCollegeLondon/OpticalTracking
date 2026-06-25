function r = translations_mean(self)
if isempty(self.translations) | all(isnan(self.translations), "all")
    r = [];
    return
end
r = mean(self.translations(), 1, "omitmissing");
end
