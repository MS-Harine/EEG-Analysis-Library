function epoching(obj, varargin)
% EPOCHING Seperate the epochs from the signal
%   OBJ.EPOCHING(range, triggerIndex, triggerType) seperates the epochs at
%   each points of signal from range(1) to range(2) using triggerIndex.
%   Range's unit is second. If one of triggerIndex and triggerType is
%   empty, it uses saved data from instance.
%
%   OBJ.EPOCHING(..., 'baseline', baselineRange) corrects the baseline of
%   each epochs using the baseline which is the mean from baselineRange(1)
%   to baselineRange(2). Baseline range's unit is handled as second.
%
%   OBJ.EPOCHING(..., 'threshold', threshold) validates the epochs that
%   the range of amplitude are under the threshold only.
%
%   % Example 1:
%   %   Epoching the signals
%   nChannel = 32;
%   nPoints = 100;
%   eeg = EEG(rand(nChannels, nPoints), 10);
%   epochRange = [-0.2 0.3];
%   triggerIndex = [1 3 5];
%   triggerType = [0 1 1];
%   eeg.epoching(epochRange, triggerIndex, triggerType);
%
%   % Example 2:
%   %   Epoching the signals with baseline correction
%   nChannel = 32;
%   nPoints = 100;
%   triggerIndex = [1 3 5];
%   triggerType = [0 1 1];
%   eeg = EEG(rand(nChannels, nPoints), 10, 'triggerIndex', triggerIndex, 'triggerType', triggerType);
%   epochRange = [-0.2 0.3];
%   baselineRange = [-0.2 0];
%   eeg.epoching(epochRange, 'baselineRange', baselineRange);

%   Copyright 2022 Minseok Song     Minseok.H.Song@gmail.com

validateRange = @(x) (numel(x) == 2) && (x(1) < x(2));

p = inputParser;
addRequired(p, 'range', validateRange);
addOptional(p, 'triggerIndex', obj.triggerIndex, @isvector);
addOptional(p, 'triggerType', obj.triggerType, @isvector);
addParameter(p, 'baselineRange', [], validateRange);
addParameter(p, 'threshold', Inf, @isscalar);
parse(p, signal, point, range, varargin{:});

triggerIndex = p.Results.triggerIndex;
triggerType = p.Results.triggerType;
baselineRange = p.Results.baseline;
threshold = p.Results.threshold;

if isempty(triggerIndex)
    errorStruct.message = "There is no trigger index information";
    errorStruct.identifier = 'MATLAB:invalidInput';
    error(errorStruct);
end

if isempty(triggerType)
    triggerType = ones(size(triggerIndex));
end

obj.signal = epoching(obj.signal, triggerIndex, range, obj.srate, ...
                      'baseline', baselineRange, 'threshold', threshold);
obj.isEpoched = true;
obj.epochRange = range;
obj.baselineRange = baselineRange;
obj.triggerIndex = triggerIndex;
obj.triggerType = triggerType;

end















