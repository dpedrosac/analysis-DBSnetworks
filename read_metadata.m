function dat = read_metadata(varargin)

%   Function which reads metadata from xls-file; returns a table

%   Copyright (C) September 2020
%   D. Pedrosa, Emil Pruchnewski, Alexander Sperlich, Josefine Walthaler
%   University Hospital of Gießen and Marburg
%
%   This software may be used, copied, or redistributed as long as it is
%   not sold and this copyright notice is reproduced on each copy made.
%   This routine is provided as is without any express or implied
%   warranties whatsoever.

if nargin == 0
    if strcmp(getenv('username'), 'dpedrosa')
        ROOTDIR = 'D:\DBSnetworks';
        filename_metadata = fullfile(ROOTDIR, 'metadata_DBSnetworks.xlsx');
    else
        error('ROOTDIR unknown, please define directory to work at')
    end
end

debug = 0;
if debug == 1
    detectImportOptions(filename_metadata);
    keyboard;
end

dat = readtable(filename_metadata);
