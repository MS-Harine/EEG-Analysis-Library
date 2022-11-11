classdef Subject < handle
% SUBJECT 이 클래스의 요약 설명 위치
%   자세한 설명 위치
    
    properties (Access = private)
        sessions            = [];
        runs                = [];
        data                = [];
        selectedSessionType = [];
        dataLoader          = nan;
    end

    properties (Dependent)
        sessionType
        nSessions
        runType
        nRuns
    end
    
    methods
        function obj = subject(sessions, runs, loader)
            % SUBJECT 이 클래스의 인스턴스 생성
            %   자세한 설명 위치

            if nargin == 0
                return
            end

            obj.sessions = sessions;
            obj.runs = runs;
            obj.dataLoader = loader;
        end

        function sessionType = get.sessionType(obj)
            % GET.SESSIONTYPE Get session type of subject
            %   S = SUBJECT.sessionType returns the types of sessions in subject.
            
            sessionType = unique(obj.sessions);
        end
        function nSessions = get.nSessions(obj)
            % GET.NSESSIONS Get number of sessions in subject
            %   N = SUBJECT.nSessions returns the number of sessions in subject.
            
            nSessions = numel(obj.sessionType);
        end
        function runType = get.runType(obj)
            % GET.RUNTYPE Get run types of subject or specific session of subject
            %   R = SUBJECT.runType returns the types of runs of all sessions in subject.
            %
            %   R = SUBJECT{session}.runType returns the types of runs of specific
            %   session of subject.
            
            if isempty(obj.selectedSessionType)
                obj.selectedSessionType = obj.sessionType;
            end
            
            runType = cell(numel(obj.selectedSessionType), 1);
            for iSession = 1:numel(obj.selectedSessionType)
                iSessionType = obj.selectedSessionType(iSession);
                runIndex = ismember(obj.sessions, iSessionType);
                runType{iSession} = unique(obj.runs(runIndex));
            end
            
            isConvertableToMat = numel(unique(cellfun(@length, runType))) == 1;
            if isConvertableToMat
                runType = cell2mat(runType);
            end
        end
        function nRuns = get.nRuns(obj)
            % GET.NRUNS Get number of runs of all or specific session in subject  
            %   N = SUBJECT.nRuns returns the number of runs in all sessions in
            %   subject. 
            %
            %   N = SUBJECT{session}.nRuns returns the number of runs in specific
            %   sessions in subject.
            
            nRuns = numel(obj.runType);
        end

        
    end

    methods (Static)
        sample = createtable();
    end
end

