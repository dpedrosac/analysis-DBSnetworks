function varargout = ...
    DBSartefacts_removal(data2process, options, DBSfreq)

%   This function removes the DBS artefact making use of the
%   algorithm/toolbox developed at the Centre de Neurosciences Cognitives,
%   in Lyon, France (https://github.com/guillaumelio/DBSFILT)

%   INPUTS: data2process = fieldtrip dataframe for unprocessed data
%   OUTPUTS: 1) fieldtrip structre including time series w/o DBS artefact,
%            2) filter coeffs (for opt: [simple_filter])

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
    fprintf("\n option argument is missing. Please provide a method to remove DBS artefacts")
    return
end

switch options
    case 'simple_filter' % high- and low-pass filter data
        filterOrder     = 4;
        f_lpf           = DBSfreq*.8;
        f_hpf           = .5;
        sr              = data2process.fsample;
        [blow,alow]     = butter(filterOrder,2*f_lpf/sr,'low');         % Low pass filter at defined frequency
        
        datafilt_low    = arrayfun(@(q) filtfilt(blow,alow, ...
            data2process.trial{q}), 1:numel(data2process),...
            'UniformOutput',false);
        [bhigh,ahigh]  = butter(filterOrder,2*f_hpf/sr,'high');         % High pass filter at defined frequency
        datafilt_lowhigh = arrayfun(@(q) filtfilt(bhigh,ahigh, ...
            datafilt_low{q}),1:numel(datafilt_low),...
            'UniformOutput',false);
        data2process.trial = datafilt_lowhigh;
        varargout{1} = data2process;
        varargout{2} = [blow; alow];
        varargout{3} = [bhigh; ahigh];
        
    case 'hampel_identifier' % identify peaks and remove data
        [spikes, ~, ~]=DBSFILT_PrepareSpikesDetection(data2process.trial{1}, ...
            data2process.fsample);
        type    = 2; % Hampel identifier and refined spike identification
        HampelL = 1; % windows size for aut. spike detection (Hz)
        HampelT = 2; % Hampel threshold for automatic spike detection.
        
        [spikes, ~] = DBSFILT_SpikesDetection(spikes, type, ...
            HampelL, HampelT, DBSfreq, DBSfreq, 5, .01);
        
        data_filt = DBSFILT_SpikesRemoval(spikes, data2process.trial{1}, ...
            data2process.fsample);
        data2process.trial = {data_filt};
        varargout{1} = data2process;
    otherwise
        fprintf("\n {%s} not implemented!", options)
        return
end
