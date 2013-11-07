function sl_customization(cm)
%--------------------------------------------------------------------------
% Description : sl_customization function used to register context menu
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
%-------------------------------------------------------------------------

  %% Register custom menu function.
  cm.addCustomMenuFcn('Simulink:PreContextMenu', @getMyMenuItems);
end

%% Define the custom menu function.
function schemaFcns = getMyMenuItems(callbackInfo) 
  schemaFcns = {@userFunctions}; 
end

%% Define the schema function for first menu item.
function schema = userFunctions(callbackInfo)
  % Make a submenu label    
  schema = sl_container_schema;
  schema.label = 'CASPER helpers';     
  schema.childrenFcns = {@userFunction1, @userFunction2, @userFunction3};
end 

function schema = userFunction1(callbackInfo)
  schema = sl_action_schema;
  schema.label = 'Create From Blocks';
  schema.callback = @sl_from2goto; 
end 

function schema = userFunction2(callbackInfo)
  schema = sl_action_schema;
  schema.label = 'Goto++ (copy and reindex)';
  schema.callback = @sl_goto_reindex; 
end 

function schema = userFunction3(callbackInfo)
  schema = sl_action_schema;
  schema.label = 'Goto Tag: Increment in place';
  schema.callback = @sl_goto_increment_inplace; 
end 

% if you'd like to add more user functions duplicate 'userFunction1'
% structure.

