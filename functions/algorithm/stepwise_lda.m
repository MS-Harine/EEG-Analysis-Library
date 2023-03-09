function [Mdl, inmodel] = stepwise_lda(data, label, varargin)
% STEPWISE_LDA Training the LDA model with step-wise selected features
%   [Mdl, inmodel] = STEPWISE_LDA(X, y) calculated the step-wise features
%   and training the LDA model with selected features.
%
%   % Example 1:
%   %   Training the LDA model with step-wise selected features.
%   nData = 50;
%   nFeatures = 300;
%   data = rand(nData, nFeatures);
%   label = cat(2, zeros(1, 25), ones(1, 25));
%   [Mdl, inmodel] = stepwise_lda(data, label);
%   
%   % Example 2:
%   %   Test the trained model
%   [Mdl, inmodel] = stepwise_lda(data, label);
%   result = predict(Mdl, testdata(:, inmodel));
%
%   Parameter
%       - data : [N x ...] data for training
%       - label : [N x 1] or [1 x N] label for training
%       - pvalue : threshold of p-value while select the step-wise features
%       - maxCount : max number of selected features

%   Copyright 2022 Minseok Song     Minseok.H.Song@gmail.com

    p = inputParser;
    addRequired(p, 'data', @isnumeric);
    addRequired(p, 'label', @(x) isvector(x) && ismember(1, size(x)));
    addOptional(p, 'pvalue', 0.05, @isscalar);
    addOptional(p, 'maxCount', 60, @isscalar);
    parse(p, data, label, varargin{:});
    
    pvalue = p.Results.pvalue;
    maxCount = p.Results.maxCount;

    data = reshape(data, size(data, 1), []);
    
    [sw_data, ~, inmodel] = stepwise_feature(data, label, 'pvalue', pvalue, 'maxCount', maxCount);
    if ~any(inmodel == 1)
        Mdl = [];
    else
        Mdl = fitcdiscr(sw_data, label);
    end
end

