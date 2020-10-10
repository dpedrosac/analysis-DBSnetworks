function select_files2analyse
%   This is a GUI which enables to select the subjects to look at and the 
%   steps that should be applied

%   Copyright (C) September 2020
%   D. Pedrosa, Emil Pruchnewski, Alexander Sperlich, Josefine Walthaler 
%   University Hospital of Gießen and Marburg
%
%   This software may be used, copied, or redistributed as long as it is
%   not sold and this copyright notice is reproduced on each copy made.
%   This routine is provided as is without any express or implied
%   warranties whatsoever.

[~, ROOTDIR] = DBSnetworks_defaults;

%% General settings
listbox_width   = 250;
listbox_height  = 400;
fig             = uifigure('Position',[100 250 650 600], ... 
                'Name', 'Control GUI to select subjects and steps2apply');
debug           = 0;                                                        % adds the possibility to debug the code if necessary      
[dat, ~] = read_metadata(fullfile(ROOTDIR, 'data'));

%% create the items'-lists which may be displayed later
items_steps2apply = {   'read_data_brainvision', ....
                        'clean_data'   };
items_pseudonyms = dat.pseudonym;

% Create list box left (subjects)
lbox1 = uilistbox(fig,...
    'Position',[25 120 listbox_width listbox_height],...
    'MultiSelect', 'on', ...
    'Items',items_pseudonyms);
uilabel(fig, ...
    'Position', [25 120+listbox_height 150 22], ...
    'Text', 'Subjects to include');


% Create list box right (steps2apply)
lbox2 = uilistbox(fig,...
    'Position',[listbox_width+50 120 listbox_width listbox_height],...
    'MultiSelect', 'on', ...
    'Items',items_steps2apply);
uilabel(fig, ...
    'Position', [listbox_width+50 120+listbox_height 150 22], ...
    'Text', 'Adaptations to use');
% TODO: include some titles for both lists

% Create a push button
btn = uibutton(fig, 'Push', 'Text', sprintf('Start \nanalysis'),...
               'Position',[450, 60, 100, 42],...
               'ButtonPushedFcn', @(btn,event) startAnalysis(btn, ...
               lbox1, lbox2)); %#ok<NASGU>

%% Callback section    
    function startAnalysis(~, lbox1, lbox2)
        %disp('Button pressed!')
        %disp(lbox1.Value)
        %disp(lbox2.Value)
        DBSnetworks_ctrl_script(lbox2.Value, lbox1.Value)
        closereq()
    end

end