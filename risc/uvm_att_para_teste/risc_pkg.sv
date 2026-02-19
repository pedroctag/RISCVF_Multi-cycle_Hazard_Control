// CORREÇÃO: Timescale definido antes do package
`timescale 1ns/1ps

package risc_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // Ordem de includes
    `include "risc_item.sv"
    `include "risc_sequencer.sv"
    `include "risc_sequence.sv" // Sua sequence corrigida
    `include "risc_driver.sv"
    `include "risc_monitor.sv"
    `include "risc_coverage.sv"
    `include "risc_agent.sv"
    `include "risc_scoreboard.sv" // Seu scoreboard corrigido
    `include "risc_env.sv"
    `include "risc_test.sv"

endpackage
