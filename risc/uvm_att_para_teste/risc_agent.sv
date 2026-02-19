`ifndef RISC_AGENT_SV
`define RISC_AGENT_SV

class risc_agent extends uvm_agent;
  `uvm_component_utils(risc_agent)

  // ----------------------------------------------------------------
  // Componentes do Agente
  // ----------------------------------------------------------------
  risc_sequencer sequencer;
  risc_driver    driver;
  risc_monitor   monitor; // Precisaremos definir este em breve

  // ----------------------------------------------------------------
  // Porta de Análise (Saída do Agente)
  // ----------------------------------------------------------------
  // Esta porta serve para "retransmitir" o que o Monitor viu para o Scoreboard.
  // O Environment vai conectar esta porta na entrada do Scoreboard.
  uvm_analysis_port #(risc_item) agent_analysis_port;

  // ----------------------------------------------------------------
  // Construtor
  // ----------------------------------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  // ----------------------------------------------------------------
  // Build Phase
  // ----------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // 1. Inicializa a porta de saída
    agent_analysis_port = new("agent_analysis_port", this);

    // 2. O Monitor é passivo, ele sempre existe
    monitor = risc_monitor::type_id::create("monitor", this);

    // 3. Verifica se o Agente é ATIVO (UVM_ACTIVE)
    // Se for PASSIVE (apenas escutando), não criamos driver nem sequencer.
    if (get_is_active() == UVM_ACTIVE) begin
      sequencer = risc_sequencer::type_id::create("sequencer", this);
      driver    = risc_driver::type_id::create("driver", this);
    end
  endfunction

  // ----------------------------------------------------------------
  // Connect Phase
  // ----------------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // 1. Conecta a porta interna do monitor com a porta externa do agente
    // Assumindo que o monitor terá uma porta chamada 'mon_analysis_port'
    monitor.mon_analysis_port.connect(agent_analysis_port);

    // 2. Se for Ativo, conecta o Sequencer ao Driver
    // O Driver puxa itens do Sequencer através dessa conexão
    if (get_is_active() == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
  endfunction

endclass

`endif
