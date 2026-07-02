function digitisation = find(self, specimen)
    is_spc = [self.specimen] == specimen;
    first = find(is_spc, 1);
    digitisation = self(first);
end
