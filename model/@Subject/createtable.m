function sample = createtable(varargin)
% CREATETABLE Create the template of data table
%   S = CREATETABLE() returns a table template for save data. It contains
%   session, run, signal, sampling rate, trigger index, trigger type,
%   channel information, note columns.
%
%   S = CREATETABLE(session, run, signal, srate, triggerIndex, triggerType,
%   channelInfomation, note) returns a table fill with data. The parameter
%   can be ommitted.

isnumericvector = @(x) isnumeric(x) & isvector(x);

p = inputParser;
addOptional(p, 'sess', 0, @isvector);
addOptional(p, 'run', 0, @isvector);
addOptional(p, 'signal', [], @isnumeric);
addOptional(p, 'srate', 0, isnumericvector);
addOptional(p, 'trigIdx', [], isnumericvector);
addOptional(p, 'trigType', [], @isvector);
addOptional(p, 'chanInfo', [], @isvector);
addOptional(p, 'note', '', @isvector);
parse(p, varargin{:});

sess = p.Results.sess;
run = p.Results.run;
signal = p.Results.signal;
srate = p.Results.srate;
trigIdx = p.Results.trigIdx;
trigType = p.Results.trigType;
chanInfo = p.Results.chanInfo;
note = p.Results.note;

fields = {'Session', 'Run', 'Signal', 'SamplingRate', 'TriggerIndex', 'TriggerType', 'ChannelInformation', 'Note'};
if nargin == 0
    data = cell(0, numel(fields));
else
    data = {sess, run, signal, srate, trigIdx, trigType, chanInfo, note};
end

sample = cell2table(data, "VariableNames", fields);

end

