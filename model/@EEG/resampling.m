function obj = resampling(obj, srate)
% RESAMPLING Resample the signal
%   RESAMPLING() changes the signal's sampling rate.
%
%   % Example 1:
%   %   Resample the signal
%   nChannel = 32;
%   nPoints = 100;
%   eeg = EEG(rand(nChannels, nPoints), 10);
%   resampling(eeg, 5);
%
%   Parameter
%       - srate : Sampling rate to change
%
%   See also resample, downsample

%   Copyright 2023 Minseok Song     Minseok.H.Song@gmail.com

    if srate == obj.srate
        return
    end

    obj.signal = resample(obj.signal, srate, obj.srate, "Dimension", 2);
    obj.srate = srate;
    obj.triggerIndex = round(obj.triggerIndex * (srate / obj.srate));
end
