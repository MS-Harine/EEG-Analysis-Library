classdef Won2022 < DataLoader
% Won2022 Data loader for Won 2022 dataset (GIST Speller & RSVP)
%   SubjectId is numeric value between 1 to 55
%
%   [1] Won, Kyungho, et al. "EEG Dataset for RSVP and P300 Speller
%   Brain-Computer Interfaces." Scientific Data 9.1 (2022): 1-11.
%   [2] Won, Kyungho, et al. "P300 speller performance predictor based on
%   RSVP multi-feature." Frontiers in Human Neuroscience 13 (2019): 261.

    properties
        subjects        = 1:55;
        sessions        = ["rest", "RSVP", "train", "test"];
        runs            = {["RSVP-open", "RSVP-close", "P300-open", "P300-close", "End-open", "End-close"], 1, 1:2, 1:4};

        baseDir = fullfile(pwd, 'data', 'Won (2022) GIST Speller');
    end
    
    methods
        function subjectIds = getSubjectIdentifiers(obj)
            subjectIds = obj.subjects;
        end

        function sessionTypes = getSessionTypes(obj)
            sessionTypes = obj.sessions;
        end

        function runTypes = getRunTypes(obj, session)
            if nargin < 2
                runTypes = obj.runs;
                return
            end

            runIdx = find(ismember(obj.sessions, session));
            if isempty(runIdx)
                errorStruct.message = ['There is no session "' session '"'];
                errorStruct.identifier = 'EEGAL:invalidInput';
                error(errorStruct);
            end
            runTypes = obj.runs{runIdx};
        end

        function data = load(obj, subjectId)
            data = struct('session', [], 'run', [], 'eeg', []);
            dataIdx = 1;
            currentData = load(fullfile(obj.baseDir, sprintf("s%02d.mat", subjectId)));
            obj.locationInfo = currentData.test{1}.chanlocs;

            for sessionIdx = 1:numel(obj.sessions)
                session = obj.sessions{sessionIdx};
                for runIdx = 1:numel(obj.runs{sessionIdx})
                    run = obj.runs{sessionIdx}(runIdx);

                    data(dataIdx).session = string(session);
                    data(dataIdx).run = string(run);

                    currentSession = currentData.(session);
                    if ~isa(currentSession, "cell")
                        currentSession = {currentSession};
                    end

                    switch session
                        case "rest"
                            if mod(runIdx, 2) == 1
                                restMod = 'open';
                            else
                                restMod = 'close';
                            end
                            eeg = EEG(currentSession{ceil(runIdx/2)}.(restMod), 512, ...
                                      'channelInfo', currentData.test{1}.chanlocs);
                        otherwise
                            [index, type] = obj.getTrigger(currentSession{run}.markers_target, ["Target", "NonTarget"], [1 2]);
                            eeg = EEG(currentSession{run}.data, currentSession{run}.srate, ...
                                      'triggerIndex', index, 'triggerType', type, ...
                                      'channelInfo', currentSession{run}.chanlocs);
                    end
                    data(dataIdx).eeg = eeg;
                    dataIdx = dataIdx + 1;
                end
            end
        end
    end

    methods (Access = private)
        function [index, type] = getTrigger(~, event, eventType, eventList)
            idx = find(ismember(event, eventList));
            index = zeros(1, numel(idx));
            type = strings(1, numel(idx));

            for triggerIdx = 1:numel(idx)
                index(triggerIdx) = idx(triggerIdx);
                type(triggerIdx) = eventType(event(idx(triggerIdx)) == eventList);
            end
        end
    end
end
