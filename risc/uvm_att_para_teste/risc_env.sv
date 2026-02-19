`ifndef RISC_ENV_SV
`define RISC_ENV_SV

class risc_env extends uvm_env;
  `uvm_component_utils(risc_env)

  risc_agent agent;
  risc_scoreboard scoreboard;
  
  // 1. Declaração
  risc_coverage coverage_collector;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = risc_agent::type_id::create("agent", this);
    scoreboard = risc_scoreboard::type_id::create("scoreboard", this);
    
    // 2. Construção
    coverage_collector = risc_coverage::type_id::create("coverage_collector", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    // Liga Driver -> Scoreboard
    agent.driver.driver_analysis_port.connect(scoreboard.driver_port);
    
    // Liga Monitor -> Scoreboard
    agent.monitor.mon_analysis_port.connect(scoreboard.monitor_port);

    // 3. CONEXÃO IMPORTANTE:
    // O coverage deve escutar o que o Monitor vê (resultados)
    // OU o que o Driver envia (estímulos).
    // Geralmente ligamos no Monitor, mas como seu Monitor foca no output e 
    // o coverage quer ver a instrução, podemos ligar no Driver temporariamente:
    
    agent.driver.driver_analysis_port.connect(coverage_collector.analysis_export);
  endfunction

endclass

`endif
