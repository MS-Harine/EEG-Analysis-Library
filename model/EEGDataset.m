classdef EEGDataset
% EEGDATASET dataset class for eeg data
%   This dataset contains many subjects' eeg data.
    
    properties
        sessions
        runs
        subjectIds
        subjects
    end

    properties (Access = private)
        dataLoader
        sessionTypes
        runTypes
    end

    properties (Dependent)
        nSubjects
    end

    methods
        function obj = EEGDataset(datasetId)
            % DATASET constructor of dataset class
            %   OBJ = EEGDATASET(datasetId) initializes the information of
            %   dataset. The datasetId should be one of filename in loader
            %   directory.
            %
            %   % Example 1:
            %   %   Instanciate the dataset
            %   dataset = EEGDataset('Won2022');

            obj.dataLoader = loaddataset(datasetId);
            obj.subjectIds = dataLoader.getSubjectIdentifiers();
            obj.sessionTypes = dataLoader.getSessionInfo();
            obj.runTypes = dataLoader.getRunInfo();

            obj.sessions = obj.sessionTypes;
            obj.runs = obj.runTypes;

            nSubjects = numel(obj.subjectIds);
            obj.subjects = Subject.empty(1, nSubjects);
            for i = 1:nSubjects
                obj.subjects(i) = Subject(obj.subjectIds(i), obj.dataLoader);
            end
        end

        function nSubjects = get.nSubjects(obj)
            nSubjects = numel(obj.subjectIds);
        end

        function obj = setSessions(obj, sess)
            obj.sessions = validatestring(sess, obj.sessionTypes);
            for i = 1:obj.nSubjects
                obj.subjects(i).setSessions(obj.sessions);
            end
        end

        function obj = setRuns(obj, run)
            obj.runs = validatestring(run, obj.runTypes);
            for i = 1:obj.nSubjects
                obj.subjects(i).setRuns(obj.runs);
            end
        end

        function subject = subsref(obj, subscript)
            % SUBSREF return the n-th subject's data
            %   SUBJ = obj(n) is overrided function for subsref. It returns
            %   n-th subject's data. If the parameter n is vector, it
            %   returns n subjects' data.
            %
            %   % Example
            %   obj = EEGDataset(datasetId);
            %   subject = obj(1);
        
            isValidate = ~strcmpi(subscript(1).type, '.') && ...
                         numel(subscript) == 1 && ...
                         numel(subscript(1).subs) == 1 && ...
                         isscalar(subscript(1).subs{1});
        
            if ~isValidate
                subject = builtin('subsref', obj, subscript);
                return;
            end

            subjectIndex = find(ismember(obj.subjectIds, subscript(1).subs{1}));
            subject = obj.subjects(subjectIndex);
        end
    end
end
