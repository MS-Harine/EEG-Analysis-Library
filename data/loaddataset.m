function dataset = loaddataset(datasetId)
% LOADDATA Return specific data loader class
%   
%   % Example 1.
%   data = loaddata('ExampleLoader');

    persistent datasetList

    if isempty(datasetList)
        loaderList = dir(fullfile(mfilename("fullpath"), 'loader', '*.m'));
        datasetList = cellfun(@(x) extractBefore(x, '.'), {loaderList.name}, 'UniformOutput', false);
    end

    validateDataset = validatestring(datasetId, datasetList);
    datasetIndex = strcmpi(datasetList, validateDataset);
    datasetName = datasetList(datasetIndex);
    dataset = feval(datasetName(datasetId));

end
