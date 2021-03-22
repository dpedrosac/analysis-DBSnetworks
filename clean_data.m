function clean_data(wdir, subj, experiment)

%   Wrapper function in order to perform all necessary preprocessing steps
%   for EEG data.

%   ## Version 1.0

%   Copyright (C) September 2020
%   D. Pedrosa, Emil Pruchnewski, Alexander Sperlich, Josefine Waldthaler
%   University Hospital of Gießen and Marburg
%
%   This software may be used, copied, or redistributed as long as it is
%   not sold and this copyright notice is reproduced on each copy made.
%   This routine is provided as is without any express or implied
%   warranties whatsoever.

cd(fullfile(wdir, 'data_rsp'))
[~, ROOTDIR] = DBSnetworks_defaults;

%% General settings
conds           = {'off', '60', '130', '180'};
debug           = 0;                                            %#ok<NASGU>

% Define and create necessary output directories (outdir)
outdir_noica = fullfile(wdir, 'data_noica');                                % directory in which data will be saved after removing ICA artefacts
if ~exist(outdir_noica, 'dir'), mkdir(outdir_noica); end                    % create directory, if not present already
outdir_clean = fullfile(wdir, 'data_clean');                                % directory in which data will be saved
if ~exist(outdir_clean, 'dir'), mkdir(outdir_clean); end                    % create directory, if not present already


% Start extracting and resampling data
for s = 1:numel(subj)
    fprintf('\n\tprocessing subj: %s\n', num2str(subj{s}))
    file_prefix = subjdetails(ROOTDIR, subj{s});
    
    for c = 1:numel(conds)
        fprintf('\t\t ... condition: %s', num2str(upper(conds{c})))
        
        %% ICA for blink and additional DBS artefacts
        filename_noica = fullfile(outdir_noica, ...
            strcat('data_noica_', file_prefix, '_', conds{c}, ...
            sprintf('_%s', experiment), '.mat'));                             % removes the artefacts detected in the ICA
        if ~exist(filename_noica, 'file')
            filename_rsp = strcat('data_rsp_', file_prefix, '_', ...
                conds{c}, sprintf('_%s', experiment), '.mat');                  % filename under which data will be saved in the (outdir) directory
            filename_rsp = fullfile(wdir, 'data_rsp', filename_rsp);
            ICAremove_blink_artefacts(subj{s}, conds{c}, filename_rsp, ...
                filename_noica)
        else
            fprintf('\n\t ICA already finished for subj: %s in the %s (Hz) condition!\n', subj{s}, conds{c});
        end
        
        %% Remove channels with artefacts from data after visual inspection
        % filename_clean = % removes "bad channels" and performs spline
        % interpolation
        
    end
end