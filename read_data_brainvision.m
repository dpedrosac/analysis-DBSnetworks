function read_data_brainvision(wdir, subj)

%   This function reads (raw) data and performs a resampling with the
%   fieldtrip toolbox

%   ## Version 1.2

%   Copyright (C) December 2017, modified March 2019 and September 2020
%   D. Pedrosa, Emil Pruchnewski, Alexander Sperlich, Josefine Waldthaler
%   University Hospital of Gießen and Marburg
%
%   This software may be used, copied, or redistributed as long as it is
%   not sold and this copyright notice is reproduced on each copy made.
%   This routine is provided as is without any express or implied
%   warranties whatsoever.

cd(fullfile(wdir, 'raw_data'))

%% General settings
rspl_freq       = 250;                                                      % frequency at which the data will be resampled
conds           = {'off', '60hz', '130hz', '180hz'};
nchans          = 132;

outdir = fullfile(wdir, 'data_rsp');                                        % directory in which data will be saved
if ~exist(outdir, 'dir'), mkdir(outdir); end                                % create directory, if not present already

% Start extracting and resampling data
for s = 1:numel(subj)
    fprintf('\n\tprocessing subj: %s', num2str(subj{s}))
    dir_rawdata = fullfile(wdir, 'raw_data', subj{s});                      % folder in which raw data is stored
    
    [file_prefix, ~] = subjdetails(subj{s});                                % extracts information from metadata file (xls-file)

    for c = 1:numel(conds)
        fprintf('\t\t\t condition: %s', num2str(upper(conds{c})))
        filename_save = strcat('datrsp_', file_prefix, '_', ...
            conds{c}, '.mat');                                              % filename under which data will be saved in the (outdir) directory
        
        if ~exist(fullfile(outdir, filename_save), 'file')                  % if filename has already been processed, subject is skipped to save time    
            clear filename2load data_all data_rsp;                          % clears data that will be used from now on in loops
            filename2load = fullfile(dir_rawdata, strcat(file_prefix, ...
            code_participant, '_', conds{c}, '.eeg'));                      % filename, so that data may be loaded
            
            if ~exist(filename2load, 'file')
                fprintf('\tproblem with reading data from subj: %s, cond: %s. Please select file manually \n', s, conds{c});
                
                cd(dir_rawdata)                                             % change directory and select file manually
                [file,path] = uigetfile('*.eeg');
                if isequal(file,0)
                    fprintf('No file selected, skipping to next subject ...\n');
                    continue
                else
                    filename2load = file;
                    fprintf('The selected file for the %s condition is: %s\n', conds{c}, fullfile(path,file));
                end
                cd(wdir)
            end
            
            %   Reads data from original brainvision-files taking 
            %   specific channels into account
            cfg = [];                                                       % cfg is used in the for-loop for reading and downsampling data channelwise
            cfg.resamplefs = rspl_freq;
            cfg.detrend     = 'no';
            
            % TODO: there must be a transformation/filtering of the
            % artifacts here before resampling occurs
            
            singlechan = cell(1, nchans);  %cell(1,4)%                      % pre-allocate space
            for i=1:nchans % for loop is necessary because of size if the data over 2GB
                fprintf('\n ... processed %s of %s channels, (%.1f%%) \n', ...
                    num2str(i-1), num2str(nchans), (i-1)/nchans*100)
                cfg_temp = [];
                cfg_temp.channel    = i;                                    % can bei either string (channel name) or number
                cfg_temp.dataset    = filename2load;                        % reads data from filename as defined before
                temp                = ft_preprocessing(cfg_temp);
                fprintf('\n\t\tprocessing channel no. %s ', temp.label{1});
                singlechan{i}       = ft_resampledata(cfg, temp);
            end
            fprintf('\n processed all %s channels', num2str(nchans))
            
            % Append data to one file/
            cfg = [];
            data_rsp = ft_appenddata(cfg, singlechan{:});
            
            % Saves data to pre-specified folder
            save(fullfile(outdir, filename_save), 'data_rsp', '-v7.3');
            
        else
            fprintf('subj: %s already read/resampled, next subj... \n', nam);
            continue
        end
    end
end
