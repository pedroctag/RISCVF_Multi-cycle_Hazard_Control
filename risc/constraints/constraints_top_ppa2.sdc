# --- PPA 2: Clock de 10ns ---

# 1. Definição do Clock (Waveform ajustada: 0 a 5)
create_clock -name clk -period 10 -waveform {0 5} [get_ports "clk"]

# 2. Clock Uncertainty (10% de 10ns)
set_clock_uncertainty 1 [get_clocks "clk"]

# 3. Clock Transition (10% de 10ns)
set_clock_transition -rise 1 [get_clocks "clk"]
set_clock_transition -fall 1 [get_clocks "clk"]

# 4. Clock Latency
set_clock_latency -source 0.5 [get_clocks "clk"]   ;# 5%
set_clock_latency -network 0.3 [get_clocks "clk"]  ;# 3%

# Coleções auxiliares
set inputs_ex_clk [remove_from_collection [all_inputs] [get_ports "clk"]]
set all_outs [all_outputs]

# 5. Input e Output Delay (30% de 10ns)
set_input_delay -max 3 [get_ports ""] -clock [get_clocks "clk"]
set_output_delay -max 3 [get_ports ""] -clock [get_clocks "clk"]

# 6. Output Load (Mantido constante)
set_load 0.04 [all_outputs]

# 7. Input Transition (Min 1% / Max 10%)
set_input_transition -min 0.1 [get_ports $inputs_ex_clk]
set_input_transition -max 1.0 [get_ports $inputs_ex_clk]
