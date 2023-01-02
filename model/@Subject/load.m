function obj = load(obj)
%LOAD Load the data
%   Loading the actual data. It may take some times.

    obj.data = obj.dataLoader.load(obj.subjectId);
    obj.isLoaded = true;
    
end

