
%%  Control file for analysis DBSnetworks data. This file controls
%   for all the different steps in order to get the preprocessing and
%   the analysis

wdir = DBSnetworks_default;

%% General settings
% TODO: Load patient data from xls-file as patdat after selection by
% uitable GUI

subj = 'all'; % if strcmp(subj, 'all'); # get all pseudonyms from files

for adap = 1:1
    switch adap
        case (1)
            read_data_brainvision(wdir, patdat, subj)
        case (2)
            extract_hdr_brainvision(wdir, patdat, subj)
            
    end
    
end