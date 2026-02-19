// -----------------------------------------------------------
// Flags do Compilador (Xcelium/Xrun)
// -----------------------------------------------------------

-uvm                     // Habilita suporte a UVM
-access +rwc             // Habilita Read/Write/Connectivity (ESSENCIAL PARA BACKDOOR)
-coverage functional         // Cobre RTL (Code Coverage)
-covoverwrite          // Sobrescreve dados antigos

-timescale 1ns/1ps

+incdir+../uvm_att_para_teste
+incdir+../RTL/modulos

// -----------------------------------------------------------
// Design (RTL) - Arquivos .v legados
// -----------------------------------------------------------
    ../RTL/modulos/adder.v
    ../RTL/modulos/ALU.v
    ../RTL/modulos/byteEnableDecoder.v
    ../RTL/modulos/Control_Unit.v
    ../RTL/modulos/Execute_Memory.v
    ../RTL/modulos/forwarding_control.v
    ../RTL/modulos/fp2int.v
    ../RTL/modulos/FPU.v
    ../RTL/modulos/FPU_Decoder.v
    ../RTL/modulos/InstructionDecode.v
    ../RTL/modulos/InstructionFetch.v
    ../RTL/modulos/instruction_memory.v
    ../RTL/modulos/int2fp.v
    ../RTL/modulos/Main_Decoder.v
    ../RTL/modulos/memByteAddressable32WF.v
    ../RTL/modulos/memory_write_first.v
    ../RTL/modulos/memReadManager.v
    ../RTL/modulos/memTopoLittleEndian.v
    ../RTL/modulos/multiply.v
    ../RTL/modulos/mux2x1_32bits.v
    ../RTL/modulos/mux3x1_32bits.v
    ../RTL/modulos/PC.v
    ../RTL/modulos/register_file.v
    ../RTL/modulos/ULA_Decoder.v
    ../RTL/modulos/SignExtend.v
    ../RTL/modulos/topo.v

// -----------------------------------------------------------
// Testbench (UVM) - Arquivos .sv
// -----------------------------------------------------------
// 1. Interface
    ../uvm_att_para_teste/risc_if.sv

// 2. Package
    ../uvm_att_para_teste/risc_pkg.sv

// 3. Topo do Testbench
    ../uvm_att_para_teste/tb_top.sv
