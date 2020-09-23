function sorted_data = sorted_data(data, rename_iz)

%   This (helper) function is intended to sort channels according to name
%   and to rename Iz channel, as this one had a wrong name in the BrainLab
%   montage; the input is the standard structure created by the fieldtrip
%   toolbox w/ only one trial

%   ## Version 1.0 

%   Copyright (C) March 2019
%   D. Pedrosa, University Hospital of Gieﬂen and Marburg
%
%   This software may be used, copied, or redistributed as long as it is
%   not sold and this copyright notice is reproduced on each copy made.
%   This routine is provided as is without any express or implied
%   warranties whatsoever.

if rename_iz == 1
    sorted_data.label{strcmp(data.label, 'IZ')} = 'Iz';
else
    sorted_data = data;
end

[sorted_data.label,I] = sort(sorted_data.label);
sorted_data.trial{1,1} = data.trial{1,1}(I,:);

end