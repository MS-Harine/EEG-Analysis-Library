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

            p = inputParser;
            addRequired(p, 'signal', @(x) ndims(x) < 4);
            addRequired(p, 'srate', @isscalar);
            addOptional(p, 'triggerIndex', [], @isvector);
            addOptional(p, 'triggerType', [], @isvector);
            addOptional(p, 'channelInfo', []);
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
        
        epoching(obj, varargin);
        rereference(obj, varargin);
        trials = subsref(obj, subscript);
    end
end

