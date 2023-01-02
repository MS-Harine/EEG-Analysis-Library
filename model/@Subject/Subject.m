classdef Subject < handle
% SUBJECT 이 클래스의 요약 설명 위치
%   자세한 설명 위치

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
            % SUBJECT 이 클래스의 인스턴스 생성
            %   자세한 설명 위치

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
            
            nSessions = numel(obj.sessionType);
        end

        function nRuns = get.nRuns(obj)
            % GET.NRUNS Get number of runs of all or specific session in subject  
            %   N = SUBJECT.nRuns returns the number of runs in all sessions in
            %   subject. 
            %
            %   N = SUBJECT{session}.nRuns returns the number of runs in specific
            %   sessions in subject.
            
            lengths = cellfun(@length, obj.runTypes);
            if range(lengths) == 0
                nRuns = numel(obj.runTypes{1});
            else
                nRuns = lengths;
            end
        end

        value = subsref(obj, subscript);
    end
end

