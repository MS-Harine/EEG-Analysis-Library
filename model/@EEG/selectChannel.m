function obj = selectChannel(obj, channels)
% SELECTCHANNEL Select eeg channels to use
%   SELECTCHANNEL() select the channels and remove other channels.
%
%   % Example 1:
%   %   Resample the signal
%   nChannel = 32;
%   nPoints = 100;
%   locs = locs;
%   eeg = EEG(rand(nChannels, nPoints), 10, 'channelInfo', locs);
%   selectChannel(eeg, {'Cz', 'Fz'});
%
%   Parameter
%       - channels : {cellstr} channel list

%   Copyright 2023 Minseok Song     Minseok.H.Song@gmail.com

    if isempty(obj.channelInfo)
        warning("Channel information is empty!");
        return
    end

    chanIdx = find(ismember({obj.channelInfo.labels}, channels));
    obj.signal = obj.signal(chanIdx, :);
    obj.channelInfo = obj.channelInfo(chanIdx);

end

