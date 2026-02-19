`ifndef RISC_TEST_SV
`define RISC_TEST_SV

class risc_test extends uvm_test;
  `uvm_component_utils(risc_test)

  risc_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = risc_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    risc_random_seq seq; 
    phase.raise_objection(this);
    
    // Opcional: imprimir topologia para garantir que tudo está conectado
    // uvm_top.print_topology();

    seq = risc_random_seq::type_id::create("seq");
    `uvm_info("TEST", "Iniciando SEQUENCE ALEATORIA...", UVM_LOW)
    
    // Roda a sequência 5 vezes para gerar bastante dados para o coverage
    repeat(5) begin
        seq.start(env.agent.sequencer);
    end
    
    #5000;
    `uvm_info("TEST", "Sequences Finalizadas.", UVM_LOW)
    
    phase.drop_objection(this);
  endtask

  // -------------------------------------------------------
  // REPORT PHASE: Aqui imprimimos o resultado no terminal
  // -------------------------------------------------------
  function void report_phase(uvm_phase phase);
    real cov_result;
    
    super.report_phase(phase);

// Isso pede a cobertura acumulada desse covergroup (funciona melhor)
cov_result = env.coverage_collector.cg_risc.get_coverage();

    `uvm_info("COV_REPORT", $sformatf("--------------------------------------------------"), UVM_NONE)
    `uvm_info("COV_REPORT", $sformatf(" COBERTURA FUNCIONAL ATINGIDA: %0.2f%% ", cov_result), UVM_NONE)
    `uvm_info("COV_REPORT", $sformatf("--------------------------------------------------"), UVM_NONE)

    if (cov_result < 100.0)
        `uvm_info("COV_REPORT", "Ainda faltam cenarios para cobrir 100%!", UVM_NONE)
    else
        `uvm_info("COV_REPORT", "Parabens! Cobertura Completa!", UVM_NONE)

  endfunction

endclass

`endif
