function value = subsref(obj, subscript)
%SUBSREF Overwritted function for subsref
%   Value = SUBJECT.Function(params) apply the function to all EEG signals.
%   It works as Function(signal, params) for all trials. These functions
%   should be one of the method of EEG class.
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
        return;
    end

    switch subscript(1).type
        case '.'
            % TODO
        case '{}'
            if strcmp(subscript(1).subs{1}, ':')
                sessionIdx = 1:numel(obj.sessionTypes);
            else
                validateSessions = obj.sessionTypes;
                session = cellfun(@(x) validatestring(x, validateSessions), subscript(1).subs{1});
                sessionIdx = find(ismember(obj.sessionTypes, session));
            end
        
            switch numel(subscript(1).subs)
                case 1  % SUBJECT{session}.property
                    if numel(subscript) < 2 || ~strcmp(subscript(2).type, '.')
                        errID = 'EEGAL:badsubscript';
                        errMsg = 'Invalid subscript usage. Using SUBJECT{session, run} or SUBJECT{session}.property';
                        throw(MException(errID, errMsg));
                    end
        
                    validateProperties = ['runTypes', 'nRuns'];
                    validProperty = validatestring(subscript(2).subs{1}, validateProperties);
                    switch validProperty
                        case 'runTypes'
                            value = obj.runTypes{sessionIdx};
                        case 'nRuns'
                            value = numel(obj.runTypes{sessionIdx});
                    end
                case 2  % SUBJECT{session, run}
                    if ~obj.isLoaded
                        disp('Warning: data is not loaded. Data will be loaded automatically...')
                        obj.load();
                    end

                    selectedSessionIdx = ismember([obj.data.session], obj.sessionTypes(sessionIdx));
                    selectedRunIdx = ismember([obj.data.run], subscript(1).subs{2});
                    selectedIdx = selectedSessionIdx & selectedRunIdx;
                    value = obj.data(selectedIdx).eeg;

                    if numel(subscript) > 2
                        value = subsref(value, subscript(2:end));
                    end
            end
    end
end
