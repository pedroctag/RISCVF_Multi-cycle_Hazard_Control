interface risc_if(input logic clk, input logic rst);
    
    // Sinais para "silenciar" as entradas não usadas do Topo
    logic        we;
    logic [31:0] data_in; // Ligado ao 'in' do topo
    
    // Sinal de monitoramento (Resultado do Writeback)
    logic [31:0] result_out; // Ligado ao 'out' do topo

endinterface
