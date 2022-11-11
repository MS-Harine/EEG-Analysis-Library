classdef EEGDataset
% EEGDATASET dataset class for eeg data
%   This dataset contains many subjects' eeg data.
    
    properties
        datasetIdentifier   = '';
        datasetLoader       = nan;
        subjects            = [];
        isLoaded            = [];
    end

    properties (Dependent)
        nSubjects
    end
    
    methods
        function obj = EEGDataset(datasetId, dataLoader, varargin)
            % DATASET constructor of dataset class
            %   OBJ = EEGDATASET(datasetId) initializes the information of
            %   dataset. The datasetId should be one of filename in loader
            %   directory.
            %
            %   OBJ = EEGDATASET(datasetId, dataLoader, ...) loads the data
            %   and subject information from dataLoader. The dataLoader has
            %   to return list of subjects' identifiers when the function
            %   called without any parameter. When the loader is called,
            %   each subject's identifier will passed as parameter. If any
            %   additional parameter is needed to call the data loader,
            %   pass all parameters after dataLoader.
            %
            %   % Example 1:
            %   %   Instanciate the dataset
            %   dataset = EEGDataset('Won2021');
            %
            %   % Example 2:
            %   %   Instanciate the dataset with specific data loader
            %   dataset = EEGDataset('CustomDataset', @customloader, ...
            %                        param1, param2, ...);
            
            if nargin < 2
                filepath = fileparts(mfilename("fullpath"));
                baseDir = fileparts(filepath);
                controllerDir = fullfile(baseDir, 'data');
    
                currentPath = pwd;
                cd(controllerDir);
                basicLoader = @loaddata;
                cd(currentPath);

                obj.datasetLoader = @(varargin) basicLoader(datasetId, varargin{:});
            else
                obj.datasetLoader = dataLoader;
            end

            obj.subjects = obj.datasetLoader();
            obj.datasetIdentifier = datasetId;

            obj.subjects = Subject.empty(1, numel(obj.subjects));
            for iSubject = 1:numel(obj.subjects)
                subjectId = obj.subjects(iSubject);
                obj.subjects(iSubject) = obj.datasetLoader(subjectId, varargin{:});
            end
            obj.isLoaded = false(size(obj.subjects));
        end

        function nSubjects = get.nSubjects(obj)
            nSubjects = numel(obj.subjects);
        end

        function subject = subsref(obj, subscript)
            % SUBSREF return the n-th subject's data
            %   SUBJ = obj(n) is overrided function for subsref. It returns
            %   n-th subject's data. If the parameter n is vector, it
            %   returns n subjects' data.
            %
            %   % Example
            %   obj = EEGDataset(directory, @function);
            %   subject = obj([1:3]);
        
            isValidate = ~strcmpi(subscript(1).type, '.') && ...
                         numel(subscript) == 1 && ...
                         numel(subscript(1).subs) == 1;
        
            if ~isValidate
                subject = builtin('subsref', obj, subscript);
                return;
            end
        
            if strcmpi(subscript(1).subs{1}, ':')
                subjectIndex = 1:numel(obj.subjects);
            else
                subjectIndex = find(ismember(obj.subjects, subscript(1).subs{1}));
            end

            for iSubject = subjectIndex
                if ~obj.isLoaded(iSubject)
                    obj.subjects(iSubject).load();
                    obj.isLoaded(iSubject) = true;
                end
            end
            subject = obj.subjects(subjectIndex);
        end
    end
end

