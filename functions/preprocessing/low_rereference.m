function referencedSignal = low_rereference(signal,varargin)
% REREFERENCE Re-referencing the signal
%   Y = REREFERENCE(X) changes the reference of signal using specific
%   method. The input parameter X should be (channel x time) format. It
%   uses common average reference method as default.
%   
%   Y = REREFERENCE(X, METHOD, channelInfo) returns the rereferenced 
%   signal using specific channel informations based upon the value of 
%   METHOD:
%
%       'CAR' - Using common average reference method to compute the
%       reference.
%
%       'Laplacian' - Not implemented. Using channel information.
%
%       'Manual' - Using the average of specific channels as reference
%       signal. Channel information should be given as array.
%
%   % Example 1:
%   %   Rereference the signal using common average reference method.
%   nChannel = 32;
%   nPoints = 100;
%   eegSignal = rand(nChannels, nPoints);
%   rereferencedSignal = rereference(eegSignal, 'car');
%
%   % Example 2:
%   %   Rereference the signal using specific channel information.
%   nChannel = 32;
%   nPoints = 100;
%   eegSignal = rand(nChannel, nPoints);
%   rereferencedSignal = rereference(eegSignal, 'manual', [2 10]);

%   Copyright 2022 Minseok Song     Minseok.H.Song@gmail.com

    defaultMethod = 'car';
    expectedMethods = {'CAR', 'Laplacian', 'Manual'};
    
    p = inputParser;
    addRequired(p, 'signal', @ismatrix);
    addOptional(p, 'method', defaultMethod, @(x) any(validatestring(x, expectedMethods)));
    addOptional(p, 'channelInfo', []);
    parse(p, signal, varargin{:});
    
    method = p.Results.method;
    channelInfo = p.Results.method;
    
    switch method
        case 'CAR'
            reference = mean(signal, 1);
        case 'Laplacian'
            throw('Method is not implemented')
        case 'Manual'
            reference = mean(signal(channelInfo, :), 1);
    end
    
    referencedSignal = signal - reference;

end

