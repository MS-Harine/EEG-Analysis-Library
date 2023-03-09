function [feature, weight, inmodel, stats] = stepwise_feature(data, label, varargin)
% STEPWISE_FEATURE Select the features with step-wise calculation
%   [F, W, inmodel, stats] = STEPWISE_FEATURE(X, y) select the step-wise
%   features.
%
%   % Example 1:
%   %   Get the step-wise selected features
%   nData = 50;
%   nFeatures = 300;
%   data = rand(nData, nFeatures);
%   label = cat(2, zeros(1, 25), ones(1, 25));
%   [feature, weight, inmodel, stats] = stepwise_feature(data, label);
%
%   Parameter
%       - data : [N x ...] data for training
%       - label : [N x 1] or [1 x N] label for training
%       - pvalue : threshold of p-value while select the step-wise features
%       - maxCount : max number of selected features
%   
%   Output Parameter
%       - feature : selected features
%       - weight : weight of features
%       - inmodel : indicies of selected features
%       - stats : detailed informations about calculation

%   Copyright 2022 Minseok Song     Minseok.H.Song@gmail.com

    p = inputParser;
    addRequired(p, 'data', @ismatrix);
    addRequired(p, 'label', @isvector);
    addOptional(p, 'pvalue', 0.05, @isscalar);
    addOptional(p, 'maxCount', 0, @isscalar);
    parse(p, data, label, varargin{:});
    
    pvalue = p.Results.pvalue;
    maxCount = p.Results.maxCount;
    
    [weight, ~, pval, inmodel, stats] = stepwisefit(data, label, 'penter', pvalue, 'Display', 'off');
    if (maxCount ~= 0) && (sum(inmodel) > maxCount)
        [~, index] = sort(pval);
        inmodel = false(size(inmodel));
        inmodel(index(1:maxCount)) = true;
    end
    
    feature = data(:, inmodel);
end

