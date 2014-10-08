% Generate cos/sin
%
% cosin_init(blk, varargin)
%
% blk = The block to be configured.
% varargin = {'varname', 'value', ...} pairs
%
% Valid varnames for this block are:

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                             %
%   Karoo Array Telesope                                                      %
%   http://www.kat.ac.za                                                      %
%   Copyright (C) 2013 Andrew Martens                                         %
%                                                                             %
%   This program is free software; you can redistribute it and/or modify      %
%   it under the terms of the GNU General Public License as published by      %
%   the Free Software Foundation; either version 2 of the License, or         %
%   (at your option) any later version.                                       %
%                                                                             %
%   This program is distributed in the hope that it will be useful,           %
%   but WITHOUT ANY WARRANTY; without even the implied warranty of            %
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             %
%   GNU General Public License for more details.                              %
%                                                                             %
%   You should have received a copy of the GNU General Public License along   %
%   with this program; if not, write to the Free Software Foundation, Inc.,   %
%   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.               %
%                                                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%TODO logic for where conditions don't allow optimization 

function cosin_init(blk,varargin)

  clog('entering cosin_init',{'trace', 'cosin_init_debug'});
  check_mask_type(blk, 'cosin');

  defaults = { ...
    'output0',      'cos', ...     
    'output1',      '-sin', ...  
    'phase',        0, ...
    'fraction',     3, ... 
    'table_bits',   5, ...  
    'n_bits',       18, ...      
    'bin_pt',       17, ...    
    'bram_latency', 2, ...
    'bram',         'BRAM', ... %'BRAM' or 'distributed RAM'
    'misc',         'off', ...
  };
  if same_state(blk, 'defaults', defaults, varargin{:}), return, end
  munge_block(blk, varargin{:});

  output0       = get_var('output0', 'defaults', defaults, varargin{:});
  output1       = get_var('output1', 'defaults', defaults, varargin{:});
  phase         = get_var('phase', 'defaults', defaults, varargin{:});
  fraction      = get_var('fraction', 'defaults', defaults, varargin{:});
  table_bits    = get_var('table_bits', 'defaults', defaults, varargin{:});
  n_bits        = get_var('n_bits', 'defaults', defaults, varargin{:});
  bin_pt        = get_var('bin_pt', 'defaults', defaults, varargin{:});
  bram_latency  = get_var('bram_latency', 'defaults', defaults, varargin{:});
  bram          = get_var('bram', 'defaults', defaults, varargin{:});         
  misc          = get_var('misc', 'defaults', defaults, varargin{:});         
 
  delete_lines(blk);

  %default case for storage in the library
  if table_bits == 0,
    clean_blocks(blk);
    set_param(blk, 'AttributesFormatString', '');
    save_state(blk, 'defaults', defaults, varargin{:});
    clog('exiting cosin_vanilla_init',{'trace', 'cosin_vanilla_init_debug'});
    return;
  end %if

  %%%%%%%%%%%%%%%
  % input ports %
  %%%%%%%%%%%%%%%

  reuse_block(blk, 'theta', 'built-in/Inport', 'Port', '1', 'Position', [10 88 40 102]);

  reuse_block(blk, 'assert', 'xbsIndex_r4/Assert', ...
          'assert_type', 'on', ...
          'type_source', 'Explicitly', ...
          'arith_type', 'Unsigned', ...
          'n_bits', num2str(table_bits), 'bin_pt', '0', ...
          'Position', [70 85 115 105]);
  add_line(blk, 'theta/1', 'assert/1');

  if strcmp(misc, 'on'),
    reuse_block(blk, 'misci', 'built-in/Inport', 'Port', '2', 'Position', [10 238 40 252]);
  else
    reuse_block(blk, 'misci', 'xbsIndex_r4/Constant', ...
            'const', '0', 'n_bits', '1', 'arith_type', 'Unsigned', ...
            'bin_pt', '0', 'explicit_period', 'on', 'period', '1', ...
            'Position', [10 238 40 252]);
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % address manipulation logic %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  full_cycle_bits = table_bits + fraction;
  store = fraction;


  %determine optimal lookup functions if not packed
  lookup0 = output0; lookup1 = output1; %not sharing values so store as specified

  %lookup size depends on fraction of cycle stored
  lookup_bits = full_cycle_bits - fraction;

  address_bits = table_bits;
  %draw_basic_partial_cycle(blk, full_cycle_bits, address_bits, lookup_bits, output0, output1, lookup0, lookup1);
  
  %%%%%%%%%%%%%%%%  
  % output ports %
  %%%%%%%%%%%%%%%%  
  
  reuse_block(blk, output0, 'built-in/Outport', ...
          'Port', '1', ...
          'Position', [875 88 905 102]);

  reuse_block(blk, output1, 'built-in/Outport', ...
          'Port', '2', ...
          'Position', [875 168 905 182]);

  if strcmp(misc, 'on'),
    reuse_block(blk, 'misco', 'built-in/Outport', ...
            'Port', '3', ...
            'Position', [875 198 905 212]);
  else,
    reuse_block(blk, 'misco', 'built-in/Terminator', 'Position', [875 198 905 212]);
  end
  
  %%%%%%%%%%%%%
  % ROM setup %
  %%%%%%%%%%%%%

  %determine memory implementation
  if strcmp(bram, 'BRAM'),
    distributed_mem = 'Block RAM';
  elseif strcmp(bram, 'distributed RAM'),
    distributed_mem = 'Distributed memory';
  else,
    %TODO
  end

  vec_len = 2^lookup_bits;
  
  initVector = [lookup0,'((',num2str(phase),'*(2*pi))+(2*pi)/(2^',num2str(full_cycle_bits),')*(0:(2^',num2str(lookup_bits),')-1))'];

  %pack two outputs into the same word from ROM

  
  %lookup ROM
  reuse_block(blk, 'ROM', 'xbsIndex_r4/ROM', ...
          'depth', ['2^(',num2str(lookup_bits),')'], ...
          'latency', 'bram_latency', ...
          'arith_type', 'Unsigned', ...
          'n_bits', 'n_bits*2', ...
          'bin_pt', '0', ...
          'optimize', 'Speed', ...
          'distributed_mem', distributed_mem, ...
          'Position', [435 150 490 300]);
  add_line(blk,'assert/1', 'ROM/1');

  %calculate values to be stored in ROM
  real_vals = gen_vals(output0, phase, full_cycle_bits, vec_len, n_bits, bin_pt);

  imag_vals = gen_vals(output1, phase, full_cycle_bits, vec_len, n_bits, bin_pt);
  
  vals = doubles2unsigned([real_vals',imag_vals'], n_bits, bin_pt, n_bits*2);

  set_param([blk,'/ROM'], 'initVector', mat2str(vals'));

  %extract real and imaginary parts of vector
  reuse_block(blk, 'c_to_ri', 'casper_library_misc/c_to_ri', ...
    'n_bits', 'n_bits', 'bin_pt', 'bin_pt', ...
    'Position', [510 204 550 246]);
  add_line(blk,'ROM/1','c_to_ri/1');
  add_line(blk,'c_to_ri/1',[output0 '/1']);
  add_line(blk,'c_to_ri/2',[output1 '/1']);


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % delays for negate outputs from address manipulation block % 
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  reuse_block(blk, 'Delay', 'xbsIndex_r4/Delay', ...
          'latency', 'bram_latency', ...
          'reg_retiming', 'on', ...
          'Position', [450 116 480 134]);
  add_line(blk,'misci/1','Delay/1');
  add_line(blk, 'Delay/1', 'misco/1');





  %%%%%%%%%%%%%%%%%%%%%  
  % final cleaning up %
  %%%%%%%%%%%%%%%%%%%%%  

  clean_blocks(blk);

  fmtstr = sprintf('');
  set_param(blk, 'AttributesFormatString', fmtstr);
  %ensure that parameters we have forced reflect in mask parameters (ensure this matches varargin
  %passed by block so that hash in same_state can be compared)
  args = { ...
    'output0', output0, 'output1', output1, 'phase', phase, 'fraction', fraction, ...
    'table_bits', table_bits, 'n_bits', n_bits, 'bin_pt', bin_pt, 'bram_latency', bram_latency, ...
    'bram', bram, 'misc', misc};
  save_state(blk, 'defaults', defaults, args{:});
  clog('exiting cosin_vanilla_init',{'trace', 'cosin_vanilla_init_debug'});

end %cosin_init


function[vals] = gen_vals(func, phase, table_bits, subset, n_bits, bin_pt),
    %calculate init vector
    if strcmp(func, 'sin'),
        vals = sin((phase*(2*pi))+[0:subset-1]*pi*2/(2^table_bits));
    elseif strcmp(func, 'cos'),
        vals = cos((phase*(2*pi))+[0:subset-1]*pi*2/(2^table_bits));
    elseif strcmp(func, '-sin'),
        vals = -sin((phase*(2*pi))+[0:subset-1]*pi*2/(2^table_bits));
    elseif strcmp(func, '-cos'),
        vals = -cos((phase*(2*pi))+[0:subset-1]*pi*2/(2^table_bits));
    end %if strcmp(func)
%    vals = fi(vals, true, n_bits, bin_pt); %saturates at max so no overflow
%    vals = fi(vals, false, n_bits, bin_pt, 'OverflowMode', 'wrap'); %wraps negative component so can get back when positive

end %gen_vals


