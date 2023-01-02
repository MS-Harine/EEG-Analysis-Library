classdef (Abstract) DataLoader
% DATALOADER Data loader abtract class for various loaders
%   Abstract dataloader class for implement various loaders.

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

