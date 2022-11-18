function subjects = Won2022(subjectId, varargin)
% WON2022 Data loader for Won 2022 dataset (GIST Speller & RSVP)
%   SubjectId is numeric value between 1 to 55
%
%   [1] Won, Kyungho, et al. "P300 speller performance predictor based on
%   RSVP multi-feature." Frontiers in Human Neuroscience 13 (2019): 261.

    defaultSessionTypes = {'rest', 'RSVP',   'train', 'test'};
    defaultRunTypes     = { [1 2],      1, [1 2 3 4],  [1 2]};

    p = inputParser;
    addRequired(p, 'subjectId', @(x) isvector(x) && isnumeric(x));
    addParameter(p, 'session', defaultSessionTypes);
    addParameter(p, 'run', 1:4, @isnumeric);
    parse(p, subjectId, varargin{:});

    sessionTypes = cellfun(@(x) validatestring(x, defaultSessionTypes), p.Results.session);
    runTypes = intersect(defaultRunTypes{ismember(defaultSessionTypes, sessionTypes)}, p.Results.run);

    
    baseDir = fullfile(pwd, 'data', 'Won (2022) GIST Speller');
    dataList = dir(fullfile(baseDir, '*.mat'));

    if isempty(subjectId)
        subjects = 1:numel(dataList);
        return
    end

    
    subjects = Subject.empty(1, numel(subjectId));
    dataLoader = @Won2022Loader;
    for i = 1:numel(subjectId)
        iSubjectId = subjectId(i);
        filename = sprintf('s%02d.mat', iSubject);
        
    end

end

function Won2022Loader(subjectId)

end



%     data = cell(numel(subjectId), 1);
%     for i = 1:numel(subjectId)
%         iSubject = subjectId(i);
%         filename = sprintf('s%02d.mat', iSubject);
%         data = load(fullfile(baseDir, filename), varargin{:});
%         
%     end
% 
%     
%     iData = 1;
%     for i = 1:length(dataList)
%         
%         filename = dataList(i).name;
%         subject_num = str2double(regexp(dataList(i).name, '\d*', 'match')');
% 
%         % RSVP
%         % EEG Data
%         current_data = load(fullfile(dataList(i).folder, dataList(i).name));
%         data(iData).data = current_data.RSVP.data;
% 
%         % Trigger
%         data(iData).event = getTrigger(current_data.RSVP.markers_target, ["Target", "NonTarget"], [1, 2]);
%         
%         % Infomations
%         data(iData).srate = current_data.RSVP.srate;
%         data(iData).run = 1;
%         data(iData).session = 'RSVP';
%         data(iData).filename = filename;
%         data(iData).subject = subject_num;
%         data(iData).chanlocs = current_data.RSVP.chanlocs;
% 
%         iData = iData + 1;
% 
%         % BCI Speller
%         % Training
%         for iTrain = 1: length(current_data.train)
%             train_data = current_data.train{iTrain};
%             
%             data(iData).data = train_data.data;
%             data(iData).event = getTrigger(train_data.markers_target, ["Target", "NonTarget"], [1, 2]);
%             data(iData).srate = train_data.srate;
%             data(iData).run = iTrain;
%             data(iData).session = 'Train';
%             data(iData).filename = filename;
%             data(iData).subject = subject_num;
%             data(iData).chanlocs = train_data.chanlocs;
% 
%             iData = iData + 1;
%         end
% 
%         % Testing
%         for iTest = 1: length(current_data.test)
%             test_data = current_data.test{iTest};
%             
%             data(iData).data = test_data.data;
%             data(iData).event = getTrigger(test_data.markers_target, ["Target", "NonTarget"], [1, 2]);
%             data(iData).srate = test_data.srate;
%             data(iData).run = iTest;
%             data(iData).session = 'Test';
%             data(iData).filename = filename;
%             data(iData).subject = subject_num;
%             data(iData).chanlocs = test_data.chanlocs;
% 
%             iData = iData + 1;
%         end
%     end
%     
% 
%     function trigger = getTrigger(event, event_type, event_list)
%         trigger = struct('type', '', 'latency', 0);
%         idx = find(ismember(event, event_list));
% 
%         for iTrigger = 1:length(idx)
%             trigger(iTrigger).latency = idx(iTrigger);
%             trigger(iTrigger).type = event_type(event(idx(iTrigger)) == event_list);
%         end
% 
%         trigger = table2struct(struct2table(trigger));
%     end
% 
% end

