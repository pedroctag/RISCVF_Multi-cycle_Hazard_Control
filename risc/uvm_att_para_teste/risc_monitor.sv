`ifndef RISC_MONITOR_SV
`define RISC_MONITOR_SV

class risc_monitor extends uvm_monitor;
  `uvm_component_utils(risc_monitor)

  virtual risc_if vif;
  uvm_analysis_port #(risc_item) mon_analysis_port;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    mon_analysis_port = new("mon_analysis_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual risc_if)::get(this, "", "vif", vif))
      `uvm_fatal("MON", "Virtual interface nao encontrada")
  endfunction

  task run_phase(uvm_phase phase);
    // Variável para ler o sinal interno do DUT
    logic reg_write_val;
    risc_item item;

    // Aguarda reset inicial
    @(negedge vif.rst);

    forever begin
      @(posedge vif.clk);

      // CORREÇÃO: Leitura de sinal interno via String (Backdoor UVM)
      // Substitui: if (tb_top.dut.RegWrite_MEMWB === 1'b1)
      if (uvm_hdl_read("tb_top.dut.RegWrite_MEMWB", reg_write_val)) begin
          
          // Se conseguiu ler o sinal E ele for 1, captura a saída
          if (reg_write_val === 1'b1) begin
             capture_transaction();
          end
      
      end else begin
          // Se falhar em ler o caminho, avisa (opcional, pode ser flood de log)
          // `uvm_warning("MON", "Nao foi possivel ler sinal RegWrite_MEMWB via backdoor")
      end
    end
  endtask

  task capture_transaction();
    risc_item item_captured;
    item_captured = risc_item::type_id::create("item_captured");
    
    // Captura o pino de saída 'out' da interface
    item_captured.result = vif.result_out;
    
    `uvm_info("MON", $sformatf("Resultado capturado: 0x%0h", item_captured.result), UVM_HIGH)
    mon_analysis_port.write(item_captured);
  endtask

endclass

`endif
