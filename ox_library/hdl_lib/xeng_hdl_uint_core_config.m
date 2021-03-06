
function xeng_top_config(this_block)

  % Revision History:
  %
  %   31-Jan-2012  (16:35 hours):
  %     Original code was machine generated by Xilinx's System Generator after parsing
  %     /home/jack/physics_svn/gmrt_beamformer/trunk/projects/xeng_opt/hdl/iverilog_xeng/xeng_lib/xeng_top.v
  %
  %

  myname = this_block.blockName;
  this_block.setTopLevelLanguage('Verilog');

  this_block.setEntityName('xeng_top');


  serial_acc_len_bits   = str2num(get_param(myname, 'serial_acc_len_bits'  ));
  p_factor_bits         = str2num(get_param(myname, 'p_factor_bits'        ));
  bitwidth              = str2num(get_param(myname, 'bitwidth'             ));
  acc_mux_latency       = 2; %get_param(myname, 'acc_mux_latency'      );
  first_dsp_registers   = 2; %get_param(myname, 'first_dsp_registers'  );
  dsp_registers         = 2; %get_param(myname, 'dsp_registers'        );
  n_ants                = str2num(get_param(myname, 'n_ants'               ));
  bram_latency          = str2num(get_param(myname, 'bram_latency'         ));
  mcnt_width            = 48; %get_param(myname, 'mcnt_width'           );

  input_width = bitwidth*2*2*(2^p_factor_bits); %bitwidth*{r/i}*{x/y}*parallel samples
  output_width = (2*4)*((bitwidth*2+1)+p_factor_bits+serial_acc_len_bits); %r/i}*{4 stokes}*(cmult_width+bit_growth+)
  output_width_uncorr = (2*4)*((bitwidth*2+1)+p_factor_bits+serial_acc_len_bits); %r/i}*{4 stokes}*(cmult_width+bit_growth)
  
  % System Generator has to assume that your entity  has a combinational feed through; 
  %   if it  doesn't, then comment out the following line:
  %this_block.tagAsCombinational;

  this_block.addSimulinkInport('sync_in');
  this_block.addSimulinkInport('din');
  this_block.addSimulinkInport('vld');
  this_block.addSimulinkInport('mcnt');

  this_block.addSimulinkOutport('dout');
  this_block.addSimulinkOutport('dout_uncorr');
  this_block.addSimulinkOutport('sync_out');
  this_block.addSimulinkOutport('vld_out');
  this_block.addSimulinkOutport('window_vld_out');
  this_block.addSimulinkOutport('last_triangle');
  this_block.addSimulinkOutport('buf_sel_out');
  this_block.addSimulinkOutport('mcnt_out');

  sync_out_port = this_block.port('sync_out');
  sync_out_port.setType('Bool');
  sync_out_port.useHDLVector(false);

  vld_out_port = this_block.port('vld_out');
  vld_out_port.setType('Bool');
  vld_out_port.useHDLVector(false);

  window_vld_out_port = this_block.port('window_vld_out');
  window_vld_out_port.setType('Bool');
  window_vld_out_port.useHDLVector(false);

  last_triangle_port = this_block.port('last_triangle');
  last_triangle_port.setType('Bool');
  last_triangle_port.useHDLVector(false);

  buf_sel_out_port = this_block.port('buf_sel_out');
  buf_sel_out_port.setType('Bool');
  buf_sel_out_port.useHDLVector(false);

  mcnt_out_port = this_block.port('mcnt_out');
  mcnt_out_port.setType(['UFix_', num2str(mcnt_width), '_0']);
  mcnt_out_port.useHDLVector(true);

  dout_port = this_block.port('dout');
  dout_port.setType(['UFix_', num2str(output_width), '_0']);
  dout_port.useHDLVector(true);

  dout_uncorr_port = this_block.port('dout_uncorr');
  dout_uncorr_port.setType(['UFix_', num2str(output_width_uncorr), '_0']);
  dout_uncorr_port.useHDLVector(true);

  % -----------------------------
  if (this_block.inputTypesKnown)
    % do input type checking, dynamic output type and generic setup in this code block.

    if (this_block.port('sync_in').width ~= 1);
      this_block.setError('Input data type for port "sync_in" must have width=1.');
    end

    this_block.port('sync_in').useHDLVector(false);

    % (!) Port 'din' appeared to have dynamic type in the HDL -- please add type checking as appropriate;
    if (this_block.port('din').width ~= input_width);
      this_block.setError(['Input data type for port "din" must have width=', num2str(input_width), '.']);
    end

    this_block.port('din').useHDLVector(true);

    if (this_block.port('vld').width ~= 1);
      this_block.setError('Input data type for port "vld" must have width=1.');
    end

    this_block.port('vld').useHDLVector(false);

    % (!) Port 'mcnt' appeared to have dynamic type in the HDL -- please add type checking as appropriate;
    if (this_block.port('mcnt').width ~= mcnt_width);
      this_block.setError(['Input data type for port "mcnt" must have width=', num2str(mcnt_width), '.']);
    end

    this_block.port('mcnt').useHDLVector(true);
  % (!) Port 'dout' appeared to have dynamic type in the HDL
  % --- you must add an appropriate type setting for this port
  % (!) Port 'dout_uncorr' appeared to have dynamic type in the HDL
  % --- you must add an appropriate type setting for this port
  % (!) Port 'mcnt_out' appeared to have dynamic type in the HDL
  % --- you must add an appropriate type setting for this port
  end  % if(inputTypesKnown)
  % -----------------------------

  % -----------------------------
   if (this_block.inputRatesKnown)
     setup_as_single_rate(this_block,'clk','ce')
   end  % if(inputRatesKnown)
  % -----------------------------

    % (!) Set the inout port rate to be the same as the first input 
    %     rate. Change the following code if this is untrue.
    uniqueInputRates = unique(this_block.getInputRates);

  % (!) Custimize the following generic settings as appropriate. If any settings depend
  %      on input types, make the settings in the "inputTypesKnown" code block.
  %      The addGeneric function takes  3 parameters, generic name, type and constant value.
  %      Supported types are boolean, real, integer and string.
  this_block.addGeneric('SERIAL_ACC_LEN_BITS','integer', num2str(serial_acc_len_bits));
  this_block.addGeneric('P_FACTOR_BITS','integer', num2str(p_factor_bits));
  this_block.addGeneric('BITWIDTH','integer', num2str(bitwidth));
  this_block.addGeneric('ACC_MUX_LATENCY','integer', num2str(acc_mux_latency));
  this_block.addGeneric('FIRST_DSP_REGISTERS','integer', num2str(first_dsp_registers));
  this_block.addGeneric('DSP_REGISTERS','integer', num2str(dsp_registers));
  this_block.addGeneric('N_ANTS','integer', num2str(n_ants));
  this_block.addGeneric('BRAM_LATENCY','integer', num2str(bram_latency));
  this_block.addGeneric('MCNT_WIDTH','integer', num2str(mcnt_width));

  % Add addtional source files as needed.
  %  |-------------
  %  | Add files in the order in which they should be compiled.
  %  | If two files "a.vhd" and "b.vhd" contain the entities
  %  | entity_a and entity_b, and entity_a contains a
  %  | component of type entity_b, the correct sequence of
  %  | addFile() calls would be:
  %  |    this_block.addFile('b.vhd');
  %  |    this_block.addFile('a.vhd');
  %  |-------------

  %    this_block.addFile('');
  %    this_block.addFile('');
  
  %this_block.addFile('general_lib/math_func.txt');
  %this_block.addFile('xeng_lib/math_func.txt');

  %%source_root_path = '/home/jack/physics_svn/gmrt_beamformer/trunk/projects/xeng_opt/hdl/iverilog_xeng'

  %%this_block.addFile([source_root_path, '/xilinx/DSP48E.v']);

  %%this_block.addFile([source_root_path, '/general_lib/delay.v'])
  %%this_block.addFile([source_root_path, '/general_lib/posedge.v'])
  %%this_block.addFile([source_root_path, '/general_lib/negedge.v'])
  %%this_block.addFile([source_root_path, '/general_lib/window_delay.v'])
  %%this_block.addFile([source_root_path, '/general_lib/sync_delay.v'])
  %%this_block.addFile([source_root_path, '/general_lib/sample_and_hold.v'])
  %%this_block.addFile([source_root_path, '/general_lib/adder.v'])
  %%this_block.addFile([source_root_path, '/general_lib/subtractor.v'])
  %%this_block.addFile([source_root_path, '/general_lib/adder_tree.v'])
  %%this_block.addFile([source_root_path, '/general_lib/sp_ram.v'])
  %%this_block.addFile([source_root_path, '/general_lib/dp_ram.v'])
  %%this_block.addFile([source_root_path, '/general_lib/bram_delay_behave.v'])

  %%
  %%this_block.addFile([source_root_path, '/xeng_lib/stagger.v'])
  %%this_block.addFile([source_root_path, '/xeng_lib/conv_uint.v'])
  %%this_block.addFile([source_root_path, '/xeng_lib/xeng_preproc.v'])
  %%this_block.addFile([source_root_path, '/xeng_lib/acc.v'])
  %%this_block.addFile([source_root_path, '/xeng_lib/comp_vacc.v'])
  %%this_block.addFile([source_root_path, '/xeng_lib/dsp48e_uint_cmult.v'])
  %%this_block.addFile([source_root_path, '/xeng_lib/dsp48e_mac_chain.v'])
  %%this_block.addFile([source_root_path, '/xeng_lib/cmac.v'])
  %%this_block.addFile([source_root_path, '/xeng_lib/dual_pol_cmac.v'])
  %%this_block.addFile([source_root_path, '/xeng_lib/bl_order_gen.v'])
  %%this_block.addFile([source_root_path, '/xeng_lib/auto_tap.v'])
  %%this_block.addFile([source_root_path, '/xeng_lib/baseline_tap.v'])
  %%this_block.addFile([source_root_path, '/xeng_lib/component_tracker.v'])

  %%this_block.addFile([source_root_path, '/xeng_lib/xeng_top.v'])

  %this_block.addFile('xilinx/glbl.v');
  %this_block.addFile('xilinx/DSP48E.v');

  source_root_path = [getenv('MLIB_DEVEL_PATH'), '/ox_library/hdl_lib'];

  this_block.addFile([source_root_path, '/general_lib/delay.v']);
  this_block.addFile([source_root_path, '/general_lib/posedge.v']);
  this_block.addFile([source_root_path, '/general_lib/negedge.v']);
  this_block.addFile([source_root_path, '/general_lib/sync_delay.v']);
  this_block.addFile([source_root_path, '/general_lib/window_delay.v']);
  this_block.addFile([source_root_path, '/general_lib/sample_and_hold.v']);
  this_block.addFile([source_root_path, '/general_lib/adder.v']);
  this_block.addFile([source_root_path, '/general_lib/subtractor.v']);
  this_block.addFile([source_root_path, '/general_lib/adder_tree.v']);
  this_block.addFile([source_root_path, '/general_lib/sp_ram.v']);
  this_block.addFile([source_root_path, '/general_lib/sdp_ram.v']);
  this_block.addFile([source_root_path, '/general_lib/dp_ram.v']);
  this_block.addFile([source_root_path, '/general_lib/bram_delay_behave.v']);

  
  this_block.addFile([source_root_path, '/xeng_lib/stagger.v']);
  this_block.addFile([source_root_path, '/xeng_lib/conv_uint.v']);
  this_block.addFile([source_root_path, '/xeng_lib/xeng_preproc.v']);
  this_block.addFile([source_root_path, '/xeng_lib/acc.v']);
  this_block.addFile([source_root_path, '/xeng_lib/comp_vacc.v']);
  this_block.addFile([source_root_path, '/xeng_lib/dsp48e_uint_cmult.v']);
  this_block.addFile([source_root_path, '/xeng_lib/dsp48e_mac_chain.v']);
  this_block.addFile([source_root_path, '/xeng_lib/cmac.v']);
  this_block.addFile([source_root_path, '/xeng_lib/dual_pol_cmac.v']);
  this_block.addFile([source_root_path, '/xeng_lib/bl_order_gen.v']);
  this_block.addFile([source_root_path, '/xeng_lib/auto_tap.v']);
  this_block.addFile([source_root_path, '/xeng_lib/baseline_tap.v']);
  this_block.addFile([source_root_path, '/xeng_lib/component_tracker.v']);

  this_block.addFile([source_root_path, '/xeng_lib/xeng_top.v']);
return;


% ------------------------------------------------------------

function setup_as_single_rate(block,clkname,cename) 
  inputRates = block.inputRates; 
  uniqueInputRates = unique(inputRates); 
  if (length(uniqueInputRates)==1 & uniqueInputRates(1)==Inf) 
    block.addError('The inputs to this block cannot all be constant.'); 
    return; 
  end 
  if (uniqueInputRates(end) == Inf) 
     hasConstantInput = true; 
     uniqueInputRates = uniqueInputRates(1:end-1); 
  end 
  if (length(uniqueInputRates) ~= 1) 
    block.addError('The inputs to this block must run at a single rate.'); 
    return; 
  end 
  theInputRate = uniqueInputRates(1); 
  for i = 1:block.numSimulinkOutports 
     block.outport(i).setRate(theInputRate); 
  end 
  block.addClkCEPair(clkname,cename,theInputRate); 
  return; 

% ------------------------------------------------------------

