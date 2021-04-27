function remove_badchannels(subj, cond, filename_noica, filename_clean)

%   This function is intended to remove "bad" channels, that is those
%   affected by excessive artefacts durin recordings; The inputs are two
%   filenames (pre and post-processing) the subject pseudonym and the
%   condition [off, 60, 130, 180] to be processed

%   ## Version 1.0

%   Copyright (C) March 2021
%   D. Pedrosa, Alexander Sperlich, Josefine Waldthaler, Charlotte Stüssel
%   University Hospital of Gießen and Marburg
%
%   This software may be used, copied, or redistributed as long as it is
%   not sold and this copyright notice is reproduced on each copy made.
%   This routine is provided as is without any express or implied
%   warranties whatsoever.

%% General settings
[wdir, ROOTDIR]     = DBSnetworks_defaults; cd(wdir)
all_conds           = {'off', '60', '130', '180'};
fx_transpose        = @(x) x.';
[dattable, patdat]  = read_metadata(fullfile(ROOTDIR, 'data'));% necessary to save changes later

subj_idx            = find(cell2mat(cellfun(@(x) ismember({x}, subj), ...   % index of the subject in the table
    dattable.pseudonym, 'UniformOutput', false)), 1);
if size(patdat,2) < subj_idx
    patdat(subj_idx).subj = [];
else
    patdat(subj_idx).subj = subj;
end

cond_idx = find(strcmp(cond, all_conds));
if isempty(subj_idx)
    warning("No subject with the pseudonym: %s available. Stopping!", subj)
    return
end

%% Start with identifying "bad channels" and "bad trials"
fprintf('\n\t removing "bad channels" for {subj}:\t%s - %s-cond', subj, cond)
load(filename_noica);                                           %#ok<LOAD>  % this line loads the resampled data into workspace
try data_noica = sorted_data(data_noica, 1); catch; end         %#ok<NODEF> % in order to make FT recognize 'Iz', it is necessary to rename it; besides, elec labels are sorted alphabetically for consistency

filename_trialdef   = strcat('trialdef_', subj, '_', cond, '_DBS.mat');
load(fullfile(wdir,'metadata_eeg', filename_trialdef));    %#ok<LOAD>  % this line loads the trial definitions so that data may be cut into chunks to be processed
[bc, bt] = plot_epoched(subj, trialdef, cond, data_noica);

patdat(subj_idx).bt{cond_idx}= bt;
patdat(subj_idx).bc{cond_idx}= bc;

filename_patdat = fullfile(ROOTDIR, 'data', 'preprocess_data.mat');
backup_preprocessed(filename_patdat, ROOTDIR)                               % backup data so that no information is lost
save(filename_patdat, 'patdat', '-v7.3');                                   % save data to (outdir)
end

function [bc, bt] = plot_epoched(subj, trialdef, cond, data_noica)
%% This function is just a helper to cut data and plot everything according
% to the trials saved in the trialdef file
frsp = 5000/data_noica.fsample;
fprintf('\nthe subject actually being processed is %s in the %s condition \n', ...
    subj, cond);

% Cut data into chunks of data w/ same length aligned at trial start
cfg = [];
cfg.trl         = trialdef.trl;
cfg.trl(:,1:2)  = round(cfg.trl(:,1:2)./frsp);                              % the next two lines intend to "resample" the trialdefinition in a
cfg.trl(:,3)    = round(cfg.trl(:,3)./frsp);                                % admittedly not very elegant way, but it works!
idx_low         = find(cfg.trl(:,1) - cfg.trl(:,2) == -499);
idx_high        = find(cfg.trl(:,1) - cfg.trl(:,2) == -501);

if ~isempty(idx_low); cfg.trl(idx_low,2) = cfg.trl(idx_low,2)+1; end
if ~isempty(idx_high); cfg.trl(idx_high,2) = cfg.trl(idx_high,2)+1; end

cfg.minlength   = 'maxperlen';                                              % this ensures all resulting trials are equal length
data_epoched = ft_redefinetrial(cfg, data_noica);

cfg = [];
cfg.trials = find(data_epoched.trialinfo == 2);
data_epoched = ft_preprocessing(cfg, data_epoched);

% Start plotting data stacked 'vertically'
cfg = [];
cfg.channel         = 1:42;%'EEG';                                          % only EEG channels are plotted, to obtain approximately equal number of channels, the first 42 are selected
cfg.viewmode        = 'vertical';                                           % display data vertically
cfg.yaxis           = [-1 1].*40;                                           % scale of y-axis (arbitrary)
cfg.preproc.bpfilter= 'yes';                                                % band-pass filter settings in the next two lines
cfg.preproc.bpfreq  = [1 80];
cfg.preproc.bsfilter= 'yes';                                                % band-stop filter settings in the next two lines (notch filter for 50Hz noise)
cfg.preproc.bsfreq  = [48 52];
cfg.preproc.demean  = 'yes';                                                % de-mean data
cfg.preproc.detrend = 'yes';                                                % detrend data
cfg.blocksize       = 25;                                                   % no. of seconds to display
cfg.layout          = 'eeg1005.lay';                                        % specifies the layout file that should be used for plotting

cfg.datafile = data_noica;
ft_databrowser(cfg, data_noica);

cfg.datafile = data_epoched;
cfg.blocksize = 3.5;
ft_databrowser(cfg, data_epoched);

% Displayed/select channels with artefacts according to some metric
cfg = [];
cfg.method      = 'summary';
cfg.metric      = 'zvalue';
cfg.channel     = 'EEG';
cfg.keepchannel = 'nan';                                                    % replacing "bad channels" with nan makes it easier to idetify them later
cfg.keeptrial   = 'nan';                                                    % replacing "bad channels" with nan makes it easier to idetify them later
dummy           = ft_rejectvisual(cfg, data_epoched);

% Select bad trials according to 'ft_rejectvisual routine and save them
bt = find(cell2mat(arrayfun(@(q) all(isnan(dummy.trial{q}(:))), ...
    1:numel(dummy.trial), 'Un', 0)));
bc_select = ...
    find(any(isnan(cat(2,dummy.trial{setdiff(1:numel(dummy.trial), bt)})),2));
bc = {dummy.label{bc_select}}; %#ok<FNDSB>

prompt  = sprintf('Please take a minute to verify the results;\nbad trials:\t%s,\nbad channels:\t%s', ...
    regexprep(num2str(bt),'\s+',','), strjoin(bc,', '));
waitfor(warndlg(prompt, 'Warning'));
keyboard
close all
end

function backup_preprocessed(filename_metadata, ROOTDIR)
%% Backup for patdat information

folder_backup = fullfile(ROOTDIR, 'data', 'backup');
if ~exist(folder_backup, 'dir'); mkdir(folder_backup); end
target_file = fullfile(folder_backup, sprintf('%spreprocess_data.mat', datestr(now,'mm-dd-yyyy_HH-MM-SS')));
copyfile(filename_metadata, target_file)
end
