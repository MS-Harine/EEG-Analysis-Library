function obj = autoICA(obj, varargin)
% AUTOICA Automatic ICA(Independent Componenet Analysis)
%   AUTOICA() processes the automatic ICA. It labels the ICs(Independent
%   componenets) as one of {'Brain', 'Eye', 'Muscle', 'Heart', 'Line
%   Noise', 'Channel Noise', 'Other'}, and remove them with threshold.
%   Default remove ICs are {'Eye', 'Muscle'} and threshold is 0.9.
%   It requires channel information.
%   It also depends on `EEGLAB` framework.
%
%   % Example 1:
%   %   Using autoICA as default.
%   data = ExampleDataset();
%   s1 = data{1};
%   s1.autoICA();
%
%   % Example 2:
%   %   Remove 'Heart' with default threshold.
%   data = ExampleDataset();
%   s1 = data{1};
%   s1.autoICA('removeIC', {'Heart'});
%
%   % Example 3:
%   %   Remove 'Line Noise' and 'Channel Noise' with custom threshold.
%   data = ExampleDataset();
%   s1 = data{1};
%   s1.autoICA('removeIC', {'Line Noise', 'Channel Noise'}, 'threshold', 0.8);
%   or
%   s1.autoICA('removeIC', {'Line Noise', 'Channel Noise'}, 'threshold', [0.7, 0.6]);
%
%   Parameter
%       - icaType : 'sobi' as default
%       - removeIC : { ICs } to remove
%       - threshold : 0.0 < scalar < 1.0
%
%   See also pop_runica, pop_iclabel, pop_icflag, pop_subcomp

%   Copyright 2023 Minseok Song     Minseok.H.Song@gmail.com

    ICTypes = {'Brain', 'Muscle', 'Eye', 'Heart', 'Line Noise', 'Channel Noise', 'Other'}; 
    validateICTypes = @(x) iscellstr(cellfun(@(y) validatestring(y, ICTypes), x));
    validateThreshold = @(x) all(x > 0 & x < 1);

    p = inputParser;
    addRequired(p, 'obj');
    addParameter(p, 'icaType', 'sobi');
    addParameter(p, 'removeIC', {'Eye', 'Muscle'}, validateICTypes);
    addParameter(p, 'threshold', 0.9, validateThreshold);
    parse(p, obj, varargin{:});
    
    icaType = p.Results.icaType;
    removeIC = p.Results.removeIC;
    threshold = p.Results.threshold;

    if ~isscalar(threshold)
        assert(length(threshold) == length(removeIC), ...
            'Length of "removeIC" and "threshold" should be same or length of threshold" should be 1.');
    end

    icIdx = ismember(ICTypes, removeIC);
    thresholdParam = zeros(7, 2);
    thresholdParam(icIdx, 1) = threshold;
    thresholdParam(icIdx, 2) = 1;

    obj.signal = low_autoica(obj.signal, obj.srate, obj.channelInfo, ...
        'icatype', icaType, 'removethresh', thresholdParam);

end

