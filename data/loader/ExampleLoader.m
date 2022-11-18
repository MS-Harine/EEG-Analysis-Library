function subjects = ExampleLoader(subjectId, varargin)
%EXAMPLELOADER Example of data loader
%   Example template for data loader.
%   This example shows N subjects, 3 sessions, and 2 runs with 20 seconds
%   and 6 target/non-target triggers.

subjects = Subject.empty(1, numel(subjectId));
sessions = [1 2 3];
runs = ["train" "test"];

% If subjectId is empty, return all ids of subjects.
if isempty(subjectId)
    subjects = 1:3;
    return
end

for iSubject = 1:numel(subjectId)
    loader = @(id) loadData(subjectId(iSubject));
    subjects(iSubject) = Subject(sessions, runs, loader);
end

function data = loadData(subjectId)
    % loadedData = load(subjectId);
    nChannels = 32;
    srate = 100;
    trigIdx = [1 4 7 11 14 17];
    trigType = ["Target", "Target", "Target", "Nontarget", "Nontarget", "Nontarget"];
    
    data = createtable();
    for iSession = sessions
        for jRun = runs
            signal = rand(nChannels, srate * 20);
            newData = createtable(iSession, jRun, signal, srate, trigIdx, trigType);
            data = [data; newData];
        end
    end
end

end