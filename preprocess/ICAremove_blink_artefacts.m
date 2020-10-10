function ICAremove_blink_artefacts(subj, cond, filename_rsp, filename_noica)

%   This function is intended to remove the blink artefacts via an ICA
%   approach; The inputs are two filenames (pre and post-processing) the
%   subject pseudonym and the condition [off, 60, 130, 180] to be processed

%   ## Version 1.0

%   Copyright (C) September 2020
%   D. Pedrosa, Emil Pruchnewski, Alexander Sperlich, Josefine Waldthaler
%   University Hospital of Gießen and Marburg
%
%   This software may be used, copied, or redistributed as long as it is
%   not sold and this copyright notice is reproduced on each copy made.
%   This routine is provided as is without any express or implied
%   warranties whatsoever.

%% General settings
[wdir, ROOTDIR]     = DBSnetworks_defaults; cd(wdir)
flag_check          = 1;                                                        % defines whether results should be plotted (1) or not (0)
all_conds           = {'off', '60', '130', '180'};
fx_transpose        = @(x) x.';
[dattable, patdat]  = read_metadata(fullfile(ROOTDIR, 'data'));                 % necessary to save changes later
subj_idx            = find(cell2mat(cellfun(@(x) ismember({x}, subj), ...       % index of the subject in the table
    dattable.pseudonym, 'UniformOutput', false)), 1);

if isempty(subj_idx)
    warning("No subject with the pseudonym: %s available. Stopping!", subj)
end

%% Start with ICA in order to remove blink artefacts
fprintf('\n\tremoving blink artefacts for {subj}:\t%s - %s-cond', subj, cond)
load(filename_rsp);                                             %#ok<LOAD>  % this line loads the resampled data into workspace
try data_rsp = sorted_data(data_rsp, 1); catch; end             %#ok<NODEF> % in order to make FT recognize 'Iz', it is necessary to rename it; besides, elec labels are sorted alphabetically for consistency

% Filter and detrend to remove drifts
cfg = [];                                                                   % this steps intends to remve drifts from the continous data
cfg.channel = 'EEG';                                                        % for ICA being more precise
cfg.hpfilter= 'yes';
cfg.detrend = 'yes';
cfg.hpfreq  = 0.5;
data_rsp    = ft_preprocessing(cfg, data_rsp);

% Estimates the different components available in the data
cfg = [];                                                                   % this steps runs an independent component analysis on the continous data
cfg.method  = 'runica';                                                     % to determine the blink artifacts and later reject them
cfg.channel = 'EEG';                                                        % select only EEG channels
data_comp  = ft_componentanalysis(cfg, data_rsp);

% Plot frontal data to compare w/ ICA later
cfg = [];
cfg.channel         = {'Fp1', 'Fp2', 'Fpz'};                                % channels to be plotted
cfg.viewmode        = 'butterfly';                                          % data is plotted either 'vertical' or as a 'butterfly'
cfg.preproc.bpfilter= 'yes';                                                % filtering and pre-processing of the data
cfg.preproc.bpfreq  = [1 40];
cfg.preproc.demean  = 'yes';
cfg.preproc.detrend = 'yes';
cfg.blocksize       = 10;                                                   % no. of seconds to display
cfg.layout          = 'eeg1005.lay';                                        % specifies the layout file that should be used for plotting
ft_databrowser(cfg, data_rsp)

% Plot all components to selects those corresponding to blink artifacts
cfg = [];
cfg.viewmode = 'component';
cfg.blocksize= 10;                                                          % no. of seconds to display
cfg.layout   = 'eeg1005.lay';                                               % specifies the layout file that should be used for plotting
try ft_databrowser(cfg, data_comp); catch; end

done = 0;
while done == 0
    prompt  = sprintf('Enter ICA-component to remove. In case of several components,use semicoli "";"" in between');
    dlgtitle= 'ICA-Components to remove';                                   % GUI title
    dims    = [1, 60];                                                      % GUI size
    definput= "1;2";                                                        % GUI default input
    keyboard;
    
    answer = inputdlg(prompt,dlgtitle, dims, definput);
    x = fx_transpose(str2double(split(answer{1}, ';')));% extract the components to remove
    done = 1;
    if length(x) > 4
        answer = questdlg('>4 components selected. Continue?', ...
            'Warning: Many components to be removed', 'Yes','No','No');
        if strcmp(answer, 'Yes'); done = 1; else; done = 0; end
    else
        done = 1;
    end
end

% Components excluded from original data
cfg = [];
cfg.component   = x;
data_noica      = ft_rejectcomponent(cfg, data_comp, data_rsp);             % the next line removes the selected components

idx = 1;
if ~isempty(patdat)
    matches=cellfun(@(x) strcmp(x, subj), {patdat(:).subj}, 'Un', 0);
    idx = find(cell2mat(matches));
end

patdat(idx).subj = subj;
patdat(idx).bt{find(ismember(all_conds, cond))} = x; %#ok<FNDSB>
save(fullfile(ROOTDIR, 'data', 'preprocess_data.mat'), 'patdat', '-v7.3');

%  Plot differences before ICA removal and after
if flag_check == 1
    cfg = [];
    cfg.datafile        = data_rsp;                                         % first file to be plotted
    cfg.channel         = 1:42;%'EEG';                                      % channels to plot
    cfg.ylim            = [-1 1].*25;                                        % scale at the y-axis
    cfg.viewmode        = 'vertical';
    cfg.preproc.bpfilter= 'yes';                                            % defines the preprocessing thta happens with the data, that is
    cfg.preproc.bpfreq  = [1 40];                                           % band-pass filtering
    cfg.preproc.demean  = 'yes';                                            % de-meaning
    cfg.preproc.detrend = 'yes';                                            % de-trending
    cfg.blocksize       = 25;                                               % no. of seconds to display
    cfg.layout          = 'eeg1005.lay';                                    % specifies the layout file that should be used for plotting
    ft_databrowser(cfg, data_rsp)                                           % before bad channel interpolation
    
    cfg.datafile = data_noica;                                              % second file to be plotted
    ft_databrowser(cfg, data_noica);                                        % after all steps of interpolation/ICA and rejection
    keyboard
end

save(filename_noica, 'data_noica', '-v7.3');                                % save data to (outdir)
end