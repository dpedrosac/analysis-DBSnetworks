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
[dattable, ~]  = read_metadata(fullfile(ROOTDIR, 'data'));% necessary to save changes later

subj_idx            = find(cell2mat(cellfun(@(x) ismember({x}, subj), ...   % index of the subject in the table
    dattable.pseudonym, 'UniformOutput', false)), 1);

if isempty(subj_idx)
    warning("No subject with the pseudonym: %s available. Stopping!", subj)
    return
end

%% Start with  ???
fprintf('\n\t removing "bad channels" for {subj}:\t%s - %s-cond', subj, cond)
load(filename_noica);                                           %#ok<LOAD>  % this line loads the resampled data into workspace
try data_noica = sorted_data(data_noica, 1); catch; end         %#ok<NODEF> % in order to make FT recognize 'Iz', it is necessary to rename it; besides, elec labels are sorted alphabetically for consistency

filename_trialdef   = strcat('trialdef_', subj, '_', cond, '_DBS.mat');
load(fullfile(wdir, 'data', 'metadata', filename_trialdef));    %#ok<LOAD>  % this line loads the trial definitions so that data may be cut into chunks to be processed
[bc, bt] = plot_epoched(subj, trialdef, cond, data_noica);

%% TODO:    1) bt and bc MUST be saved to the metadata file, in order to save results for all conditions;
%           2) there must be a 'flag' indicating that this step is already done        

%save(filename_noica, 'data_noica', '-v7.3');                                % save data to (outdir)
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
cfg.keeptrials  = 'nan';                                                    % replacing "bad channels" with nan makes it easier to idetify them later
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
keyboard;
end
