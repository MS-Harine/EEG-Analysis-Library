classdef Subject < handle
% SUBJECT Class for handle a subject's EEG data
%   This class handles one subject data

    properties
        subjectId
        sessionTypes
        runTypes
        isLoaded = false;
    end
    
    properties (Access = private)
        dataset
        dataLoader
        data
    end

    properties (Dependent)
        nSessions
        nRuns
    end
    
    methods
        function obj = Subject(subjectId, loader, dataset)
            % SUBJECT constructor of Subject class
            %   OBJ = Subject(subjectId, loader) initializes the properties
            %   of this object. Loader is custom class which inherits the
            %   DataLoader class. This class initializes the properties
            %   from the loader. SubjectId is needed for loading specific
            %   subject's data.

            if nargin == 0
                return
            end

            if nargin == 3
                obj.dataset = dataset;
            end

            obj.subjectId = subjectId;
            obj.dataLoader = loader;
            obj.sessionTypes = string(obj.dataLoader.getSessionTypes());
            obj.runTypes = obj.dataLoader.getRunTypes();
        end

        function nSessions = get.nSessions(obj)
            % GET.NSESSIONS Get number of sessions in subject
            %   N = SUBJECT.nSessions returns the number of sessions in subject.
            
            nSessions = numel(obj.sessionTypes);
        end

        function nRuns = get.nRuns(obj)
            % GET.NRUNS Get number of runs of all or specific session in subject  
            %   N = SUBJECT.nRuns returns the number of runs in all sessions in
            %   subject. 
            %
            %   N = SUBJECT{session}.nRuns returns the number of runs in specific
            %   sessions in subject.
            
            if ~iscell(obj.runTypes)
                nRuns = numel(obj.runTypes);
            else
                lengths = cellfun(@length, obj.runTypes);
                if range(lengths) == 0
                    nRuns = numel(obj.runTypes{1});
                else
                    nRuns = lengths;
                end
            end
        end

        function obj = load(obj)
            %LOAD Load the data
            %   Loading the actual data. It may take some times.
        
            if ~obj.isLoaded
                obj.data = obj.dataLoader.load(obj.subjectId);
                obj.isLoaded = true;
            end

            if ~isempty(obj.dataset) && isempty(obj.dataset.locationInfo)
                obj.dataset.locationInfo = obj.dataset.dataLoader.getLocationInfo();
            end
        end

        function n = numArgumentsFromSubscript(obj, ~, ~)
            n = numel(obj);
        end

        function varargout = subsref(obj, s)
            %SUBSREF Overwritted function for subsref
            %   Value = SUBJECT.Function(params) apply the function to all EEG signals.
            %   These functions should be one of the method of EEG class. It returns
            %   the last computation result.
            %
            %   Value = SUBJECT{session, run} returns the EEG data for specific session
            %   and run.
            %
            %   Value = SUBJECT{session}.runTypes returns the list of run types for
            %   specific session
            %   
            %   Value = SUBJECT{session}.nRuns returns the number of runs for specific
            %   session

            nout = max(1, nargout);
            varargout = cell(1, nout);

            switch s(1).type
                case '()'
                    value = builtin('subsref', obj, s);
                case '.' 
                    % obj.xxx
                    name = s(1).subs;
        
                    if ismember(name, properties(Subject))
                        % obj.PropertyName
                        value = obj.(name);
                    elseif ismethod(Subject, name)
                        % obj.Method(xx)
                        func = str2func(name);
                        value = func(obj, s(2).subs{:});
                        s(2) = [];
                    elseif ismethod(EEG, name)
                        % obj.Method(xx)
                        if ~obj.isLoaded
                            disp('Warning: data is not loaded. Data will be loaded automatically...')
                            obj.load();
                        end
        
                        for i = 1:numel(obj.data)
                            value = feval(obj.data(i).eeg.(name), s(2).subs{:});
                        end
                        s(2) = [];
                    else
                        errID = 'EEGAL:noSuchMethodOrField';
                        errMsg = ['There is no "' name '" method or field in "Subject" class.'];
                        throw(MException(errID, errMsg));
                    end
                case '{}'
                    % obj{xxx}
                    if strcmp(s(1).subs{1}, ':')
                        sessionIdx = 1:numel(obj.sessionTypes);
                    else
                        validateSessions = obj.sessionTypes;
                        if ~iscell(s(1).subs{1})
                            s(1).subs{1} = {s(1).subs{1}};
                        end
                        session = cellfun(@(x) validatestring(string(x), validateSessions), s(1).subs{1});
                        sessionIdx = find(ismember(obj.sessionTypes, session));
                    end
                
                    switch numel(s(1).subs)
                        case 1  % SUBJECT{session}.property
                            if numel(s) < 2 || ~strcmp(s(2).type, '.')
                                errID = 'EEGAL:badsubscript';
                                errMsg = 'Invalid subscript usage. Using SUBJECT{session, run} or SUBJECT{session}.property. You can use "runTypes" or "nRuns" as property.';
                                throw(MException(errID, errMsg));
                            end
                
                            validateProperties = ["runTypes", "nRuns"];
                            validProperty = validatestring(s(2).subs, validateProperties);
                            switch validProperty
                                case 'runTypes'
                                    value = obj.runTypes{sessionIdx};
                                case 'nRuns'
                                    value = numel(obj.runTypes{sessionIdx});
                            end
                            s(2) = [];
        
                        case 2  % SUBJECT{session, run}
                            if ~obj.isLoaded
                                disp('Warning: data is not loaded. Data will be loaded automatically...')
                                obj.load();
                            end

                            if strcmp(s(1).subs{2}, ':')
                                s(1).subs{2} = {obj.data.run};
                            end
        
                            selectedSessionIdx = ismember([obj.data.session], obj.sessionTypes(sessionIdx));
                            selectedRunIdx = ismember([obj.data.run], string(s(1).subs{2}));
                            selectedIdx = selectedSessionIdx & selectedRunIdx;
                            value = [obj.data(selectedIdx).eeg];
                    end
                otherwise
                    error('Not a valid indexing expression');
            end
            s(1) = [];
            
            if ~isempty(s)
                value = subsref(value, s);
            end
            
            varargout{1} = value;
        end
    end
end

