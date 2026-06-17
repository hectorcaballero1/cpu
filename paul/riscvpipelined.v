module riscvpipelined(input  clk, reset,
                      output [31:0] PCF,
                      input  [31:0] InstrF,
                      output MemWriteM,
                      output [31:0] ALUResultM, WriteDataM,
                      input  [31:0] ReadDataM);

    // Wires internos de la etapa Decode hacia el Controller
    wire [6:0] opD;
    wire [2:0] funct3D;
    wire       funct7b5D;
    
    // Wires de control generados por el Controller
    wire [1:0] ResultSrcD;
    wire MemWriteD;
    wire ALUSrcD;
    wire RegWriteD;
    wire JumpD;
    wire JalrD;
    wire BranchD;
    wire [2:0] ImmSrcD;
    wire [3:0] ALUControlD;

    controller c(
        .op(opD),
        .funct3(funct3D),
        .funct7b5(funct7b5D),
        .ResultSrc(ResultSrcD),
        .MemWrite(MemWriteD),
        .ALUSrc(ALUSrcD),
        .RegWrite(RegWriteD),
        .Jump(JumpD),
        .Jalr(JalrD),
        .Branch(BranchD),
        .ImmSrc(ImmSrcD),
        .ALUControl(ALUControlD)
    );

    datapath dp(
        .clk(clk),
        .reset(reset),
        
        .PCF(PCF),
        .InstrF(InstrF),
       
        .MemWriteM(MemWriteM),
        .ALUResultM(ALUResultM),
        .WriteDataM(WriteDataM),
        .ReadDataM(ReadDataM),
        
        .opD(opD),
        .funct3D(funct3D),
        .funct7b5D(funct7b5D),
        
        .ResultSrcD(ResultSrcD),
        .MemWriteD(MemWriteD),
        .ALUSrcD(ALUSrcD),
        .RegWriteD(RegWriteD),
        .JumpD(JumpD),
        .JalrD(JalrD),
        .BranchD(BranchD),
        .ImmSrcD(ImmSrcD),
        .ALUControlD(ALUControlD)
    );

endmodule