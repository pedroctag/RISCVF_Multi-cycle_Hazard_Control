module Execute_Memory (
  input [31:0] ImmExt,
  input [31:0] WriteData,
  input [31:0] SrcA,
  input [31:0] SrcAF,
  input [31:0] SrcBF,
  input MemSrc,
  input DSrc,
  input [4:0] rs1, rs2, // rs1 e rs2
  input [4:0] rd, // rd
  input wreX, wreF, //write enable dos registros X e F
  // instanciar duas entradas da FPU (A e B)
  // instanciar também o select da FPU
  // instanciar dois controles de muxes de 1 bit
  input [2:0] ALUControl,
  input [2:0] funct3,
  input MemWrite,
  input clk,
  input ALUSrc,
  input FPUAinSel,
  input [4:0] selFPU,
  input [31:0] inD, //entrada para fowarding do ff D
  input [63:0] inMEM, //entrada para fowarding da memoria
  input [63:0] inMEMX, // entrada forwarding de reg X
  input [4:0] rd_MEMWB,
  input RegWrite_MEMWB,
  output zero, // Ver se existe este sinal para FPU
  output reg RegWrite_EXMEM, //or dos dois sinais de write enable
  output reg [4:0] rd_EXMEM, // rd
  output [31:0] ReadData, muxpal_result
);

// MÓDULO INCOMPLETO, FALTA A FPU E SEUS SINAIS, ALÉM DE COMPLETAR MUXES

  wire [31:0] SrcB, ALUResult, FPUResult, Write_muxmem, AdaFPU;
  wire [5:0] deslocado;
  wire RegWrite_EXMEM_wire; //or dos dois sinais de write enable
  wire [4:0] rd_EXMEM_wire; // rd
  wire [1:0] operando_a_sel, operando_b_sel;
  wire [31:0] mux1_wire,mux2_wire,mux3_wire,mux4_wire; 

  always @(posedge clk) begin
    RegWrite_EXMEM <= wreX | wreF;
    rd_EXMEM <= rd;
  end

  assign rd_EXMEM_wire = rd_EXMEM; 
  assign RegWrite_EXMEM_wire = RegWrite_EXMEM;


  mux3x1_32bits mux1 (
    .inC(inD), //10
    .inA(AdaFPU), //00
    .inB(inMEM[31:0]), //01
    .sel(operando_a_sel),
    .out(mux1_wire)
  );

  mux3x1_32bits mux2 (
    .inC(inD), //10
    .inA(SrcBF), //00
    .inB(inMEM[63:32]), //01
    .sel(operando_b_sel),
    .out(mux2_wire)
    );

  mux3x1_32bits mux3 (
    .inC(inD), //10
    .inA(SrcA), //00
    .inB(inMEMX[31:0]), //01
    .sel(operando_a_sel),
    .out(mux3_wire)
  );

  mux3x1_32bits mux4 (
    .inC(inD), //10
    .inA(WriteData), //00 tambem conhecido como registro B do x
    .inB(inMEMX[63:32]), //01
    .sel(operando_b_sel),
    .out(mux4_wire)
  );

  forwarding_control fc (
    .RegWrite_EXMEM(RegWrite_EXMEM_wire),   // Hab. escrita no EX/MEM de dentro do EXMEME
    .RegWrite_MEMWB(RegWrite_MEMWB),   // Hab. escrita no MEM/WB externo ao EXMEM (MEM/WRB)
    .rd_EXMEM(rd_EXMEM_wire),   // Reg. destino no EX/MEM
    .rd_MEMWB(rd_MEMWB),   // Reg. destino no MEM/WB
    .rs1_IDEX(rs1),   // Reg. fonte 1 no ID/EX
    .rs2_IDEX(rs2),   // Reg. fonte 2 no ID/EX

    // Saídas: seletores de mux para operandos
    .operand_a_sel(operando_a_sel), // Seletor para op.A
    .operand_b_sel(operando_b_sel)  // Seletor para op.B
  );

  mux2x1_32bits muxin (
    .inA(mux4_wire),
    .inB(ImmExt),
    .sel(ALUSrc),
    .out(SrcB)
  );

  ALU alu (
    .A(mux3_wire),
    .B(SrcB),
    .ALUControl(ALUControl),
    .ALUResult(ALUResult),
    .Zero(zero)
  );

  FPU fpu (

    .A(mux1_wire),
    .B(mux2_wire), // alterar para a entrada B da FPU
    .sel(selFPU), // alterar para o controle da FPU
    .Result(FPUResult)

  );

  mux2x1_32bits muxFPUin (
    .inA(SrcAF),
    .inB(SrcA),
    .sel(FPUAinSel),
    .out(AdaFPU)
  );

  mux2x1_32bits muxmem ( // mux de entrada para a memória
    .inA(SrcB), // entrada B da ALU
    .inB(SrcBF), //entrada B da FPU
    .sel(MemSrc),
    .out(Write_muxmem)
  );

  mux2x1_32bits muxpal ( // mux para saída da AUL/FPU
    .inA(ALUResult),
    .inB(FPUResult),
    .sel(DSrc),
    .out(muxpal_result)
  );
// instanciar dois muxes, um para a entrada da memória (decide se pega o dado de B ou fB), outro para a saida até o ff D (Decide se o dado vem da ULA ou FPU)
// instanciar FPU com entrada dos novos sinais de input

// em análise diagonal, 4 wires de 32 bits novos serão utilizados(para entrada e saída dos muxes), ver quais no esquemático

/*  data_memory dmemory (
    .clk(clk),
    .A(muxpal_result),
    .WD(Write_muxmem),
    .WE(MemWrite),
    .RD(ReadData)
  );
*/
assign deslocado = (funct3[1] != 1'b1) ? (muxpal_result << 2) : ((muxpal_result <<2 ) - 4 );

  memTopo32LittleEndian dmemory (
    .clk(clk),
    .size(funct3[1:0]),
    .addr(deslocado),
    .din(Write_muxmem),
    .sign_ext(funct3[2]),
    .writeEnable(MemWrite),
    .dout(ReadData)
  );

endmodule
