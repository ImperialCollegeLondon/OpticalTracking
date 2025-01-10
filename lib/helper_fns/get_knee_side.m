function is_right_knee = get_knee_side(root, right_text, left_text)
    parent_folder_full_fp = split(root, filesep);
    test_name = parent_folder_full_fp{end};
    test_name_split = lower(string(split(test_name, {'_', ' ', '-'})));
    if any(test_name_split == lower(right_text), "all")
        is_right_knee = true;
    elseif any(test_name_split == lower(left_text), "all")
        is_right_knee = false;
    end
end