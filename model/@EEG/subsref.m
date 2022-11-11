function trials = subsref(obj, subscript)
% SUBSREF return the n-th trial of epoched data
%   T = OBJ(n) is overrided function for subsref. It returns n-th trial of
%   epoched data. If it is not epoched, it returns n-th data from (channel
%   x time) data.
%
%   T = OBJ(type, n) returns the n-th trial of epoched data with specific
%   type of trigger. 
%   
%   % Example 1:
%   %   Indexing the trials
%   eeg = EEG(signal, srate);
%   eeg.epoching(range, triggerIndex, triggerType);
%   trials = eeg(3:5);
%
%   % Example 2:
%   %   Indexing the trials with specific trigger type
%   eeg = EEG(signal, srate);
%   eeg.epoching(range, triggerIndex, triggerType);
%   targets = eeg('target', 3:5);

    isValidate = strcmpi(subscript(1).type, '()') ...
                 && numel(subscript) == 1 ...
                 && numel(subscript(1).subs) < 3 ...
                 && obj.isEpoched;

    if ~isValidate
        trials = builtin('subsref', obj, subscript);
        return;
    end

    % Without trigger type
    if numel(subscript(1).subs) == 1
        sub = subscript(1).subs(1);
        trials = obj.signal(sub, :, :);
        return;
    end

    % With trigger type
    type = subscript(1).subs(1);
    sub = subscript(1).subs(2);

    typeIndex = find(ismember(obj.triggerType, type));
    typeIndex = typeIndex(sub);
    trials = obj.signal(typeIndex, :, :);
end