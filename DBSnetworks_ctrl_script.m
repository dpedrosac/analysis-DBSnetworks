function DBSnetworks_ctrl_script(varargin)

%%  Control file for analysis DBSnetworks data. This file controls
%   for all the different steps in order to get the preprocessing and
%   the analysis; Two inputs are possible

[wdir, ROOTDIR] = DBSnetworks_defaults(0);                                  % with the option, restoredefaultpath; clc; clear all; close all is used

%% General settings
if nargin == 0
    select_files2analyse
    return
elseif nargin == 1 % this means that only the steps are provided
    answer = questdlg('Assuming all subj. available should be analysed ?', ...
        'Selection subjects', 'Yes','No','Yes');
    if strcmp(answer, 'Yes')
        dattable = read_metadata(fullfile(ROOTDIR, 'data'));
        subj = dattable.pseudonym;
    else
        return
    end
elseif nargin == 2
    subj = varargin{2};
elseif nargin > 2
    warndlg('Too many inputs for this control function. Please double-check!','Warning');
    return
end

adap = get_adaptation(varargin{1});
if isempty(adap)
    warndlg('No adaptation was selected. Please check for errors','Warning');
    return
end

%% Start with the distinct steps in order to process data
for adap = adap % TODO: helper function is needed which selects the adap numbers according to the cells provided
    switch adap
        case (1)
            read_data_brainvision(wdir, subj, 'DBS')
        case (2)
            clean_data(wdir, subj, 'DBS')
            
    end
end

end

function adap = get_adaptation(selected_cells)
% This function returns the adaptations that should be analysed

available_adaps = {   'read_data_brainvision', ....
    'clean_data'   };
matches=cellfun(@(x) ismember(x, available_adaps), ...
    selected_cells, 'UniformOutput', 0);
adap = find(cell2mat(matches));
end