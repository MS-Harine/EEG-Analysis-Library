function [H] = entropy(X)

    % Check input
    if ~isvector(X)
        error('Only vector data is supported');
    end

    % Information entropy
    N = length(X);
    classes = unique(X);

    H = 0;
    for i = 1:length(classes)
        p = sum(X == classes(i)) / N;
        H = H + (-p * log2(p));
    end

end

