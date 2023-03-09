function [F_bar, V, W_bar, W] = filterbank_csp(X, y, srate, m, select_mode, k)

    % Initialize
    y_types = unique(y);
    trials_x = length(y);
    channels_x = size(X, 2);
    band_range = [4 8; 8 12; 12 16; 16 20; 20 24; ...
                  24 28; 28 32; 32 36; 36 40];

    % Check input
    if ~isvector(y)
        error('Parameter y should be vector');
    end

    if length(unique(y)) > 2 || isscalar(unique(y))
        error('This function only support for binary class problem');
    end

    if nargin < 4
        m = 2;
    end

    if nargin < 5
        select_mode = 'MIRSR';
        % select_mode = 'MIBIF';
    end

    if nargin < 6
        if strcmp(select_mode, 'MIRSR')
            k = round(2 * log2(length(band_range) * 2 * m));
        else
            k = 4;
        end
    end
    
    % Bandpass
    X_band = zeros(length(band_range), size(X));
    for b = 1:length(band_range)
        filter_band = band_range(b, :);
        for i = 1:length(y)
            X_band(b, i, :, :) = ft_preproc_bandpassfilter(X(i, :, :), srate, filter_band);
        end
    end

    % CSP
    W = zeros(length(band_range), channels_x, channels_x);
    W_bar = zeros(length(band_range), 2*m, channels_x);
    V = zeros(trials_x, length(band_range) * 2*m);

    X1 = X_band(:, y == y_types(1), :, :);
    X2 = X_band(:, y == y_types(2), :, :);
    for b = 1:length(band_range)
        W(b, :, :) = csp(X1(b, :, :, :), X2(b, :, :, :));
    end

    for i = 1:m
        W_bar(:, :, i) = W(:, :, i);
        W_bar(:, :, 2*m - i + 1) = W(:, :, channels_x - i + 1);
    end

    for i = 1:trials_x
        v_i = [];
        for b = 1:length(band_range)
            mat = squeeze(W_bar(b, :, :))' * squeeze(X_band(b, i, :, :)) * ...
                  squeeze(X_band(b, i, :, :))' * squeeze(W_bar(b, :, :));

            v_i = cat(1, v_i, log(diag(mat) / trace(mat)));
        end
        V(i, :) = v_i;
    end

    % Mutual Information
    F = V'; % f_j = F(j, :);

    p_w = zeros(length(y_types), 1);
    for w = 1:length(y_types)
        p_w(w) = mean(y == y_types);
    end

    p_f_bar_w = zeros(size(F), length(y_types));
    for j = 1:size(F, 1)
        for i = 1:size(F, 2)
            for w = 1:length(y_types)
                y_idx = find(y == y_types(w));
                
                p_hat = 0;
                for k_i = 1:length(y_idx)
                    p_hat = p_hat + parzen_window(F(j, i) - F(j, y_idx(k_i)));
                end
                p_hat = p_hat / length(y_idx);
                
                p_f_bar_w(j, i, w) = p_hat;
            end
        end
    end

    I = zeros(size(F, 1), 1);
    for j = size(F, 1)
        conditional_entropy = 0;
        for w = 1:length(y_types)
            for i = 1:size(F, 2)
                denominator = 0;
                for w_i = 1:length(y_types)
                    denominator = denominator + p_f_bar_w(j, i, w_i) * p_w(w_i);
                end
                numerator = p_f_bar_w(j, i, w) * p_w(w);

                prob = numerator / denominator;
                conditional_entropy = conditional_entropy + prob * log2(prob);
            end
        end
        conditional_entropy = -conditional_entropy;

        I(j) = entropy(y) - conditional_entropy;
    end
    
    % Sorting and select k features
    [~, idx_I] = sort(I);
    selected_idx = [];
    for i = 1:k
        
        selected_idx = [selected_idx, ]
    end

    
end
