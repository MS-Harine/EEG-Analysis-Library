classdef (Abstract) DataLoader < handle
% DATALOADER Data loader abtract class for various loaders
%   Abstract dataloader class for implement various loaders.

    properties (Access = protected)
        % locationInfo
        %   Set the locationInfo property when you can get the location
        %   information from 'readlocs()' function in EEGLAB.
        locationInfo = []
    end

    methods
        function locs = getLocationInfo(obj)
            % getLocationInfo (struct)
            %   Return the location informations from 'readlocs()' in EEGLAB
            %   
            %   If you cannot get location information before load the data,
            %   return empty array(default) for lazy initialization.
            locs = obj.locationInfo;
        end
    end

    methods (Abstract)
        % getSubjectIdentifiers (string or double array)
        %   Return the list of subject identifiers
        subjectIds = getSubjectIdentifiers(obj);

        % getSessionTypes (cell array, {string or double ...})
        %   Return the list of session types
        sessionTypes = getSessionTypes(obj);

        % getRunTypes (cell array, {double array, double array ...})
        %   Return the list of run types for specific session
        runTypes = getRunTypes(obj, session);

        % load
        %   Load specific subject's data and event.
        %   Data is struct type contains 'session', 'run', and 'eeg'
        %   fields.
        %   In 'eeg' fields, EEG class is needed.
        %
        %   Ex)
        %   'session'   |   'run'   |   'eeg'
        %   ------------|-----------|-----------
        %   'train'     |   1       |   'EEG'
        %   'train'     |   2       |   'EEG'
        %   'test'      |   1       |   'EEG'
        data = load(subjectId);
    end
end

