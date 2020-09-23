<<<<<<< HEAD
function [wdir, ROOTDIR] = DBSnetworks_defaults(opt)
=======
function [wdir, ROOTDIR] = DBSnetworks_defaults
>>>>>>> d95015444f8b812f98c85e24ff2d431ba8c0c249

%   This is a set of default settings intended to facilitate the scripts
%   applied in this project

<<<<<<< HEAD
%   ## Version 1.2
=======
%   ## Version 1.1
>>>>>>> d95015444f8b812f98c85e24ff2d431ba8c0c249

%   Copyright (C) Juli 2020, modified September 2020
%   D. Pedrosa, Emil Pruchnewski, Alexander Sperlich, Josefine Walthaler
%   University Hospital of Gießen and Marburg
%
%   This software may be used, copied, or redistributed as long as it is
%   not sold and this copyright notice is reproduced on each copy made.
%   This routine is provided as is without any express or implied
%   warranties whatsoever.

if nargin == 0
    opt = 0;
end

if opt == 0
    restoredefaultpath
    close all; clear; clc;
end

if isunix
    wdir = '/media/storage/test_DBSnetworks';                               % defines the working directory
    ROOTDIR = '/media/storage/skripte/DBSnetworks/';                        % adds the folder with all scripts to the wdir
    addpath('/media/storage/skripte/fieldtrip/'); ft_defaults               % set fieldtrip defaults
elseif ispc
    if strcmp(getenv('username'), 'dpedrosa')
<<<<<<< HEAD
        wdir = 'C:\Users\dpedrosa\Downloads'; %'F:\EEG_DBSnetworks\';
=======
        wdir = 'F:\EEG_DBSnetworks\';
<<<<<<< HEAD
>>>>>>> d95015444f8b812f98c85e24ff2d431ba8c0c249
=======
>>>>>>> d95015444f8b812f98c85e24ff2d431ba8c0c249
        ROOTDIR = 'D:\skripte\analysis-DBSnetworks\';
        addpath('d:\skripte\fieldtrip'); ft_defaults;
    elseif strcmp(getenv('username'), 'Alexander')
        wdir = 'C:\Users\User\Documents\Alexander\Uni\Doktorarbeit\EEG_DBSnetworks';
        ROOTDIR = 'C:\Users\User\Documents\Alexander\Uni\Doktorarbeit\analysis-DBSnetworks-master';
        addpath('C:\Users\User\Documents\Fieldtrip\fieldtrip-20200919'); ft_defaults;
    elseif strcmp(getenv('username'), 'Emil')
        wdir = 'd:\test_DBSnetworks';
        ROOTDIR = [];
        addpath('d:\skripte\fieldtrip'); ft_defaults;
    else
        warning("Please specific folders to 'DBSnetworks_default.m' fitting to your settings")
    end
<<<<<<< HEAD
<<<<<<< HEAD
    addpath(genpath(ROOTDIR));
=======
    addpath(genpath(ROOTDIR))
>>>>>>> d95015444f8b812f98c85e24ff2d431ba8c0c249
=======
    addpath(genpath(ROOTDIR))
>>>>>>> d95015444f8b812f98c85e24ff2d431ba8c0c249
end