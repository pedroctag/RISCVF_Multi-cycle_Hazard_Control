`ifndef RISC_SCOREBOARD_SV
`define RISC_SCOREBOARD_SV

// Macros de portas
`uvm_analysis_imp_decl(_from_driver)
`uvm_analysis_imp_decl(_from_monitor)

class risc_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(risc_scoreboard)

  // Portas
  uvm_analysis_imp_from_driver #(risc_item, risc_scoreboard) driver_port;
  uvm_analysis_imp_from_monitor #(risc_item, risc_scoreboard) monitor_port;

  // Memória interna do modelo
  bit [31:0] shadow_regs[32];
  bit [31:0] expected_queue[$];
  
  // CORREÇÃO 1: 'matches' é palavra reservada. Usamos num_matches.
  int num_matches = 0;
  int num_mismatches = 0;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    driver_port = new("driver_port", this);
    monitor_port = new("monitor_port", this);
    shadow_regs[0] = 0;
  endfunction

  // Recebe do Driver
  function void write_from_driver(risc_item req);
    `uvm_info("SCB", $sformatf("Recebido programa com %0d instrucoes", req.program_payload.size()), UVM_LOW)
    // Passa o payload para o modelo
    run_reference_model(req.program_payload);
  endfunction

  // Recebe do Monitor
  function void write_from_monitor(risc_item item);
    bit [31:0] expected;
    
    // Ignora checks se a fila estiver vazia (início da simulação)
    if (expected_queue.size() == 0) return;

    expected = expected_queue.pop_front();

    if (item.result == expected) begin
      `uvm_info("SCB", $sformatf("MATCH! Exp: %0h | Real: %0h", expected, item.result), UVM_MEDIUM)
      num_matches++; 
    end else begin
      `uvm_error("SCB", $sformatf("MISMATCH! Exp: %0h | Real: %0h", expected, item.result))
      num_mismatches++;
    end
  endfunction

  // Report Final
  function void report_phase(uvm_phase phase);
    `uvm_info("SCB", $sformatf("REPORT FINAL: Matches=%0d | Mismatches=%0d", num_matches, num_mismatches), UVM_LOW)
  endfunction

  // Modelo de Referência
  // CORREÇÃO 2: 'program' é palavra reservada. Renomeado para 'prog_verif'.
  function void run_reference_model(bit [31:0] prog_verif[]);
    bit [6:0] opcode;
    bit [4:0] rd, rs1, rs2;
    bit [2:0] funct3;
    bit [6:0] funct7;
    bit [31:0] val1, val2, res;

    // Zera registradores antes de rodar
    foreach(shadow_regs[i]) shadow_regs[i] = 0;

    // Loop usando o novo nome do array
    foreach(prog_verif[i]) begin
      bit [31:0] inst = prog_verif[i];
      
      opcode = inst[6:0];
      rd     = inst[11:7];
      funct3 = inst[14:12];
      rs1    = inst[19:15];
      rs2    = inst[24:20];
      funct7 = inst[31:25];

      val1 = shadow_regs[rs1];
      val2 = shadow_regs[rs2];
      res  = 0;

      // Início do Case Opcode
      case (opcode)
        // R-Type
        7'b0110011: begin 
            case(funct3)
                3'b000: res = (funct7[5]) ? (val1 - val2) : (val1 + val2);
                3'b111: res = val1 & val2;
                3'b110: res = val1 | val2;
                default: res = 0;
            endcase
            
            if (rd != 0) begin
                shadow_regs[rd] = res;
                expected_queue.push_back(res);
            end
        end

        // I-Type (ADDI)
        7'b0010011: begin
            bit [11:0] imm = inst[31:20];
            // Extensão de sinal manual
            bit [31:0] imm_ext = {{20{imm[11]}}, imm};
            
            if (funct3 == 3'b000) res = val1 + imm_ext;
            
            if (rd != 0) begin
                shadow_regs[rd] = res;
                expected_queue.push_back(res);
            end
        end
      endcase // Fim do Case Opcode
    end
  endfunction

endclass

`endif
