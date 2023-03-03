function epochedSignal = low_epoching(signal, srate, point, range, varargin)
% EPOCHING Seperate the epochs from the signal
%   Y = EPOCHING(X, point, range) seperates the epochs at each points of
%   signal from range(1) to range(2). X should be (channel x time) format,
%   point should be (trials x 1) or (1 x trials), and range should be (1 x
%   2) or (2 x 1) format.
%
%   Y = EPOCHING(X, point, range, srate) handles the unit of the range as
%   second.
%
%   Y = EPOCHING(..., 'baseline', baselineRange) corrects the baseline of
%   each epochs using the baseline which is the mean from baselineRange(1)
%   to baselineRange(2). If the sampling rate information is in parameter,
%   baseline range's unit is handled as second.
%
%   Y = EPOCHING(..., 'threshold', threshold) validates the epochs that
%   the range of amplitude are under the threshold only.
%
%   % Example 1:
%   %   Epoching the signals
%   nChannels = 32;
%   nPoints = 1000;
%   eegSignal = rand(nChannels, nPoints);
%   points = [100 400 700];
%   range = [-50 200];
%   epochedSignal = epoching(eegSignal, points, range);
%
%   % Example 2:
%   %   Epoching the signals with baseline correction
%   nChannels = 32;
%   nPoints = 1000;
%   eegSignal = rand(nChannels, nPoints);
%   points = [100 400 700];
%   range = [-50 200];
%   baselineRange = [-50 0];
%   epochedSignal = epoching(eegSignal, points, range, 'baseline', baselineRange);
%
%   % Example 3:
%   %   Epoching the signals with thresholding
%   nChannels = 32;
%   nPoints = 1000;
%   eegSignal = rand(nChannels, nPoints);
%   points = [100 400 700];
%   range = [-50 200];
%   epochedSignal = epoching(eegSignal, points, range, 'threshold', 100);

%   Copyright 2022 Minseok Song     Minseok.H.Song@gmail.com

validateRange = @(x) (numel(x) == 2) && (x(1) < x(2));

p = inputParser;
addRequired(p, 'signal', @ismatrix);
addRequired(p, 'srate', @isscalar);
addRequired(p, 'point', @isvector);
addRequired(p, 'range', validateRange);
addParameter(p, 'baseline', [], validateRange);
addParameter(p, 'threshold', Inf, @isscalar);
parse(p, signal, srate, point, range, varargin{:});

srate = p.Results.srate;
baseline = p.Results.baseline;
threshold = p.Results.threshold;

if srate ~= 0
    range = floor(range * srate);
    baseline = floor(baseline * srate);
end

epochedSignal = zeros(length(point), size(signal, 1), range(2) - range(1) + 1);
iEpoch = 1;

for iTrial = 1:length(point)
    iPoint = point(iTrial);
    if iPoint - range(1) < 0
        warning(['The range of the ' num2str(iTrial) 'st epoch is out of zero. This epoch will be exclude.'])
        continue
    elseif iPoint + range(2) > size(signal, 2)
        warning(['The range of the ' num2str(iTrial) 'st epoch is out of signal length. This epoch will be exclude.'])
        continue
    end

    epoch = signal(:, iPoint + range(1) : iPoint + range(2));
    if ~isempty(baseline)
        epoch = epoch - mean(signal(:, iPoint + baseline(1) + 1 : iPoint + baseline(2)), 2);
    end

    if max(epoch) - min(epoch) > threshold
        continue
    end

    epochedSignal(iEpoch, :, :) = epoch;
    iEpoch = iEpoch + 1;
end

if iEpoch ~= length(point)
    epochedSignal(iEpoch:end, :, :) = [];
end

end