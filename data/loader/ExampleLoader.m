classdef ExampleLoader < DataLoader
% EXAMPLELOADER Example of data loader
%   Example of data loader
    
    properties
        subjects = [1 2 3];
        % sessions = {["train", "test"], ["train", "test"], ["train", "test"]};
        sessions = ["train", "test"];
        % runs = {{[1 2 3 4], [1 2]}, {[1 2 3 4], [1 2]}, {[1 2 3 4], [1 2]}};
        runs = {[1 2 3 4], [1 2]};

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
                return;
            end
            
            runIdx = find(ismember(obj.sessions, session));
            if isempty(runIdx)
                errorStruct.message = ['There is no session "' session '"'];
                errorStruct.identifier = 'MATLAB:invalidInput';
                error(errorStruct);
            end
            runTypes = obj.runs{runIdx};
        end

        function data = load(obj, subjectId)
            subjectIdx = find(ismember(obj.subjects, subjectId));
            if isempty(subjectIdx)
                errorStruct.message = ['There is no subject "' subjectId '"'];
                errorStruct.identifier = 'MATLAB:invalidInput';
                error(errorStruct);
            end

            nChannel = 10;
            nTimes = 20;
            signal = rand(nChannel, obj.subjects(subjectIdx) * obj.srate * nTimes);

            data = EEG(signal, obj.srate, ...
                       'triggerIndex', [obj.srate * 1, obj.srate * 10], ...
                       'triggerType', ["Target", "NonTarget"], ...
                       'channelInfo', 'biosemi_chan32.ced');
        end
    end
end

