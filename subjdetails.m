function [prefix, bt] = subjdetails(datdir, subj)

%   This (helper) function is intended to look extract the information for
%   the subject being analysed.

%   ## Version 1.0 

%   Copyright (C) September 2020
%   D. Pedrosa, University Hospital of Gieﬂen and Marburg
%
%   This software may be used, copied, or redistributed as long as it is
%   not sold and this copyright notice is reproduced on each copy made.
%   This routine is provided as is without any express or implied
%   warranties whatsoever.

dattable = read_metadata(fullfile(datdir, 'data'));                           % folder, in which metadata-file is saved

idx_subj = find(ismember(dattable.pseudonym, subj));
prefix = cell2mat(dattable.pseudonym(idx_subj));
%if ~(isempty(dattable.prefix(idx_subj)) || isnan(dattable.prefix(idx_subj)))
%    prefix = cell2mat(dattable.prefix(idx_subj));
%end
bt = {dattable.bt_off(idx_subj), dattable.bt_60(idx_subj), ... 
    dattable.bt_130(idx_subj), dattable.bt_180(idx_subj)};