function plot_DBSfilterresuts(filename2load, varargin)

%   This function reads (raw) data and plots its autospectra; besides
%   different options to remove DBS artefacts are tested and compared
%   graphically

%   ## Version 1.0

%   Copyright (C) September 2020
%   D. Pedrosa, Emil Pruchnewski, Alexander Sperlich, Josefine Waldthaler
%   University Hospital of Gießen and Marburg
%
%   This software may be used, copied, or redistributed as long as it is
%   not sold and this copyright notice is reproduced on each copy made.
%   This routine is provided as is without any express or implied
%   warranties whatsoever.

if nargin < 2
    varargin{1} = 'P3';
    varargin{2} = 130;
    varargin{3} = {'simple_filter', 'hampel_identifier'};
elseif nargin < 3
    varargin{2} = 130;
    varargin{3} = {'simple_filter', 'hampel_identifier'};
elseif nargin < 4
    varargin{3} = {'simple_filter', 'hampel_identifier'};
end

%% Extract data with FT routines

cfg = [];
cfg.channel     = varargin{1};                                              % can bei either string (channel name) or number
cfg.dataset     = filename2load;                                            % reads data from filename as defined before
data2process    = ft_preprocessing(cfg);

%% Start with estimation of spectra and plotting data
sr              = data2process.fsample;
Hs1             = spectrum.welch('Hamming', sr); %#ok<DWELCH>
interval        = 2500; % msec.
start_time      = 500; % sec (random time of the recordings)
data_interval   = dsearchn(data2process.time{1}.', ...
    [start_time, start_time+interval/1000].');                                % get the indices of the time which should be plotted

%% Extract data to structures in order to process them sequentially
spec     = cell(1,numel(varargin{3})+1); data_all = spec;                       % Pre-allocate space
data_all{1} = data2process;

for opt = 1:numel(varargin{3}) % run different options to eliminate DBS artefacts
    if strcmp(varargin{3}{opt}, 'simple_filter')
        [data_all{opt+1}, lows, highs] = ...
            DBSartefacts_removal(data2process, varargin{3}{opt}, ...
            str2double(varargin{2}));
    elseif strcmp(varargin{3}{opt}, 'hampel_identifier')
        data_filtered = ...
            DBSartefacts_removal(data2process, 'simple_filter', ...
            str2double(varargin{2}));
        [data_all{opt+1}] = ...
            DBSartefacts_removal(data_filtered, varargin{3}{opt}, ...
            str2double(varargin{2}));
    end
end

spec  = arrayfun(@(q) psd(Hs1, data_all{q}.trial{1}.', 'Fs', sr), ...
    1:numel(data_all), 'UniformOutput', 0);                                 % Raw frequency representation of data as recorded
option = cat(2,{'raw_data'},varargin{3});

%% Start plotting the results
close all
p = figure_params_gen;
figure(98); clf; hold on;
set( gcf, 'Color', 'White', 'Unit', 'Normalized', ...
    'Position', [0.1,0.1,0.6,0.6] ) ;
axis off;

% - Compute #rows/cols, dimensions, and positions of lower-left corners.
nCol = 3;  nRow = numel(option);
rowH = 0.78 / nRow ;  colW = 0.7 / nCol ;
colX = 0.06 + linspace( 0, 0.96, nCol+1 ) ;  colX = colX(1:end-1) ;
rowY = 0.1 + linspace( 0.9, 0, nRow+1 ) ;  rowY = rowY(2:end) ;

% - Build subplots axes and plot data.
for dId = 1:2*numel(option)% loop through the different options to plot
    rowId = ceil( dId / nCol );
    colId = dId - (rowId - 1) * nCol ;
    axes( 'Position', [colX(colId), rowY(rowId), colW, rowH] ) ;
    
    if rowId == 1
        plot(data_all{colId}.time{1}(data_interval(1):data_interval(2)), ...
            data_all{colId}.trial{1}(data_interval(1):data_interval(2)), ...
            'Color', p.colors{1})
    else
        semilogy(spec{colId}.Frequencies, spec{colId}.Data, ...
            'Color', p.colors{1}); hold on;
        semilogy(spec{1}.Frequencies, spec{1}.Data, 'Color', p.colors{4})
        grid on; xlim([0 ceil(str2double(varargin{2})*1.2)])
        xlabel(sprintf('Frequency [in Hz]' ), 'FontName', p.ftname);
    end
    if rowId == 1
        title(sprintf('option: %s', option{colId}), 'Interpreter', 'none')
    end
end


%%
% - Build title axes and title.
axes( 'Position', [0, 0.95, 1, 0.05] ) ;
set( gca, 'Color', 'None', 'XColor', 'White', 'YColor', 'White' ) ;
text( 0.5, 0, 'PSD estimates for simulated data', 'FontSize', p.ftsize(1), 'FontWeight', 'Bold', ...
    'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom' ) ;



