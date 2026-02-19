module instruction_memory (
    input [31:0] A, in, addr,       // Endereço
    input clk, we,
    output [31:0] RD         // Saída
);

//`ifdef SYNTHESIS
    // =================================================================
    // MODO SÍNTESE (Genus) - Loopback Inteligente
    // =================================================================
    // O problema anterior: RD = A gerava instrução 0x0, que desligava o controle.
    // Nova solução: Pegamos o Endereço (A) mas FORÇAMOS os 7 bits finais
    // para serem 0110011 (0x33), que é o opcode de instruções R-Type (ADD, SUB, etc).
    // Assim, o Control Unit vai achar que é uma instrução válida e ativar o RegWrite.
    // O processador vai ficar "vivo".
    
    //assign RD = A | 32'h00000033; 

//`else
    // =================================================================
    // MODO SIMULAÇÃO
    // =================================================================
    reg [31:0] instruction [0:63]; 
    wire [29:0] aux;
    assign aux = A[31:2]; 

    always @(posedge clk)
    begin
        if (we)
            instruction[addr] <= in;
    end

    initial begin 
        $readmemh("/home/cidigital/Documentos/pt/risc/RTL/instructions.txt", instruction); 
    end

    assign RD = instruction[aux];
//endif

endmodule
