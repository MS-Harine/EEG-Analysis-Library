function obj = filtering(obj, filter, range, varargin)
% FILTERING Filtering the signal
%   FILTERING() calculate with specific filter on frequency domain. It
%   depends on 'filter' and 'range' parameter.
%
%   It also depends on `FIELDTRIP` framework.
%
%   % Example 1:
%   %   Bandpass filtering for EEG signal.
%   nChannel = 32;
%   nPoints = 100;
%   eeg = EEG(rand(nChannels, nPoints), 10);
%   filtering(eeg, 'bandpass', [1 30]);
%
%   % Example 2:
%   %   High/Low filtering for EEG signal.
%   nChannel = 32;
%   nPoints = 100;
%   eeg = EEG(rand(nChannels, nPoints), 10);
%   filtering(eeg, 'highpass', 10);
%
%   Parameter
%       - filter : 'bandpass', 'highpass', 'lowpass', 'bandstop'
%       - range : [low, high] for bandpass or bandstop,
%                 [low] or [high] for highpass or lowpass
%
%   See also FT_PREPROC_BANDPASSFILTER, FT_PREPROC_HIGHPASSFILTER,
%   FT_PREPROC_LOWPASSFILTER, FT_PREPROC_BANDSTOPFILTER

%   Copyright 2023 Minseok Song     Minseok.H.Song@gmail.com

    FILTERS = ["bandpass", "bandstop", "highpass", "lowpass"];

    validateClass = @(x) isa(x, 'EEG');

    p = inputParser;
    addRequired(p, 'obj', validateClass);
    parse(p, obj);

    filter = validatestring(filter, FILTERS);
    func = str2func(sprintf("ft_preproc_%sfilter", filter));
    obj.signal = func(obj.signal, obj.srate, range);

end

