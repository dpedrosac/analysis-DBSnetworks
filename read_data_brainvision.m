function read_data_brainvision(wdir, subj, experiment)

%   This function reads (raw) data and performs a resampling with the
%   fieldtrip toolbox; besides, artefact correction for DBS signals
%   is performed on the raw signal.

%   ## Version 1.4

%   Copyright (C) December 2017, modified March 2019 and September 2020
%   D. Pedrosa, Emil Pruchnewski, Alexander Sperlich, Josefine Waldthaler
%   University Hospital of Gießen and Marburg
%
%   This software may be used, copied, or redistributed as long as it is
%   not sold and this copyright notice is reproduced on each copy made.
%   This routine is provided as is without any express or implied
%   warranties whatsoever.

cd(fullfile(wdir, 'raw_data'))
[~, ROOTDIR] = DBSnetworks_defaults;

%% General settings
rspl_freq       = 250;                                                      % frequency at which the data will be resampled
conds           = {'off', '60', '130', '180'};
nchans          = 132;
debug           = 0;

outdir = fullfile(wdir, 'data_rsp');                                        % directory in which data will be saved
if ~exist(outdir, 'dir'), mkdir(outdir); end                                % create directory, if not present already

% Start extracting and resampling data
for s = 1:numel(subj)
    fprintf('\n\tprocessing subj: %s\n', num2str(subj{s}))
    dir_rawdata = fullfile(wdir, 'raw_data', subj{s});                      % folder in which raw data is stored
    file_prefix = subjdetails(ROOTDIR, subj{s});
    
    for c = 1:numel(conds)
        fprintf('\t\t ... condition: %s', num2str(upper(conds{c})))
        filename_save = strcat('data_rsp_', file_prefix, '_', ...
            conds{c}, sprintf('_%s', experiment), '.mat');                  % filename under which data will be saved in the (outdir) directory
        
        if ~exist(fullfile(outdir, filename_save), 'file')                  % if filename has already been processed, subject is skipped to save time
            clear filename2load data_all data_rsp;                          % clears data that will be used from now on in loops
            filename2load = fullfile(dir_rawdata, strcat(file_prefix, ...
                sprintf('_%s_', experiment), conds{c}, '.eeg'));            % filename, so that data may be loaded
            
            if ~exist(filename2load, 'file')
                fprintf('\t\tproblem with reading data from subj: %s, cond: %s. Please select file manually \n', s, conds{c});
                
                cd(dir_rawdata)                                             % change directory and select file manually
                [file,path] = uigetfile('*.eeg');
                if isequal(file,0)
                    fprintf('No file selected, skipping to next subject ...\n');
                    continue
                else
                    filename2load = file;
                    fprintf('\n\t\tThe selected file for the %s condition is: %s\n', conds{c}, fullfile(path,file));
                end
                cd(wdir)
            end
            
            %   Reads data from original brainvision-files taking
            %   specific channels into account
            cfg = [];                                                       % cfg is used in the for-loop for reading and downsampling data channelwise
            cfg.resamplefs = rspl_freq;
            cfg.detrend    = 'no';
            cfg.feedback   = 'no';
            
            singlechan = cell(1, nchans);  %cell(1,4)%                      % pre-allocate space
            for i=1:nchans % for loop is necessary because of size if the data over 2GB
                cfg_temp = [];
                cfg_temp.channel    = i;                                    % can bei either string (channel name) or number
                cfg_temp.dataset    = filename2load;                        % reads data from filename as defined before
                cfg_temp.feedback   = 'no';                                 % no feedback given during processing
                temp                = ft_preprocessing(cfg_temp);
                fprintf('\n\t\t\t... processing %s {%s of %s channels = %.1f%% done} \n', ...
                    temp.label{1}, num2str(i-1), num2str(nchans), (i-1)/nchans*100)
                
                % remove DBS artfact
                if ~strcmp(conds{c}, 'off')
                    temp_filtered = ...
                        DBSartefacts_removal(temp, 'simple_filter', ...
                        str2double(conds{c}));
                    temp_processed = ...
                        DBSartefacts_removal(temp_filtered, ...
                        'hampel_identifier', str2double(conds{c}));
                    
                    if debug == 1
                        plot_removeDBSartefact(temp, temp_processed, ...
                            str2double(conds{c}), 100)
                    end
                else
                    temp_processed = temp;
                end
                singlechan{i}       = ft_resampledata(cfg, temp_processed);
            end
            fprintf('\n\t\tprocessed all %s channels\n', num2str(nchans))
            
            % Append data to one file/
            cfg = [];
            data_rsp = ft_appenddata(cfg, singlechan{:});
            
            if debug == 1
                cfg = [];
                cfg.viewmode = 'vertical';
                ft_databrowser(cfg, data_rsp)
            end
            
            % Saves data to pre-specified folder
            save(fullfile(outdir, filename_save), 'data_rsp', '-v7.3');
            
            %% Second part: extract header information
            filename_header = strcat('header_', file_prefix, '_', ...
                conds{c}, sprintf('_%s', experiment), '.mat');              % filename to name data in the (outdir_hdr) folder
            outdir_hdr = fullfile(wdir, 'metadata_eeg');                    % directory in which metadata (header and events) will be saved
            if ~exist(outdir_hdr, 'dir'), mkdir(outdir_hdr); end            % create directory, if not present already
            
            hdr = ft_read_header(filename2load);
            save(fullfile(outdir_hdr, filename_header), 'hdr', '-v7.3');
            
            %% Third part: read event information
            filename_events = strcat('events_', file_prefix, '_', ...
                conds{c}, sprintf('_%s', experiment), '.mat');              % filename to name data in the (outdir_hdr) folder
            events = ft_read_event(filename2load);
            save(fullfile(outdir_hdr, filename_events), 'events', '-v7.3');
            
            %% Last part: save events to table/excel file
            [path, namefile] = fileparts(filename2load);                    % separate path and filename to use later
            
            if strcmp(experiment, 'DBS')
                interval = [1.5, 5];
            else
                interval = [1, 3];
            end
            % start getting the data to later epoch the file
            cfg = [];
            cfg.datafile            = filename2load;
            cfg.headerfile          = ...
                strcat(fullfile(path, namefile), '.vhdr');                  % this just defines the orignal header file
            cfg.trialfun            ='ft_trialfun_general';                 % this is the default
            cfg.trialdef.eventtype  = 'Stimulus';
            cfg.trialdef.prestim    = interval(1);                          % in seconds before time = 0;
            cfg.trialdef.poststim   = interval(2);                          % in seconds after time = 0;
            trialdef                = ft_definetrial(cfg);
            
            filename_trials = strcat('trialdef_', file_prefix, '_', ...
                conds{c}, sprintf('_%s', experiment), '.mat');              % filename to name data in the (outdir_hdr) folder
            
            save(fullfile(outdir_hdr, filename_trials), 'trialdef','-v7.3');% saves trial data
            
            filename_excl = strcat(wdir, '\', ...
                sprintf('events_%s_', experiment), conds{c}, '.xlsx');
            table = output_excel(events, hdr);
            writetable(table, filename_excl, 'Sheet', file_prefix)
        else
            fprintf('\t<strong> ... already processed, continuing!</strong> \n');
            continue
        end
    end
end