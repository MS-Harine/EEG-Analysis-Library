function default()
%DEFAULT Function for add path of this library

disp(mfilename('fullpath'));
baseDir = fileparts(mfilename('fullpath'));

dataDir = fullfile(baseDir, 'data');
modelDir = fullfile(baseDir, 'model');
functionDir = fullfile(baseDir, 'functions');

addpath(genpath(dataDir));
addpath(modelDir);
addpath(functionDir);

end

