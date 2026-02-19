###############################################################
## Configuração Geral (Bibliotecas)
###############################################################

# Defina aqui os caminhos das suas pastas
set_db init_lib_search_path ../LIB/
set_db init_hdl_search_path ../RTL/modulos/

# Carrega a biblioteca
read_libs slow_vdd1v0_basicCells.lib

# Lista de arquivos
set rtl_list {
    adder.v
    ALU.v
    byteEnableDecoder.v
    Control_Unit.v
    Execute_Memory.v
    forwarding_control.v
    fp2int.v
    FPU.v
    FPU_Decoder.v
    InstructionDecode.v
    InstructionFetch.v
    instruction_memory.v
    int2fp.v
    Main_Decoder.v
    memByteAddressable32WF.v
    memory_write_first.v
    memReadManager.v
    memTopoLittleEndian.v
    multiply.v
    mux2x1_32bits.v
    mux3x1_32bits.v
    PC.v
    register_file.v
    SignExtend.v
    topo.v
    ULA_Decoder.v
}

###############################################################
## CENÁRIO 1: BASELINE (30ns)
###############################################################
puts "=== Iniciando Baseline ==="

file mkdir reports/baseline
file mkdir outputs/baseline

# Leitura com a macro SYNTHESIS
read_hdl -define SYNTHESIS $rtl_list

set_db max_cpus 22

elaborate topo
check_design -unresolved

# Constraints Baseline
read_sdc ../constraints/constraints_top.sdc

set_db syn_generic_effort medium
set_db syn_map_effort medium
set_db syn_opt_effort medium

#set_db optimize_constant_0_flops false
#set_db optimize_constant_feedback_seqs false
# --- ETAPA 1: SYN_GENERIC ---
syn_generic
puts "--- Gerando Relatórios Baseline (Generic) ---"
report_timing > reports/baseline/report_timing_generic.rpt
report_power  > reports/baseline/report_power_generic.rpt
report_area   > reports/baseline/report_area_generic.rpt
report_qor    > reports/baseline/report_qor_generic.rpt

# --- ETAPA 2: SYN_MAP ---
syn_map
puts "--- Gerando Relatórios Baseline (Map) ---"
report_timing > reports/baseline/report_timing_map.rpt
report_power  > reports/baseline/report_power_map.rpt
report_area   > reports/baseline/report_area_map.rpt
report_qor    > reports/baseline/report_qor_map.rpt

# --- ETAPA 3: SYN_OPT (Final) ---
syn_opt
puts "--- Gerando Relatórios Baseline (Final/Opt) ---"
report_timing > reports/baseline/report_timing.rpt
report_power  > reports/baseline/report_power.rpt
report_area   > reports/baseline/report_area.rpt
report_qor    > reports/baseline/report_qor.rpt

# Outputs Finais
write_db topo -to_file outputs/baseline/design.db
write_hdl > outputs/baseline/topo_netlist.v
write_sdc > outputs/baseline/x_sdc.sdc
write_sdf -timescale ns -nonegchecks -recrem split -edges check_edge -setuphold split > outputs/baseline/delays.sdf

###############################################################
## CENÁRIO 2: PPA 1 (20ns)
###############################################################
puts "=== Iniciando PPA 1 ==="

delete_obj [get_db designs *]

file mkdir reports/ppa1
file mkdir outputs/ppa1

read_hdl -define SYNTHESIS $rtl_list

elaborate topo

read_sdc ../constraints/constraints_top_ppa1.sdc

# --- ETAPA 1: SYN_GENERIC ---
syn_generic
puts "--- Gerando Relatórios PPA1 (Generic) ---"
report_timing > reports/ppa1/report_timing_generic.rpt
report_power  > reports/ppa1/report_power_generic.rpt
report_area   > reports/ppa1/report_area_generic.rpt
report_qor    > reports/ppa1/report_qor_generic.rpt

# --- ETAPA 2: SYN_MAP ---
syn_map
puts "--- Gerando Relatórios PPA1 (Map) ---"
report_timing > reports/ppa1/report_timing_map.rpt
report_power  > reports/ppa1/report_power_map.rpt
report_area   > reports/ppa1/report_area_map.rpt
report_qor    > reports/ppa1/report_qor_map.rpt

# --- ETAPA 3: SYN_OPT (Final) ---
syn_opt
puts "--- Gerando Relatórios PPA1 (Final/Opt) ---"
report_timing > reports/ppa1/report_timing.rpt
report_power  > reports/ppa1/report_power.rpt
report_area   > reports/ppa1/report_area.rpt
report_qor    > reports/ppa1/report_qor.rpt

# Outputs Finais
write_db topo -to_file outputs/ppa1/design.db
write_hdl > outputs/ppa1/topo_netlist.v
write_sdc > outputs/ppa1/x_sdc.sdc
write_sdf -timescale ns -nonegchecks -recrem split -edges check_edge -setuphold split > outputs/ppa1/delays.sdf

###############################################################
## CENÁRIO 3: PPA 2 (10ns)
###############################################################
puts "=== Iniciando PPA 2 ==="

delete_obj [get_db designs *]

file mkdir reports/ppa2
file mkdir outputs/ppa2

read_hdl -define SYNTHESIS $rtl_list

elaborate topo

read_sdc ../constraints/constraints_top_ppa2.sdc

# --- ETAPA 1: SYN_GENERIC ---
syn_generic
puts "--- Gerando Relatórios PPA2 (Generic) ---"
report_timing > reports/ppa2/report_timing_generic.rpt
report_power  > reports/ppa2/report_power_generic.rpt
report_area   > reports/ppa2/report_area_generic.rpt
report_qor    > reports/ppa2/report_qor_generic.rpt

# --- ETAPA 2: SYN_MAP ---
syn_map
puts "--- Gerando Relatórios PPA2 (Map) ---"
report_timing > reports/ppa2/report_timing_map.rpt
report_power  > reports/ppa2/report_power_map.rpt
report_area   > reports/ppa2/report_area_map.rpt
report_qor    > reports/ppa2/report_qor_map.rpt

# --- ETAPA 3: SYN_OPT (Final) ---
syn_opt
puts "--- Gerando Relatórios PPA2 (Final/Opt) ---"
report_timing > reports/ppa2/report_timing.rpt
report_power  > reports/ppa2/report_power.rpt
report_area   > reports/ppa2/report_area.rpt
report_qor    > reports/ppa2/report_qor.rpt

# Outputs Finais
write_db topo -to_file outputs/ppa2/design.db
write_hdl > outputs/ppa2/x3_netlist.v
write_sdc > outputs/ppa2/x_sdc.sdc
write_sdf -timescale ns -nonegchecks -recrem split -edges check_edge -setuphold split > outputs/ppa2/delays.sdf

puts "=== Fim de todas as etapas ==="