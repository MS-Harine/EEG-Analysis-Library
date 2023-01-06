function locs = loadlocs(device, channels)
%LOADLOCS Load location informations for specific channels
%   locs = loadlocs('Standard', ["Fz", "Cz"]);
%   locs = loadlocs('Biosemi', ["Fz", "Cz"]);

validateDevices = ["Biosemi", "Standard"];
device = validatestring(device, validateDevices);

switch device
    case "Standard"
        loc_info = readlocs('Standard-10-5-Cap385.ced');
    case "Biosemi"
        loc_info = readlocs('biosemi_chan64.ced');
end

labels = string({loc_info.labels});
idx = ismember(labels, channels);
locs = loc_info(idx);

end

