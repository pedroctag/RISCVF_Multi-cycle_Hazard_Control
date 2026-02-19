`ifndef RISC_DRIVER_SV
`define RISC_DRIVER_SV

class risc_driver extends uvm_driver #(risc_item);
  `uvm_component_utils(risc_driver)

  virtual risc_if vif;
  uvm_analysis_port #(risc_item) driver_analysis_port;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    driver_analysis_port = new("driver_analysis_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual risc_if)::get(this, "", "vif", vif))
      `uvm_fatal("DRV", "Virtual Interface nao encontrada")
  endfunction

  task run_phase(uvm_phase phase);
    risc_item req;

    // Garante que os sinais do driver iniciem em 0
    vif.we <= 0;
    vif.data_in <= 0;

    // Aguarda o Reset do tb_top ser liberado (espera o rst cair para 0)
    wait(vif.rst === 0);
    @(posedge vif.clk);

    forever begin
      seq_item_port.get_next_item(req);
      void'(req.begin_tr());
      
      // 1. Envia para Scoreboard
      driver_analysis_port.write(req);

      // 2. Carrega memória via Backdoor
      load_program_backdoor(req);
      
      // 3. Aguarda execução
      // Removido drive_reset() pois o tb_top controla o reset global
      repeat(100) @(posedge vif.clk);

      req.end_tr();
      seq_item_port.item_done();
    end
  endtask

  task load_program_backdoor(risc_item req);
    string path;
    `uvm_info("DRV", $sformatf("Carregando %0d instrucoes via Backdoor...", req.program_payload.size()), UVM_LOW)

    foreach(req.program_payload[i]) begin
      path = $sformatf("tb_top.dut.IF.IMemory.instruction[%0d]", i);
      if (!uvm_hdl_deposit(path, req.program_payload[i])) begin
        `uvm_fatal("DRV", {"Nao foi possivel escrever no caminho backdoor: ", path})
      end
    end
  endtask

endclass

`endif
