function dataset = getDataLoader(datasetId)
% GETDATALOADER Return specific data loader class
%   
%   % Example 1.
%   data = loaddata('ExampleLoader');

    loaderList = dir(fullfile(fileparts(mfilename("fullpath")), 'loader', '*.m'));
    datasetList = cellfun(@(x) extractBefore(x, '.'), {loaderList.name}, 'UniformOutput', false);

    validateDataset = validatestring(datasetId, datasetList);
    datasetIndex = strcmpi(datasetList, validateDataset);
    datasetName = datasetList{datasetIndex};
    dataset = feval(datasetName);

end
