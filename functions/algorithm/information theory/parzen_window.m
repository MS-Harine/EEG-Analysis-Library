% Parzen Window (Parzen, 1962)
% 
% K. Ang, et al. Filter bank common spatial pattern algorithm on
% BCI competition IV datasets 2a and 2b, Frontiers in Neuroscience, 2012

function [p] = parzen_window(y, h)

    % Check input
    if isempty(h)
        n = length(y);
        sigma = std(y);

        h = sigma * (4 / 3*n)^(1/5);
    end

    % Parzen window
    p = exp(-y^2 / 2*h^2) / sqrt(2 * pi);
end
