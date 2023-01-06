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
        dataLoader
        data
    end

    properties (Dependent)
        nSessions
        nRuns
    end
    
    methods
        function obj = Subject(subjectId, loader)
            % SUBJECT constructor of Subject class
            %   OBJ = Subject(subjectId, loader) initializes the properties
            %   of this object. Loader is custom class which inherits the
            %   DataLoader class. This class initializes the properties
            %   from the loader. SubjectId is needed for loading specific
            %   subject's data.

            if nargin == 0
                return
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
        
            obj.data = obj.dataLoader.load(obj.subjectId);
            obj.isLoaded = true;
        end

        function value = subsref(obj, subscript)
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
            
            isValidate = strcmpi(subscript(1).type, '{}') || strcmpi(subscript(1).type, '.');
            if ~isValidate
                value = builtin('subsref', obj, subscript);
                return
            end
        
            switch subscript(1).type
                case '.'
                    name = subscript(1).subs;
        
                    if ismember(name, properties(Subject))
                        value = obj.(name);
                    elseif ismethod(Subject, name)                
                        func = str2func(name);
                        value = func(obj, subscript(2).subs{:});
                        subscript(2) = [];
                    elseif ismethod(EEG, name)
                        if ~obj.isLoaded
                            disp('Warning: data is not loaded. Data will be loaded automatically...')
                            obj.load();
                        end
        
                        for i = 1:numel(obj.data)
                            value = feval(obj.data(i).eeg.(name), subscript(2).subs{:});
                        end
                        subscript(2) = [];
                    else
                        errID = 'EEGAL:noSuchMethodOrField';
                        errMsg = ['There is no "' name '" method or field in "Subject" class.'];
                        throw(MException(errID, errMsg));
                    end
                case '{}'
                    if strcmp(subscript(1).subs{1}, ':')
                        sessionIdx = 1:numel(obj.sessionTypes);
                    else
                        validateSessions = obj.sessionTypes;
                        if ~iscell(subscript(1).subs{1})
                            subscript(1).subs{1} = {subscript(1).subs{1}};
                        end
                        session = cellfun(@(x) validatestring(string(x), validateSessions), subscript(1).subs{1});
                        sessionIdx = find(ismember(obj.sessionTypes, session));
                    end
                
                    switch numel(subscript(1).subs)
                        case 1  % SUBJECT{session}.property
                            if numel(subscript) < 2 || ~strcmp(subscript(2).type, '.')
                                errID = 'EEGAL:badsubscript';
                                errMsg = 'Invalid subscript usage. Using SUBJECT{session, run} or SUBJECT{session}.property';
                                throw(MException(errID, errMsg));
                            end
                
                            validateProperties = ["runTypes", "nRuns"];
                            validProperty = validatestring(subscript(2).subs, validateProperties);
                            switch validProperty
                                case 'runTypes'
                                    value = obj.runTypes{sessionIdx};
                                case 'nRuns'
                                    value = numel(obj.runTypes{sessionIdx});
                            end
                            subscript(2) = [];
        
                        case 2  % SUBJECT{session, run}
                            if ~obj.isLoaded
                                disp('Warning: data is not loaded. Data will be loaded automatically...')
                                obj.load();
                            end
        
                            selectedSessionIdx = ismember([obj.data.session], obj.sessionTypes(sessionIdx));
                            selectedRunIdx = ismember([obj.data.run], string(subscript(1).subs{2}));
                            selectedIdx = selectedSessionIdx & selectedRunIdx;
                            value = [obj.data(selectedIdx).eeg];
                    end
            end
        
            subscript(1) = [];
        
            if ~isempty(subscript)
                value = subsref(value, subscript);
            end
        end
    end
end

