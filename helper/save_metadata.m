function save_metadata(dattable, ROOTDIR, backup, filename_metadata)

%   Function which saving (changed) metadata to xls-file; With the option
%   for backup a copy is added in a separate folder

%   Copyright (C) September 2020
%   D. Pedrosa, Emil Pruchnewski, Alexander Sperlich, Josefine Walthaler
%   University Hospital of Gießen and Marburg
%
%   This software may be used, copied, or redistributed as long as it is
%   not sold and this copyright notice is reproduced on each copy made.
%   This routine is provided as is without any express or implied
%   warranties whatsoever.

if nargin == 0
    warning("No data provided; please double-check!")
elseif nargin == 1
    [~, ROOTDIR] = DBSnetworks_defaults;
    backup = 1;
    filename_metadata = fullfile(ROOTDIR, 'data', ...
        'metadata_DBSnetworks.xlsx');
elseif nargin == 2
    backup = 1;
    filename_metadata = fullfile(ROOTDIR, 'data', ...
        'metadata_DBSnetworks.xlsx');
elseif nargin == 3
    filename_metadata = fullfile(ROOTDIR, 'data', ...
        'metadata_DBSnetworks.xlsx');
end

if backup == 1
    folder_backup = fullfile(ROOTDIR, 'data', 'backup');
    if ~exist(folder_backup, 'dir'); mkdir(folder_backup); end;
    target_file = fullfile(folder_backup, sprintf('%smetadata_DBSnetworks.xlsx', datestr(now,'mm-dd-yyyy_HH-MM-SS')));
    copyfile(filename_metadata, target_file)
end

warning('off','MATLAB:xlswrite:AddSheet'); %optional
writetable(dattable, filename_metadata, 'Sheet', 1, 'FileType','text', 'Delimiter', 'tab');
