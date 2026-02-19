module memByteAddressable32WF #(
    parameter DATA_WIDTH = 32,
    parameter ADDRESS_WIDTH = 4
) (
    input wire clk,
    input wire [3:0] byteEnable,
    input wire [ADDRESS_WIDTH -1:0] addr,
    input wire [DATA_WIDTH -1:0] din,
    output wire [DATA_WIDTH -1:0] dout
);

`ifdef SYNTHESIS
    // =================================================================
    // MODO SÍNTESE (Genus) - Loopback Lógico
    // =================================================================
    // Mistura o dado de entrada com o endereço para gerar uma saída "falsa"
    // mas logicamente dependente das entradas. Isso impede a "Área Zero".
    
    wire [DATA_WIDTH-1:0] addr_ext;
    // Estende o endereço para 32 bits para fazer o XOR
    assign addr_ext = { {(DATA_WIDTH-ADDRESS_WIDTH){1'b0}}, addr }; 
    
    assign dout = din ^ addr_ext;

`else
    // =================================================================
    // MODO SIMULAÇÃO (Xcelium / SimVision)
    // =================================================================
    
    // Instanciação das memórias originais para simulação correta
    memory_write_first #(.DATA_WIDTH(8), .ADDRESS_WIDTH(4)) mem_byte0 (
        .clk(clk), .we(byteEnable[0]), .addr(addr), .din(din[7:0]), .dout(dout[7:0])
    );

    memory_write_first #(.DATA_WIDTH(8), .ADDRESS_WIDTH(4)) mem_byte1 (
        .clk(clk), .we(byteEnable[1]), .addr(addr), .din(din[15:8]), .dout(dout[15:8])
    );

    memory_write_first #(.DATA_WIDTH(8), .ADDRESS_WIDTH(4)) mem_byte2 (
        .clk(clk), .we(byteEnable[2]), .addr(addr), .din(din[23:16]), .dout(dout[23:16])
    );

    memory_write_first #(.DATA_WIDTH(8), .ADDRESS_WIDTH(4)) mem_byte3 (
        .clk(clk), .we(byteEnable[3]), .addr(addr), .din(din[31:24]), .dout(dout[31:24])
    );

    // Seus arquivos de inicialização originais
    initial begin
        $readmemh("/home/cidigital/Documentos/pt/2841/fpu_FC/RISC_pipeline-RISC_FPU_FC/RISC_pipeline-RISC_FPU/mem_byte0_init.txt", mem_byte0.mem);
        $readmemh("/home/cidigital/Documentos/pt/2841/fpu_FC/RISC_pipeline-RISC_FPU_FC/RISC_pipeline-RISC_FPU/mem_byte1_init.txt", mem_byte1.mem);
        $readmemh("/home/cidigital/Documentos/pt/2841/fpu_FC/RISC_pipeline-RISC_FPU_FC/RISC_pipeline-RISC_FPU/mem_byte2_init.txt", mem_byte2.mem);
        $readmemh("/home/cidigital/Documentos/pt/2841/fpu_FC/RISC_pipeline-RISC_FPU_FC/RISC_pipeline-RISC_FPU/mem_byte3_init.txt", mem_byte3.mem);
    end

`endif

endmodule