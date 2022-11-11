function data = loaddata(dataset, subjects, varargin)
% LOADDATA Load data from specific dataset with subject identifier
%   Load the data using loaders. It returns the subjects' data as Subject
%   object form. Loaders located in loader directory.
%
%   % Example 1.
%   data = loaddata('ExampleLoader', 1:10);

    persistent datasetList

    if isempty(datasetList)
        loaderList = dir(fullfile(mfilename("fullpath"), 'loader', '*.m'));
        datasetList = cellfun(@(x) extractBefore(x, '.'), {loaderList.name}, 'UniformOutput', false);
    end

    validateDataset = validatestring(dataset, datasetList);
    datasetIndex = strcmpi(datasetList, validateDataset);
    data = feval(datasetList(datasetIndex), subjects, varargin{:});

end
