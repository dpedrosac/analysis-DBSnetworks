function [dattable, patdat] = read_metadata(varargin)

%   Function which reads metadata from xls-file; returns a table

%   ## Version 1.1

%   Copyright (C) September 2020, modified October 2020
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
try
    load(fullfile(datdir, "preprocess_data.mat"));
catch
    patdat = [];
end

if varargin{2} == 1
    opts = detectImportOptions(filename_metadata); %#ok<NASGU>
    keyboard;
end

dattable = readtable(filename_metadata);
