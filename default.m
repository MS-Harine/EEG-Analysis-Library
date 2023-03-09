function default
%DEFAULT Function for add path of this library

    baseDir = fileparts(mfilename('fullpath'));
    
    dataDir = fullfile(baseDir, 'data');
    modelDir = fullfile(baseDir, 'model');
    functionDir = fullfile(baseDir, 'functions');
    
    addpath(baseDir);
    addpath(genpath(dataDir));
    addpath(modelDir);
    addpath(genpath(functionDir));
end