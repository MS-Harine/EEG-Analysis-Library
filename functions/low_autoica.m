function signal = low_autoica(signal, srate, channelInfo, varargin)
%ICA 이 함수의 요약 설명 위치
%   자세한 설명 위치

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

signal = EEG.data;

end