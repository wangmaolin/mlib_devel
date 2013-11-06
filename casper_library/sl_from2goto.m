function sl_from2goto(inArgs)
%--------------------------------------------------------------------------
% Description : Create 'From' blocks with same appearance and properties of
%               'Goto' blocks selected in the model
%
% Author:       Giacomo Faggiani
% Rev :         11-03-2009 - First version
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
%-------------------------------------------------------------------------

% input inArgs is needed to link with sl_customization.m, but it is not
% used.

% Select blocks in the model
%It is better to use handle instead of path, there is a bug in the way
%Simulink use block names
%http://www.mathworks.com/support/solutions/en/data/1-O7JS8/?solution=1-O7JS8
GotoList = find_system(gcs,'Selected','on','BlockType','Goto');
GotoListHandle =get_param(GotoList,'Handle');


if isempty(GotoList)
    % no Goto block selected.
    return
end

for i = 1 : length(GotoListHandle)

    % get tag name
    SignalName=get_param(GotoListHandle{i},'GotoTag');

    % change name accorging to Goto Tag.
    % if you have created this block by copy&paste.
    % it's probable that block name doesn't correspond to its tag

    set_param(GotoListHandle{i},'Name',['Goto_' SignalName]);
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

    % check if corresponding From block already exist.
    FromBlockExist=find_system(gcs,'BlockType','From','GotoTag',SignalName);

    if isempty(FromBlockExist)  % Block "From" doesn't exist, create it.

        % Position:
        % Calculate "From" block position vector
        % The new block will have same dimensions of its corresponding Goto,
        % and will be placed on its right
        GotoBlockPosition=get_param(GotoListHandle{i},'Position');
        BlockLength=GotoBlockPosition(3)-GotoBlockPosition(1);
        FromBlockPosition(1)=GotoBlockPosition(3)+BlockLength/2; %Left
        FromBlockPosition(2)=GotoBlockPosition(2);%Top
        FromBlockPosition(3)=FromBlockPosition(1)+BlockLength;%Right
        FromBlockPosition(4)=GotoBlockPosition(4);%Bottom


        Path=GotoList{i}(1:max(regexp(gcb, '/'))-1);
        Destination=strcat(Path,'/','From_',SignalName);
        add_block('built-in/From',Destination,...
            'GotoTag',SignalName,...
            'position',FromBlockPosition,...
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

    else  %From block exist, change only block appearance

        for k=1:size(FromBlockExist,1)

            set_param(FromBlockExist{k},...
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

            if isempty(find_system(gcs,'Name',['From_' SignalName]))
                % in the system there is already a block with this name,
                % cannot create another one, keep the same name
                set_param(FromBlockExist{k},'Name',['From_' SignalName]);

            end


        end

    end %if


end %for


