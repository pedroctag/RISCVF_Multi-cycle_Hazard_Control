module tb_top;
  
  // Importa bibliotecas UVM e o seu pacote de verificação
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  
  // Se você criou um arquivo package (risc_pkg.sv), descomente abaixo:
  import risc_pkg::*; 
  
  // Se não criou package, inclua os arquivos aqui (ordem importa!):
  // `include "risc_if.sv"
  // `include "risc_item.sv" ... etc ...
  
  // Sinais de Clock e Reset
  logic clk;
  logic rst;

  // -----------------------------------------------------------
  // 1. Instancia a Interface
  // -----------------------------------------------------------
  risc_if dut_if(clk, rst);

  // -----------------------------------------------------------
  // 2. Instancia o Design (DUT)
  // -----------------------------------------------------------
  // Note que conectamos 'we' e 'in' na interface para garantir
  // que fiquem em 0 durante a simulação (já que usamos backdoor).
  topo dut (
      .clk (clk),
      .rst (rst),
      .we  (dut_if.we),       // Input controlado pelo Driver (mantido em 0)
      .in  (dut_if.data_in),  // Input controlado pelo Driver (mantido em 0)
      .out (dut_if.result_out)// Output monitorado pela Interface
  );

  // -----------------------------------------------------------
  // 3. Geração de Clock (Ex: 10ns -> 100MHz)
  // -----------------------------------------------------------
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // -----------------------------------------------------------
  // 4. Geração de Reset Inicial
  // -----------------------------------------------------------
  initial begin
    // Reset ativo alto (conforme seu InstructionFetch: .rst(rst))
    // Verifique se seu reset é 0 ou 1. Assumindo Ativo Alto (1) baseado no seu código.
    rst = 1; 
    
    // Segura o reset por um tempo enquanto o UVM configura o ambiente
    #50;
    
    // O Driver vai carregar a memória via Backdoor no tempo 0 da run_phase.
    // É seguro soltar o reset depois.
    rst = 0;
  end

  // -----------------------------------------------------------
  // 5. Configuração e Start do UVM
  // -----------------------------------------------------------
  initial begin
    // Passa a interface virtual para o banco de dados de configuração
    // O "*" significa que qualquer componente abaixo de 'uvm_test_top' pode ver.
    uvm_config_db#(virtual risc_if)::set(null, "*", "vif", dut_if);
    
    // Para gerar ondas no SimVision/Xcelium
    $shm_open("waves.shm");
    $shm_probe("AC"); // Grava tudo (Analog e Digital)
    
    // Inicia o teste especificado (nome da classe string)
    run_test("risc_test");
  end

endmodule
