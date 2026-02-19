`ifndef RISC_COVERAGE_SV
`define RISC_COVERAGE_SV

class risc_coverage extends uvm_subscriber #(risc_item);
  `uvm_component_utils(risc_coverage)

  // Variáveis locais para amostragem
  bit [6:0] cur_opcode;
  bit [4:0] cur_rd;

  // -------------------------------------------------------
  // COVERGROUP
  // -------------------------------------------------------
  covergroup cg_risc;
    option.per_instance = 1; // Permite ver cobertura desta instância específica
    option.name = "cg_risc_instuctions";

    // Coverpoint para Opcode
    cp_opcode: coverpoint cur_opcode {
        bins R_TYPE = {7'b0110011}; // ADD, SUB, etc
        bins I_TYPE = {7'b0010011}; // ADDI
        bins STORE  = {7'b0100011}; // SW
        bins LOAD   = {7'b0000011}; // LW
        bins BRANCH = {7'b1100011}; // BEQ
        // Adicione outros opcodes aqui...
    }

    // Coverpoint para Registrador de Destino
    cp_rd: coverpoint cur_rd {
        bins zero = {0};
        bins others[] = {[1:31]};
    }

    // Cruzamento: Estamos testando R-Types em todos os registradores?
    cross_opcode_rd: cross cp_opcode, cp_rd;

  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    // Instancia o covergroup na construção da classe
    cg_risc = new();
  endfunction

  // -------------------------------------------------------
  // FUNÇÃO WRITE (Chamada automática pelo Driver/Monitor)
  // -------------------------------------------------------
function void write(risc_item t);
    // DEBUG: Confirma se chegou aqui
    `uvm_info("COV_DEBUG", $sformatf("Amostrando instrucao..."), UVM_HIGH)

    foreach(t.program_payload[i]) begin
        bit [31:0] inst = t.program_payload[i];
        
        cur_opcode = inst[6:0];
        cur_rd     = inst[11:7];
        
        cg_risc.sample();
    end
  endfunction

endclass

`endif
