`ifndef RISC_SEQUENCER_SV
`define RISC_SEQUENCER_SV

class risc_sequencer extends uvm_sequencer #(risc_item);
  `uvm_component_utils(risc_sequencer)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

endclass

`endif
