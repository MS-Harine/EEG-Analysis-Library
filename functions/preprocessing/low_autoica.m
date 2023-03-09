function signal = low_autoica(signal, srate, channelInfo, varargin)
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
%   signal = rand(nChannel, srate * time);
%   channelInfo = readlocs('channelInfo.ced');
%   ica_signal = low_autoica(signal, srate, channelInfo);
%
%   % Example 2:
%   %   Remove 'Line Noise' and 'Channel Noise' with 0.5 < x < 0.8
%   %   threshold.
%   signal = rand(nChannel, srate * time);
%   channelInfo = readlocs('channelInfo.ced');
%   ica_signal = low_autoica(signal, srate, channelInfo, ...
%          'removethresh', [0 0; 0 0; 0 0; 0 0; 0.5 0.8; 0.5;0.8 0 0]); 
%
%   Parameter
%       - icaType : 'sobi' as default
%       - removethresh : [7(Type) x 2(Threshold min/max)]
%
%   See also pop_runica, pop_iclabel, pop_icflag, pop_subcomp

%   Copyright 2023 Minseok Song     Minseok.H.Song@gmail.com

    p = inputParser;
    addRequired(p, 'signal', @ismatrix);
    addRequired(p, 'srate', @isscalar);
    addRequired(p, 'channelInfo', @isstruct);
    addParameter(p, 'icatype', 'sobi', @ischar);
    addParameter(p, 'iclabeltype', 'default', @ischar);
    addParameter(p, 'removethresh', [0 0; 0.9 1; 0.9 1; 0 0; 0 0; 0 0; 0 0], @(x) all(size(x) == [7 2]));
    parse(p, signal, srate, channelInfo, varargin{:});
    
    icatype = p.Results.icatype;
    iclabeltype = p.Results.iclabeltype;
    removeThreshold = p.Results.removethresh;
    
    varNames = evalin('base', 'who');
    uniqueNames = matlab.lang.makeUniqueStrings([varNames(:)', {'signal'}]);
    signalName = uniqueNames{end};
    assignin("base", signalName, signal);
    
    EEG = pop_importdata('dataformat', 'array', 'data', signalName, 'srate', srate);
    EEG.chanlocs = channelInfo;
    EEG = pop_runica(EEG, 'icatype', icatype);
    EEG = pop_iclabel(EEG, iclabeltype);
    EEG = pop_icflag(EEG, removeThreshold);
    EEG = pop_subcomp(EEG, find(EEG.reject.gcompreject));
    
    evalin('base', ['clear(''' signalName ''')']);
    
    signal = double(EEG.data);

end