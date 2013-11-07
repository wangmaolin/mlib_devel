function sl_goto_reindex(inArgs)
%--------------------------------------------------------------------------
% Description : Create 'From' blocks with same appearance and properties of
%               'Goto' blocks selected in the model
%
% Author:       Giacomo Faggiani
% Rev :         11-03-2009 - First version
%
% Copyright (c) 2009, Giacomo Faggiani
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without 
% modification, are permitted provided that the following conditions are 
% met:
% 
%     * Redistributions of source code must retain the above copyright 
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright 
%       notice, this list of conditions and the following disclaimer in 
%       the documentation and/or other materials provided with the distribution
%       
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
% POSSIBILITY OF SUCH DAMAGE.
%
% Modified 7/11/13 JH: Allow auto incrementing of both From and GoTo blocks
%-------------------------------------------------------------------------

% input inArgs is needed to link with sl_customization.m, but it is not
% used.

% Select blocks in the model
%It is better to use handle instead of path, there is a bug in the way
%Simulink use block names
%http://www.mathworks.com/support/solutions/en/data/1-O7JS8/?solution=1-O7JS8
GotoList = find_system(gcs,'LookUnderMasks','on','Selected','on','BlockType','Goto');
FromList = find_system(gcs,'LookUnderMasks','on','Selected','on','BlockType','From');
List = [GotoList, FromList];
GotoListHandle = get_param(List,'Handle');


if isempty(GotoListHandle)
    % no Goto block selected.
    return
end

for i = 1 : length(GotoListHandle)

    % get tag name
    SignalName=get_param(GotoListHandle{i},'GotoTag');
    
    
    %%%% Don't do this -- it can have unintended side effects when combined
    %%%% with simulink's auto-incremented naming. I.e., this script might
    %%%% try to create blocks which already exist and throw errors.
    %% change name accorging to Goto Tag.
    %% if you have created this block by copy&paste.
    %% it's probable that block name doesn't correspond to its tag
    %set_param(GotoListHandle{i},'Name',['Goto_' SignalName]);   
    
    BlockType=get_param(GotoListHandle{i},'BlockType');
    BlockForegroundColor=get_param(GotoListHandle{i},'ForegroundColor');
    BlockBackgroundColor=get_param(GotoListHandle{i},'BackgroundColor');
    BlockShowName=get_param(GotoListHandle{i},'ShowName');
    BlockFontName=get_param(GotoListHandle{i},'FontName');
    BlockFontSize=get_param(GotoListHandle{i},'FontSize');
    BlockFontWeight=get_param(GotoListHandle{i},'FontWeight');
    BlockFontAngle=get_param(GotoListHandle{i},'FontAngle');
    BlockTagVisibility=get_param(GotoListHandle{i},'TagVisibility');
    BlockDropShadow=get_param(GotoListHandle{i},'DropShadow');
    BlockNamePlacement=get_param(GotoListHandle{i},'NamePlacement');
    BlockOrientation= get_param(GotoListHandle{i},'Orientation');
    ParentName = get_param(GotoListHandle{i},'parent');
    
    % Figure out new signal ID
    m   = regexp(SignalName, '(?<rootname>\w+)(?<idx>\d+)$', 'names');
    if isempty(m)
        NewSignalName = strcat(SignalName, '1');
    else
        idx = str2num(m.idx) + 1;
        NewSignalName = strcat(m.rootname, num2str(idx));
    end %if
    

    % We'll use the SignalName as the from block name, but this might already exist.
    % Check if it does, and increment an appendix if so.
    name_appendix = 0;
    exists = 1;
    while exists
            NewBlockName = [ParentName,'/',NewSignalName,'_',num2str(name_appendix)];
        try
            find_system(NewBlockName);
            name_appendix = name_appendix + 1;
        catch exception
            exists=0;
        end
    end
    
        
    CurrBlockPosition=get_param(GotoListHandle{i},'Position');
    BlockLength=CurrBlockPosition(3)-CurrBlockPosition(1);
    NewBlockPosition(1)=CurrBlockPosition(3)+BlockLength/2; %Left
    NewBlockPosition(2)=CurrBlockPosition(2);%Top
    NewBlockPosition(3)=NewBlockPosition(1)+BlockLength;%Right
    NewBlockPosition(4)=CurrBlockPosition(4);%Bottom
    
    add_block(['built-in/',BlockType],NewBlockName,...
        'GotoTag',NewSignalName,...
        'position',NewBlockPosition,...
        'ForegroundColor',BlockForegroundColor,...
        'BackgroundColor',BlockBackgroundColor,...
        'ShowName',BlockShowName,...
        'FontName',BlockFontName,...
        'FontSize',BlockFontSize,...
        'FontWeight',BlockFontWeight,...
        'FontAngle',BlockFontAngle,...
        'TagVisibility',BlockTagVisibility,...
        'DropShadow',BlockDropShadow,...
        'NamePlacement',BlockNamePlacement,...
        'Orientation',BlockOrientation);

end %for


