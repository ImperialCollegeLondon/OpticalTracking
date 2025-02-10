function R = clean_mean(data)
% Squeeze and remove empty quanta. If they are not removed, later on we end
% up with weird values where the gaps were.
    R = squeeze(data);
    % R = R(any(R, 2), :); % Maybe we should leave the gaps.
end