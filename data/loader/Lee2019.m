classdef Lee2019 < DataLoader
% Lee2019 Data loader for Lee 2019 dataset (KNU 3-paradigms)
%   SubjectId is numeric value between 1 to 54
%
%   [1] Lee, Min-Ho, et al. "EEG dataset and OpenBMI toolbox for three BCI
%   paradigms: An investigation into BCI illiteracy." GigaScience 8.5 (2019): giz002.

    properties
        subjects        = 1:54;
        sessions        = [1 2];
        runs            = ["ERP-train", "ERP-test", "MI-train", "MI-test", "SSVEP-train", "SSVEP-test"];

        baseDir = fullfile(pwd, 'data', 'Lee (2019) KNU 3-paradigms');
    end
    
    methods
        function subjectIds = getSubjectIdentifiers(obj)
            subjectIds = obj.subjects;
        end

        function sessionTypes = getSessionTypes(obj)
            sessionTypes = obj.sessions;
        end

        function runTypes = getRunTypes(obj, ~)
            runTypes = obj.runs;
        end

        function data = load(obj, subjectId)
            data = struct('session', [], 'run', [], 'eeg', []);
            dataIdx = 1;

            for session = obj.sessions
                for paradigm = ["ERP", "MI", "SSVEP"]
                    currentData = load(fullfile(obj.baseDir, ['session' num2str(session)], ['s' num2str(subjectId)], ...
                                       sprintf("sess%02d_subj%02d_EEG_%s", session, subjectId, paradigm)));
                    for run = ["train", "test"]
                        var = sprintf("EEG_%s_%s", paradigm, run);
                        data(dataIdx).session = string(session);
                        data(dataIdx).run = sprintf("%s-%s", paradigm, run);
                        data(dataIdx).eeg = EEG(currentData.(var).x', currentData.(var).fs, ...
                                                'triggerIndex', currentData.(var).t, ...
                                                'triggerType', string(currentData.(var).y_class), ...
                                                'channelInfo', loadlocs('standard', string(currentData.(var).chan)));
                        dataIdx = dataIdx + 1;
                    end
                end
            end
        end
    end
end
