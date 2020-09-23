function plot_removeDBSartefact(pre, post, DBS_freq, fig_num)

%   This function plots differences between pre-processing and after
%   removing DBS artefacts

%   ## Version 1.0

%   Copyright (C) September 2020
%   D. Pedrosa, Emil Pruchnewski, Alexander Sperlich, Josefine Waldthaler
%   University Hospital of Gießen and Marburg
%
%   This software may be used, copied, or redistributed as long as it is
%   not sold and this copyright notice is reproduced on each copy made.
%   This routine is provided as is without any express or implied
%   warranties whatsoever.

if nargin < 4
    fig_num = 100;
elseif nargin < 3
    DBS_freq = 130;
end

% General settings/options
p               = figure_params_gen;
sr              = pre.fsample;
Hs1             = spectrum.welch('Hamming', sr); %#ok<DWELCH>
data_all        = {pre, post};
title_text      = {'Raw data', 'After removing \nDBS-artefact'};
interval        = 2500; % msec.
start_time      = 500; % sec (random time of the recordings)
data_interval   = dsearchn(data_all{1}.time{1}.', ...
    [start_time, start_time+interval/1000].');                                % get the indices of the time which should be plotted
spec            = arrayfun(@(q) psd(Hs1, data_all{q}.trial{1}.', 'Fs', sr), ...
    1:numel(data_all), 'UniformOutput', 0);                                 % Raw frequency representation of data as recorded
max_spec = max(cellfun(@(x) max(x.Data), spec));
min_spec = min(cellfun(@(x) min(x.Data), spec));

%% Start plotting the results
close all
figure(fig_num); clf; hold on;
set( gcf, 'Color', 'White', 'Unit', 'Normalized', ...
    'Position', [0.1,0.1,0.6,0.6] ) ;
axis off;

% - Compute #rows/cols, dimensions, and positions of lower-left corners.
nCol = 2;  nRow = 2;
rowH = 0.72 / nRow ;  colW = 0.7 / nCol ;
colX = 0.06 + linspace( 0, 0.96, nCol+1 ) ;  colX = colX(1:end-1) ;
rowY = 0.1 + linspace( 0.9, 0, nRow+1 ) ;  rowY = rowY(2:end) ;

% - Build subplots axes and plot data.
for dId = 1:nRow*nCol% loop through the different options to plot
    rowId = ceil( dId / nCol );
    colId = dId - (rowId - 1) * nCol ;
    axes( 'Position', [colX(colId), rowY(rowId), colW, rowH] ) ;
    
    if rowId == 1
        plot(data_all{colId}.time{1}(data_interval(1):data_interval(2)), ...
            data_all{colId}.trial{1}(data_interval(1):data_interval(2)), ...
            'Color', p.colors{1})
        xlabel(sprintf('Arbitrary time [in secs]' ), 'FontName', p.ftname);

        if colId == 1
            ylabel(sprintf('EEG-signal [in mV]' ), 'FontName', p.ftname);
        end
    else
        semilogy(spec{colId}.Frequencies, spec{colId}.Data, ...
            'Color', p.colors{1}); hold on;
        semilogy(spec{1}.Frequencies, spec{1}.Data, 'Color', p.colors{4})
        grid on; ylim([min_spec max_spec*1.2]); xlim([0 DBS_freq].*1.25)
        xlabel(sprintf('Frequency [in Hz]' ), 'FontName', p.ftname);
        
        if colId == 1
            ylabel(sprintf('PSD [in log(A.U.)]' ), 'FontName', p.ftname);
        end
    end
    if rowId == 1
        title(sprintf('Data: %s', title_text{colId}), ...
            'Interpreter', 'none')
    end
    
end


%% Build title axes and title.
axes( 'Position', [0, 0.95, 1, 0.05] ) ;
set( gca, 'Color', 'None', 'XColor', 'White', 'YColor', 'White' ) ;
text( 0.5, 0, sprintf('PSD estimates before \nand after removing DBS-artefacts'),...
    'FontSize', p.ftsize(1), 'FontWeight', 'Bold', ...
    'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom' ) ;



