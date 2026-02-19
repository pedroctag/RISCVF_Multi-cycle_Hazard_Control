class risc_item extends uvm_sequence_item;
  
  // Payload enviado pelo Driver (O programa todo)
  rand bit [31:0] program_payload[];

  // ---------------------------------------------
  // Campo NOVO: Resultado capturado pelo Monitor
  // ---------------------------------------------
  bit [31:0] result; 

  `uvm_object_utils_begin(risc_item)
      `uvm_field_array_int(program_payload, UVM_DEFAULT)
      `uvm_field_int(result, UVM_DEFAULT)
  `uvm_object_utils_end

  function new(string name = "risc_item");
    super.new(name);
  endfunction
  
  // constraint ...
endclass
