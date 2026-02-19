`ifndef RISC_SEQUENCE_SV
`define RISC_SEQUENCE_SV

// ----------------------------------------------------------------
// Sequence Simples (A antiga, pode manter aqui se quiser)
// ----------------------------------------------------------------
class risc_simple_seq extends uvm_sequence #(risc_item);
  `uvm_object_utils(risc_simple_seq)
  function new(string name = "risc_simple_seq"); super.new(name); endfunction
  task body();
     // ... (código antigo) ...
  endtask
endclass

// ----------------------------------------------------------------
// NOVA SEQUENCE: Leitura de Arquivo
// ----------------------------------------------------------------
class risc_file_seq extends uvm_sequence #(risc_item);
  `uvm_object_utils(risc_file_seq)

  string filename = "instructions.txt"; // Nome do arquivo

  function new(string name = "risc_file_seq");
    super.new(name);
  endfunction

  task body();
    risc_item req;
    int fd;
    int code;
    bit [31:0] temp_inst;
    bit [31:0] queue_inst[$]; // Fila temporária para guardar leitura

    req = risc_item::type_id::create("req");

    // 1. Abre o arquivo para leitura ("r")
    fd = $fopen(filename, "r");
    if (fd == 0) begin
      `uvm_fatal("SEQ", $sformatf("Nao foi possivel abrir o arquivo: %s. Verifique se ele esta na pasta de simulacao!", filename))
    end

    `uvm_info("SEQ", $sformatf("Lendo instrucoes do arquivo: %s", filename), UVM_LOW)

    // 2. Lê linha por linha (formato Hexadecimal %h)
    while ($fscanf(fd, "%h", temp_inst) == 1) begin
      queue_inst.push_back(temp_inst);
    end
    $fclose(fd);

    `uvm_info("SEQ", $sformatf("Total de instrucoes lidas: %0d", queue_inst.size()), UVM_LOW)

    // 3. Inicia a transação
    start_item(req);

    // 4. Copia da fila para o array dinâmico do item
    req.program_payload = new[queue_inst.size()];
    foreach(queue_inst[i]) begin
      req.program_payload[i] = queue_inst[i];
    end

    finish_item(req);
  endtask

endclass

class risc_random_seq extends uvm_sequence #(risc_item);
  `uvm_object_utils(risc_random_seq)

  function new(string name = "risc_random_seq");
    super.new(name);
  endfunction

  task body();
    risc_item req;
    
    // Variáveis temporárias para construir a instrução
    bit [6:0] opcode;
    bit [4:0] rd, rs1, rs2;
    bit [2:0] funct3;
    bit [6:0] funct7;
    bit [11:0] imm;
    bit [31:0] inst_montada;
    
    // Tipo de operação (0=ADD, 1=SUB, 2=ADDI, 3=AND, etc...)
    int op_type; 

    req = risc_item::type_id::create("req");
    start_item(req);

    // Vamos gerar um programa de 20 instruções aleatórias
    req.program_payload = new[20];

    for (int i = 0; i < 20; i++) begin
      
      // 1. Aleatoriza operandos
      rd  = $urandom_range(1, 31); // Evita x0 (que é sempre 0) para destino
      rs1 = $urandom_range(0, 31);
      rs2 = $urandom_range(0, 31);
      imm = $urandom_range(0, 4095); // 12 bits
      
      // 2. Escolhe um tipo de instrução aleatória
      op_type = $urandom_range(0, 3); 

      case (op_type)
        // ------------------------------------------------
        // TYPE R: ADD (Soma de Registradores)
        // Formato: {funct7, rs2, rs1, funct3, rd, opcode}
        // ------------------------------------------------
        0: begin 
           opcode = 7'b0110011; 
           funct3 = 3'b000; 
           funct7 = 7'b0000000;
           inst_montada = {funct7, rs2, rs1, funct3, rd, opcode};
        end

        // ------------------------------------------------
        // TYPE R: SUB (Subtração)
        // ------------------------------------------------
        1: begin 
           opcode = 7'b0110011; 
           funct3 = 3'b000; 
           funct7 = 7'b0100000; // Bit 30 define SUB
           inst_montada = {funct7, rs2, rs1, funct3, rd, opcode};
        end

        // ------------------------------------------------
        // TYPE I: ADDI (Soma com Imediato)
        // Formato: {imm, rs1, funct3, rd, opcode}
        // ------------------------------------------------
        2: begin 
           opcode = 7'b0010011; 
           funct3 = 3'b000;
           inst_montada = {imm, rs1, funct3, rd, opcode};
        end
        
        // ------------------------------------------------
        // TYPE R: AND (E Lógico)
        // ------------------------------------------------
        3: begin 
           opcode = 7'b0110011; 
           funct3 = 3'b111; 
           funct7 = 7'b0000000;
           inst_montada = {funct7, rs2, rs1, funct3, rd, opcode};
        end
      endcase

      // Guarda a instrução montada no pacote
      req.program_payload[i] = inst_montada;
      
      `uvm_info("RND_SEQ", $sformatf("Gerada Inst[%0d]: 0x%h (Tipo: %0d)", i, inst_montada, op_type), UVM_HIGH)
    end

    finish_item(req);
  endtask

endclass

`endif
