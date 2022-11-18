classdef (Abstract) Dataloader
% DATALOADER Data loader abtract class for various loaders
%   Abstract dataloader class for implement various loaders.

    properties
        data = table('Size', [0 8], ...
                     'VariableTypes', {   'char', 'char', 'double', 'double',  'double',     'char',   'struct', 'char'}, ...
                     'VariableNames', {'session',  'run', 'signal',  'srate', 'trigIdx', 'trigType', 'chanInfo', 'note'});
    end
    
    properties (Abstract)
        sessionTypes
        runTypes
    end
    
    methods (Abstract)
        getSubjectIdentifiers();
        getSessionInfo();
        getRunInfo();

        getMetadata(subjectId);
        load(subjectId, varargin);
    end
end

