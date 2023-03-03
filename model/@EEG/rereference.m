function obj = rereference(obj, varargin)
% REREFERENCE Re-referencing the signal
%   REREFERENCE() changes the reference of signal using specific
%   method. It uses common average reference method as default.
%   
%   REREFERENCE(METHOD, channelInfo) returns the rereferenced 
%   signal using specific channel informations based upon the value of 
%   METHOD. (see rereference.m)
%
%   % Example 1:
%   %   Rereference the signal using common average reference method.
%   nChannel = 32;
%   nPoints = 100;
%   eeg = EEG(rand(nChannels, nPoints), 10);
%   rereference(eeg);
%
%   % Example 2:
%   %   Rereference the signal using specific channel information.
%   nChannel = 32;
%   nPoints = 100;
%   eeg = EEG(rand(nChannels, nPoints), 10);
%   rereference(eeg, 'manual', {'T7', 'T8'});
%
%   See also LOW_REREFERENCE

%   Copyright 2022 Minseok Song     Minseok.H.Song@gmail.com

    p = inputParser;
    addRequired(p, 'obj');
    addOptional(p, 'method', 'CAR', @isscalar);
    addOptional(p, 'channelInfo', []);
    parse(p, obj, varargin{:});
    
    method = p.Results.method;
    channelInfo = string(p.Results.channelInfo);
    
    if ~(isempty(channelInfo) || isnumeric(channelInfo))
        channelIndex = cellfun(@(x) strcmpi({obj.channelInfo.labels}, channelInfo), 'UniformOutput', false);
        channelIndex = any(cat(1, channelIndex{:}));
    else
        channelIndex = channelInfo;
    end
    
    obj.signal = low_rereference(obj.signal, method, channelIndex);
end

