classdef EEG < handle
% EEG Class for handle the eeg data
%   This class handles one eeg data
    
    properties
        signal          = []
        srate           = 0
        isEpoched       = false
        triggerTypes    = []
        channelInfo     = nan
        epochRange      = []
        baselineRange   = []
    end

    properties (Access = private)
        triggerIndex    = []
        triggerType     = []
        rawData         = nan
    end

    methods
        obj = rereference(obj, varargin);
        obj = filtering(obj, filter, range, varargin);
        obj = autoICA(obj, varargin);
        obj = resampling(obj, srate);
    end
    
    methods
        function obj = EEG(signal, srate, varargin)
            % EEG constructor of eeg class
            %   OBJ = EEG(signal, srate) initializes the properties of this
            %   object. If the signal is matrix, it's form should be
            %   (channel x time). If it is 3 dimensional array, it's form
            %   should be (trial x channel x time) and 'triggerType' should
            %   be passed as parameter. It not, all trials handleed as same
            %   type.
            %
            %   OBJ = EEG(..., 'triggerIndex', index) saves the index of
            %   trigger in object. This array includes time indexes only.
            %   If there is no 'triggerType', all indexes are handled as
            %   same trigger type.
            %
            %   OBJ = EEG(..., 'triggerType', type) saves the type os
            %   trigger in object. This array has same shape with trigger
            %   indexes.
            %
            %   OBJ = EEG(..., 'channelInfo', info) saves the channel
            %   information about eeg. The form follows the 'readlocs'
            %   function in EEGLAB.
            %
            %   % Example 1:
            %   %   Instanciate this class with 2-dimensional signal
            %   nChannels = 32;
            %   srate = 100;
            %   signal = rand(nChannels, 10 * srate); % Generate 10s data
            %   eeg = EEG(signal, srate);
            %
            %   % Example 2:
            %   %   Instanciate this class with 3-dimensional signal
            %   nChannels = 32;
            %   srate = 100;
            %   triggerType = [1 1 0 0 1];
            %   % Generate 2s data with 5 trials
            %   signal = rand(5, nChannels, 2 * srate);
            %   eeg = EEG(signal, srate, 'triggerType', triggerType);
            %
            %   % Example 3:
            %   %   Instanciate this class with 2-dimensional signal and
            %   %   trigger informations
            %   nChannels = 32;
            %   srate = 100;
            %   triggerType = [1 1 0 0 1];
            %   triggerIndex = [100 300 500 700 900];
            %   signal = rand(nChannels, 10 * srate); % Generate 10s data
            %   eeg = EEG(signal, srate, 'triggerType', triggerType, ...
            %   'triggerIndex', triggerIndex);

            if nargin == 0
                return
            end

            p = inputParser;
            addRequired(p, 'signal', @(x) ndims(x) < 4);
            addRequired(p, 'srate', @isscalar);
            addParameter(p, 'triggerIndex', [], @isvector);
            addParameter(p, 'triggerType', [], @isvector);
            addParameter(p, 'channelInfo', []);
            parse(p, signal, srate, varargin{:});
            
            obj.signal = double(signal);
            obj.srate = srate;
            obj.triggerIndex = p.Results.triggerIndex;
            obj.triggerType = p.Results.triggerType;
            obj.channelInfo = p.Results.channelInfo;
            obj.triggerTypes = unique(p.Results.triggerType);
            
            obj.rawData = struct('signal', obj.signal, 'srate', obj.srate, ...
                'channelInfo', obj.channelInfo, 'triggerIndex', obj.triggerIndex);

            if ndims(signal) == 3
                obj.isEpoched = true;
            else
                obj.isEpoched = false;
            end
        end

        function set.channelInfo(obj, value)
            % SET.CHANNELINFO Set the value of channelInfo property
            %   OBJ.CHANNELINFO = VALUE sets the value of channelInfo property. The
            %   VALUE can be filename or array of struct. If it is filename, it use
            %   READLOCS function internally. If there is no READLOCS function, it will
            %   throw error.
            %
            %   See also READLOCS
            
            if isscalar(value)
                obj.channelInfo = readlocs(value);
            else
                obj.channelInfo = value;
            end
        end

        function obj = reset(obj)
            for fname = fieldnames(obj.rawData)
                obj.(fname) = obj.rawData.(fname);
            end
        end

        function obj = deleteData(obj)
            obj.signal = [];
            obj.rawData = nan;
        end

        function n = numArgumentsFromSubscript(obj, ~, ~)
            n = numel(obj);
        end

        function varargout = subsref(objs, s)
            % SUBSREF return the n-th trial of epoched data
            %   T = OBJ(n) is overrided function for subsref. It returns n-th trial of
            %   epoched data. If it is not epoched, it returns n-th data from (channel
            %   x time) data.
            %
            %   T = OBJ(type, n) returns the n-th trial of epoched data with specific
            %   type of trigger. 
            %   
            %   % Example 1:
            %   %   Indexing the trials
            %   eeg = EEG(signal, srate);
            %   trials = eeg(3:5);
            %
            %   % Example 2:
            %   %   Indexing the trials with channel number
            %   eeg = EEG(signal, srate);
            %   trials = eeg(1, 3:5);
            %
            %   % Example 3:
            %   %   Indexing the trials with specific trigger type
            %   eeg = EEG(signal, srate);
            %   eeg.epoching(range, triggerIndex, triggerType);
            %   targets = eeg('target', 3:5);
        
            nout = max(1, nargout);
            varargout = cell(1, nout);

            for objIdx = 1:numel(objs)
                obj = objs(objIdx);

                switch s(1).type
                    case '{}'
                        % obj{xxx}
                        value = builtin('subsref', obj, s);
                    case '.'
                        % obj.xxx
                        if numel(s) == 1
                            % obj.Property
                            if ismethod(obj, s(1).subs)
                                value = @(varargin) obj.(s(1).subs)(varargin{:});
                            elseif isprop(obj, s(1).subs)
                                value = obj.(s(1).subs);
                            else
                                value = builtin('subsref', obj, s);
                            end
                        else
                            % obj.Property(xxx)
                            value = builtin('subsref', obj, s);
                            s(2) = [];
                        end
                    case '()'
                        if numel(s(1).subs) == 1
                            % obj(xxx)
                            sub = s(1).subs{1};
                            if ismember(sub, unique(obj.triggerType))
                                % obj(trigger) return count of trigger
                                value = sum(obj.triggerType == sub);
                            elseif ~isnumeric(sub)
                                errorStruct.message = 'Only integer vector can index the data. Use EEG(integer) or EEG(Type, integer)';
                                errorStruct.identifier = 'EEGAL:invalidSubscript';
                                error(errorStruct);
                            else
                                % obj(indicies)
                                value = obj.signal(sub);
                            end
                        elseif isnumeric(s(1).subs{1})
                            % obj(channel, indicies)
                            channel = s(1).subs{1};
                            sub = s(1).subs{2};
                            value = obj.signal(channel, sub);
                        else
                            % obj(trigger, indicies)
                            type = s(1).subs{1};
                            sub = s(1).subs{2};
            
                            obj.checkSettings();
                            value = obj.epoching(type, sub);
                        end
                end
                varargout{1}{objIdx} = value;
            end

            s(1) = [];

            if ~isempty(s)
                for objIdx = 1:numel(obj)
                    varargout{1}{objIdx} = subsref(varargout{1}{objIdx}, s);
                end
            end

            if numel(varargout{1}) == 1
                varargout{1} = varargout{1}{:};
            end
        end

        function obj = setEpochRange(obj, range)
            obj.epochRange = range;
        end

        function obj = setBaselineRange(obj, range)
            obj.baselineRange = range;
        end
    end

    methods (Access = private)
        function checkSettings(obj)
            if isempty(obj.epochRange)
                errorStruct.message = 'Please set the epoching range with obj.setEpochRange(range).';
                errorStruct.identifier = 'EEGAL:invalidUsageOfMethod';
                error(errorStruct);
            elseif isempty(obj.baselineRange)
                warning('Baseline range is not set.');
            end
        end

        function epoch = epoching(obj, trigger, index)
            triggerIdx = find(ismember(obj.triggerType, trigger));
            triggerIdx = triggerIdx(index);
            triggerIdx = obj.triggerIndex(triggerIdx);

            if isempty(triggerIdx)
                warning('There is no trigger like "%s"', trigger);
            end

            if isempty(obj.baselineRange)
                epoch = low_epoching(obj.signal, obj.srate, triggerIdx, obj.epochRange);
            else
                epoch = low_epoching(obj.signal, obj.srate, triggerIdx, obj.epochRange, 'baseline', obj.baselineRange);
            end
        end
    end
end

