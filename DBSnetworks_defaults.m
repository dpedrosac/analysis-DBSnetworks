function wdir = DBSnetworks_defaults

%   This is a set of default settings intended to facilitate the scripts
%   applied in this project

%   Copyright (C) Juli 2020
%   D. Pedrosa, Emil Pruchnewski, Alexander Sperlich, Josefine Walthaler 
%   University Hospital of Gießen and Marburg
%
%   This software may be used, copied, or redistributed as long as it is
%   not sold and this copyright notice is reproduced on each copy made.
%   This routine is provided as is without any express or implied
%   warranties whatsoever.

restoredefaultpath
close all; clear; clc;

if isunix
    wdir = '/media/storage/test_DBSnetworks';                               % defines the working directory
    addpath(genpath('/media/storage/skripte/DBSnetworks/'));                % adds the folder with all scripts to the wdir
    addpath('/media/storage/skripte/fieldtrip/'); ft_defaults               % set fieldtrip defaults
elseif ispc
    if strcmp(getenv('username'), 'dpedrosa')
        wdir = 'd:\test_DBSnetworks';
        addpath('d:\skripte\analysis-DBSnetworks\');
        addpath('d:\skripte\fieldtrip'); ft_defaults;        
    else
        warning("Please specific folders to 'DBSnetworks_default.m' fitting to your settings")
    end
end