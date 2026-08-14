function widths = get_widths(cor, digitisation)
    arguments
        cor CentreOfRotation
        digitisation Digitisation
    end

    widths = nan(numel(cor), 1);
    for n = 1:numel(cor)
        specimen = cor(n).specimen;
        idx = find([digitisation.specimen] == specimen, 1);
        width = digitisation(idx).transforms.tibia.width.unwrap();
        widths(n) = width;
    end
end