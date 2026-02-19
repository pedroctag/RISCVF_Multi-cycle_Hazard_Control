# ==============================================================================
# CONSTRAINTS BASELINE (30ns) - CORRIGIDO PARA GENUS
# ==============================================================================

# 1. Configuração de Unidade
set_time_unit -nanoseconds

# 2. Criação do Clock
# Define o clock 'clk' na porta física 'clk' com período de 30ns
create_clock -name clk -period 30.0 -waveform {0 15} [get_ports clk]

# 3. Incerteza e Transição
set_clock_uncertainty 3.0 [get_clocks clk]
set_clock_transition -rise 3.0 [get_clocks clk]
set_clock_transition -fall 3.0 [get_clocks clk]

# 4. Latência do Clock
# Source Latency (Cristal até o pino) - Mantém a flag -source
set_clock_latency -source 1.5 [get_clocks clk]

# Network Latency (Pino até os registradores) 
# CORREÇÃO: Removemos o "-network". O Genus entende que sem flag = network.
set_clock_latency 0.9 [get_clocks clk]

# ==============================================================================
# 5. Definição de Delays de Entrada e Saída (Com Proteção)
# ==============================================================================

# Cria uma coleção com todas as entradas EXCETO o clock
set inputs_ex_clk [remove_from_collection [all_inputs] [get_ports clk]]

# Verifica se existem entradas antes de aplicar o delay para evitar erro SDC-204
if {[sizeof_collection $inputs_ex_clk] > 0} {
    # Input Delay
    set_input_delay -max 9.0 -clock clk $inputs_ex_clk
    
    # Input Transition
    set_input_transition -min 0.3 $inputs_ex_clk
    set_input_transition -max 3.0 $inputs_ex_clk
}

# Output Delay (Aplicado a todas as saídas)
set_output_delay -max 9.0 -clock clk [all_outputs]

# 6. Carga na Saída (Load)
set_load 0.04 [all_outputs]