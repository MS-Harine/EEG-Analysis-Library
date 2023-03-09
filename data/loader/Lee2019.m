classdef Lee2019 < DataLoader
% Lee2019 Data loader for Lee 2019 dataset (KNU 3-paradigms)
%   SubjectId is numeric value between 1 to 54
%   Run 1 and run 2 are recorded in different days.
%
%   [1] Lee, Min-Ho, et al. "EEG dataset and OpenBMI toolbox for three BCI
%   paradigms: An investigation into BCI illiteracy." GigaScience 8.5 (2019): giz002.

    properties
        subjects    = 1:54;
        sessions    = ["ERP-train", "ERP-test", "MI-train", "MI-test", "SSVEP-train", "SSVEP-test"];
        runs        = [1 2];
        srate       = 1000;

        baseDir     = fullfile(pwd, 'data', 'Lee (2019) KNU 3-paradigms');
        lightDir    = fullfile(pwd, 'data_light', 'Lee (2019)');
    end
    
    methods
        function subjectIds = getSubjectIdentifiers(obj)
            subjectIds = obj.subjects;
        end

        function sessionTypes = getSessionTypes(obj)
            sessionTypes = obj.sessions;
        end

        function runTypes = getRunTypes(obj, ~)
            runTypes = repmat({obj.runs}, 1, numel(obj.sessions));
        end

        function samplingRate = getSamplingRate(obj)
            samplingRate = obj.srate;
        end

        function data = load(obj, subjectId, varargin)
            dataParadigms = ["ERP", "MI", "SSVEP"];

            p = inputParser;
            addParameter(p, 'paradigm', {'ERP', 'MI', 'SSVEP'}, @iscellstr);
            addParameter(p, 'light', 'on', @(x) strcmpi('on', x) || strcmpi('off', x));
            parse(p, varargin{:});
            paradigms = cellfun(@(x) validatestring(string(x), dataParadigms), p.Results.paradigm);
            isLight = strcmp(p.Results.light, 'on');

            data = struct('session', [], 'run', [], 'eeg', []);
            dataIdx = 1;
            locs = [];

            if isLight
                for paradigm = paradigms
                    currentData = load(fullfile(obj.lightDir, sprintf("subj%02d_%s.mat", subjectId, paradigm)));
                    for run = ["train", "test"]
                        for day = obj.runs
                            if isempty(locs)
                                locs = loadlocs('standard', string(currentData.chanlocs));
                                obj.locationInfo = locs;
                            end

                            data(dataIdx).session = sprintf("%s-%s", paradigm, run);
                            data(dataIdx).run = string(day);
                            
                            eegData = eval(sprintf("currentData.%sDataS%d", run, day));
                            target = eval(sprintf("currentData.%sTargetS%d", run, day));
                            nontarget = eval(sprintf("currentData.%sNontargetS%d", run, day));
                            eegTriggerIndex = [target, nontarget];
                            eegTriggerType = [repmat("target", 1, numel(target)), ...
                                              repmat("nontarget", 1, numel(nontarget))];
                            data(dataIdx).eeg = EEG(eegData, currentData.srate, ...
                                                    'triggerIndex', eegTriggerIndex, ...
                                                    'triggerType', eegTriggerType, ...
                                                    'channelInfo', locs);
                            dataIdx = dataIdx + 1;
                        end
                    end
                end
            else
                for day = obj.runs
                    for paradigm = paradigms
                        currentData = load(fullfile(obj.baseDir, ['session' num2str(day)], ['s' num2str(subjectId)], ...
                                           sprintf("sess%02d_subj%02d_EEG_%s", day, subjectId, paradigm)));
    
                        for run = ["train", "test"]
                            var = sprintf("EEG_%s_%s", paradigm, run);
                            if isempty(locs)
                                locs = loadlocs('standard', string(currentData.(var).chan));
                                obj.locationInfo = locs;
                            end
    
                            data(dataIdx).session = sprintf("%s-%s", paradigm, run);
                            data(dataIdx).run = string(day);
                            data(dataIdx).eeg = EEG(currentData.(var).x', currentData.(var).fs, ...
                                                    'triggerIndex', currentData.(var).t, ...
                                                    'triggerType', string(currentData.(var).y_class), ...
                                                    'channelInfo', locs);
                            dataIdx = dataIdx + 1;
                        end
                    end
                end
            end
        end
    end
end
