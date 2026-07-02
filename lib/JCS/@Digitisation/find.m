function digitisation = find(self, specimen)
    is_specimen = [self.specimen] == specimen;
    digitisation = self(find(is_specimen, 1));
end
