module forwarding_control (
    // Entradas: informações dos estágios do pipeline
    input wire RegWrite_EXMEM,   // Hab. escrita no EX/MEM
    input wire RegWrite_MEMWB,   // Hab. escrita no MEM/WB
    input wire [4:0] rd_EXMEM,   // Reg. destino no EX/MEM
    input wire [4:0] rd_MEMWB,   // Reg. destino no MEM/WB
    input wire [4:0] rs1_IDEX,   // Reg. fonte 1 no ID/EX
    input wire [4:0] rs2_IDEX,   // Reg. fonte 2 no ID/EX

    // Saídas: seletores de mux para operandos
    output reg [1:0] operand_a_sel, // Seletor para op.A
    output reg [1:0] operand_b_sel  // Seletor para op.B
);

    // --------------------------------------------------
    // Codificação dos seletores:
    // 2'b00 -> Dado do register file (sem forwarding)
    // 2'b01 -> Dado do estágio EX/MEM
    // 2'b10 -> Dado do estágio MEM/WB
    // --------------------------------------------------

    always @(*) begin
        // Valores padrão
        operand_a_sel = 2'b00;
        operand_b_sel = 2'b00;

        // Forwarding para rs1 (operando A)
        if (RegWrite_EXMEM && rd_EXMEM != 0 && rd_EXMEM == rs1_IDEX)
            operand_a_sel = 2'b10; // do EX/MEM
        else if (RegWrite_MEMWB && rd_MEMWB != 0 && rd_MEMWB == rs1_IDEX)
            operand_a_sel = 2'b00; // do MEM/WB

        // Forwarding para rs2 (operando B)
        if (RegWrite_EXMEM && rd_EXMEM != 0 && rd_EXMEM == rs2_IDEX)
            operand_b_sel = 2'b10; // do EX/MEM
        else if (RegWrite_MEMWB && rd_MEMWB != 0 && rd_MEMWB == rs2_IDEX)
            operand_b_sel = 2'b00; // do MEM/WB
    end

endmodule
