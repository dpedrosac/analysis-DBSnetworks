function tbl = output_excel(event, hdr)

%   This function extracts different information from the evenzt and header 
%   files in order to make clear which stimulus corresponds to which task 
%   in the WCST

%   Copyright (C) January 2018
%   D. Pedrosa, University Hospital of Gieﬂen and Marburg 
%
%   This software may be used, copied, or redistributed as long as it is
%   not sold and this copyright notice is reproduced on each copy made.
%   This routine is provided as is without any express or implied
%   warranties whatsoever.


%%
smp = [event.sample];   % samples
typ = {event.type};     % type of stimulus
val = {event.value};    % value of the stimulus
ltc = (smp)/hdr.Fs;

tbl = table(smp.', reshape(typ, numel(typ), 1), ltc.', ...
    [diff(ltc).'; nan], reshape(val, numel(val), 1),...
    'VariableNames', {'sample_no', 'type', 'latency', 'delta_lat', 'value'});