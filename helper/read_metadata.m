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
    varargin{2} = 0;
    if strcmp(getenv('username'), 'dpedrosa')
        datdir = 'D:\skripte\analysis-DBSnetworks\';
    elseif strcmp(getenv('username'), 'Alexander')% TODO: anpassen
        datdir = 'C:\Users\User\Documents\Alexander\Uni\Doktorarbeit\analysis-DBSnetworks-master';
    elseif strcmp(getenv('username'), 'Emil')
        datdir = 'D:\DBSnetworks';
    else
        error('ROOTDIR unknown, please define directory to work at')
    end
elseif nargin == 1
    datdir = varargin{1};
    varargin{2} = 0;
end

filename_metadata = fullfile(datdir, 'metadata_DBSnetworks.xlsx');
    
    
if varargin{2} == 1
    detectImportOptions(filename_metadata);
    keyboard;
end

dat = readtable(filename_metadata);
