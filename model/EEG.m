classdef EEG < handle
% EEG Class for handle the eeg data
%   This class handles one eeg data
    
    properties
        signal          = []
        srate           = 0
        isEpoched       = false
        triggerIndex    = []
        triggerType     = []
        channelInfo     = nan
        epochRange      = []
        baselineRange   = []
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
            
            obj.signal = signal;
            obj.srate = srate;
            obj.triggerIndex = p.Results.triggerIndex;
            obj.triggerType = p.Results.triggerType;
            obj.channelInfo = p.Results.channelInfo;

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

        function value = subsref(obj, subscript)
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
        
            isValidate = strcmpi(subscript(1).type, '()');
        
            if ~isValidate
                value = builtin('subsref', obj, subscript);
                return
            end
        
            if numel(subscript(1).subs) == 1
                % Without trigger type
                sub = subscript(1).subs{1};
                if ismember(sub, unique(obj.triggerType))
                    value = sum(obj.triggerType == sub);
                    return
                elseif ~isnumeric(sub)
                    errorStruct.message = 'Only integer vector can index the data. Use EEG(integer) or EEG(Type, integer)';
                    errorStruct.identifier = 'EEGAL:invalidSubscript';
                    error(errorStruct);
                end
                value = obj.signal(sub);
            elseif isnumeric(subscript(1).subs{1})
                % Without trigger type & input channel number
                channel = subscript(1).subs{1};
                sub = subscript(1).subs{2};
                value = obj.signal(channel, sub);
            else
                % With trigger type
                type = subscript(1).subs{1};
                sub = subscript(1).subs{2};

                value = obj.epoching(type, sub);
            end

            subscript(1) = [];
            if ~isempty(subscript)
                value = subsref(obj, subscript);
            end
        end
    end

    methods (Access = private)
        function epoch = epoching(obj, trigger, index)
            triggerIdx = find(ismember(obj.triggerType, trigger));
            triggerIdx = triggerIdx(index);
            triggerIdx = obj.triggerIndex(triggerIdx);

            if isempty(obj.baselineRange)
                epoch = low_epoching(obj.signal, obj.srate, triggerIdx, obj.epochRange);
            else
                epoch = low_epoching(obj.signal, obj.srate, triggerIdx, obj.epochRange, 'baseline', obj.baselineRange);
            end
        end
    end
end

