classdef EEGDataset < handle
% EEGDATASET dataset class for eeg data
%   This dataset contains many subjects' eeg data.
    
    properties
        subjectIds  = [];
    end

    properties (Access = private)
        subjects
        dataLoader
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
            %   dataset = EEGDataset('ExampleLoader');

            if nargin == 0
                return
            end

            obj.dataLoader = getDataLoader(datasetId);
            obj.subjectIds = obj.dataLoader.getSubjectIdentifiers();
            nSubjects = numel(obj.subjectIds);
            
            obj.subjects = Subject.empty(0, nSubjects);
            for i = 1:nSubjects
                obj.subjects(i) = Subject(obj.subjectIds(i), obj.dataLoader);
            end
        end

        function nSubjects = get.nSubjects(obj)
            nSubjects = numel(obj.subjectIds);
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

            isValidate = strcmpi(subscript(1).type, '{}');
            if ~isValidate
                subject = builtin('subsref', obj, subscript);
                return
            end

            if strcmp(subscript(1).subs{1}, ':')
                subjectIndex = 1:numel(obj.subjectIds);
            else
                subjectIndex = find(ismember(obj.subjectIds, subscript(1).subs{1}));
            end
            subject = obj.subjects(subjectIndex);

            if numel(subscript) > 1
                subject = subsref(subject, subscript(2:end));
            end
        end
    end
end
