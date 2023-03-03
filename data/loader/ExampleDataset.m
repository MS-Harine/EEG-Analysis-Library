classdef ExampleDataset < DataLoader
% EXAMPLE Example of data loader
%   Example of data loader
    
    properties
        subjects = [1 2 3];
        sessions = ["train", "test"];
        runs = {string(1:4), ["Open", "Close"]};

        srate = 100;
        locFile = 'biosemi_chan32.ced';
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
            subjectIdx = find(ismember(obj.subjects, subjectId));
            if isempty(subjectIdx)
                errorStruct.message = ['There is no subject "' subjectId '"'];
                errorStruct.identifier = 'EEGAL:invalidInput';
                error(errorStruct);
            end

            nChannel = 10;
            nTimes = 20;
            signal = rand(nChannel, obj.subjects(subjectIdx) * obj.srate * nTimes);

            eeg = EEG(signal, obj.srate, ...
                      'triggerIndex', [obj.srate * 1, obj.srate * 10], ...
                      'triggerType', ["Target", "NonTarget"], ...
                      'channelInfo', 'biosemi_chan32.ced');

            data = struct('session', [], 'run', [], 'eeg', []);
            
            idx = 1;
            for i = 1:numel(obj.sessions)
                sess = obj.sessions{i};
                run = obj.runs{i};
                for subrun = run
                    data(idx).session = string(sess);
                    data(idx).run = subrun;
                    data(idx).eeg = eeg;
                    idx = idx + 1;
                end
            end
        end
    end
end

