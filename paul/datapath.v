module datapath(input clk, reset,
                output [31:0] PCF,
                input  [31:0] InstrF,
                output MemWriteM,
                output [31:0] ALUResultM, WriteDataM,
                input  [31:0] ReadDataM,
                output [6:0]  opD,
                output [2:0]  funct3D,
                output funct7b5D,
                input  [1:0]  ResultSrcD,
                input  MemWriteD,
                input  ALUSrcD,
                input  RegWriteD, JumpD, JalrD, BranchD,
                input  [2:0]  ImmSrcD,
                input  [3:0]  ALUControlD);

    localparam WIDTH = 32;

    // Fetch
    wire [31:0] PCNextF, PCPlus4F;
    wire [1:0]  PCSrcE;
    wire [31:0] PCTargetE;
    wire [31:0] ALUResultE;

    // Señales de hazard (stall / flush)
    wire StallF, StallD, FlushD, FlushE;

    mux3 #(WIDTH) pcmux(
        .d0(PCPlus4F),
        .d1(PCTargetE),
        .d2(ALUResultE),
        .s(PCSrcE),
        .y(PCNextF)
    );

    flopre #(WIDTH) pcreg(
        .clk(clk),
        .reset(reset),
        .en(~StallF),
        .d(PCNextF),
        .q(PCF)
    );

    adder pcadd4(
        .a(PCF),
        .b(32'd4),
        .y(PCPlus4F)
    );


    // Registros Fetch/Decode 
    wire [31:0] PCD, PCPlus4D, InstrD;

    floprce #(32) r_ifid_pc(clk, reset, FlushD, ~StallD, PCF, PCD);
    floprce #(32) r_ifid_pc4(clk, reset, FlushD, ~StallD, PCPlus4F, PCPlus4D);
    floprce #(32) r_ifid_instr(clk, reset, FlushD, ~StallD, InstrF, InstrD);


    // Instruction decode
    wire [31:0] SrcAD, WriteDataD, ImmExtD;
    wire [4:0]  RdW;
    wire [31:0] ResultW;
    wire RegWriteW;
    wire [4:0]  Rs1D, Rs2D;

    // Inputs para el Controller
    assign opD       = InstrD[6:0];
    assign funct3D   = InstrD[14:12];
    assign funct7b5D = InstrD[30];

    assign Rs1D = InstrD[19:15];
    assign Rs2D = InstrD[24:20];

    regfile rf(
        .clk(clk),
        .we3(RegWriteW),
        .a1(Rs1D),
        .a2(Rs2D),
        .a3(RdW),
        .wd3(ResultW),
        .rd1(SrcAD),
        .rd2(WriteDataD)
    );

    extend ext(
        .instr(InstrD[31:7]),
        .immsrc(ImmSrcD),
        .immext(ImmExtD)
    );


    // Registros Decode/Execute
    wire [31:0] RD1E, RD2E, PCE, ImmExtE, PCPlus4E;
    wire [4:0]  RdE, Rs1E, Rs2E;
    wire [2:0]  funct3E;
    wire [31:0] InstrE;
    wire RegWriteE;
    wire [1:0]  ResultSrcE;
    wire MemWriteE;
    wire ALUSrcE;
    wire JumpE, JalrE, BranchE;
    wire [3:0]  ALUControlE;

    floprc #(32) r_idex_srca(clk, reset, FlushE, SrcAD, RD1E);
    floprc #(32) r_idex_wdata(clk, reset, FlushE, WriteDataD, RD2E);
    floprc #(32) r_idex_pc(clk, reset, FlushE, PCD, PCE);
    floprc #(32) r_idex_imm(clk, reset, FlushE, ImmExtD, ImmExtE);
    floprc #(32) r_idex_pc4(clk, reset, FlushE, PCPlus4D, PCPlus4E);
    floprc #(5)  r_idex_rd(clk, reset, FlushE, InstrD[11:7], RdE);
    floprc #(5)  r_idex_rs1(clk, reset, FlushE, Rs1D, Rs1E);
    floprc #(5)  r_idex_rs2(clk, reset, FlushE, Rs2D, Rs2E);
    floprc #(3)  r_idex_f3(clk, reset, FlushE, funct3D, funct3E);
    floprc #(32) r_idex_instr(clk, reset, FlushE, InstrD, InstrE);   // solo para waveform

    floprc #(1)  r_idex_rwr(clk, reset, FlushE, RegWriteD, RegWriteE);
    floprc #(2)  r_idex_rsrc(clk, reset, FlushE, ResultSrcD, ResultSrcE);
    floprc #(1)  r_idex_mwr(clk, reset, FlushE, MemWriteD, MemWriteE);
    floprc #(1)  r_idex_asrc(clk, reset, FlushE, ALUSrcD, ALUSrcE);
    floprc #(1)  r_idex_jmp(clk, reset, FlushE, JumpD, JumpE);
    floprc #(1)  r_idex_jalr(clk, reset, FlushE, JalrD, JalrE);
    floprc #(1)  r_idex_br(clk, reset, FlushE, BranchD, BranchE);
    floprc #(4)  r_idex_aluc(clk, reset, FlushE, ALUControlD, ALUControlE);


    // Execute
    wire [31:0] SrcAE, WriteDataE, SrcBE;
    wire        zeroE, lessE, take_branchE;
    wire [1:0]  ForwardAE, ForwardBE;

    hazard_unit hu(
        .Rs1D(Rs1D),
        .Rs2D(Rs2D),
        .Rs1E(Rs1E),
        .Rs2E(Rs2E),
        .RdE(RdE),
        .RdM(RdM),
        .RdW(RdW),
        .RegWriteM(RegWriteM),
        .RegWriteW(RegWriteW),
        .ResultSrcE0(ResultSrcE[0]),
        .PCSrcE(PCSrcE),
        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE),
        .StallF(StallF),
        .StallD(StallD),
        .FlushD(FlushD),
        .FlushE(FlushE)
    );

    mux3 #(WIDTH) fwdamux(
        .d0(RD1E),
        .d1(ResultW),
        .d2(ALUResultM),
        .s(ForwardAE),
        .y(SrcAE)
    );

    mux3 #(WIDTH) fwdbmux(
        .d0(RD2E),
        .d1(ResultW),
        .d2(ALUResultM),
        .s(ForwardBE),
        .y(WriteDataE)
    );

    adder pctarget(
        .a(PCE),
        .b(ImmExtE),
        .y(PCTargetE)
    );

    mux2 #(WIDTH) srcbmux(
        .d0(WriteDataE),
        .d1(ImmExtE),
        .s(ALUSrcE),
        .y(SrcBE)
    );

    alu alu(
        .a(SrcAE),
        .b(SrcBE),
        .alucontrol(ALUControlE),
        .result(ALUResultE),
        .zero(zeroE),
        .less(lessE)
    );

    branch_unit bu(
        .branch_type(funct3E),
        .zero(zeroE),
        .less(lessE),
        .take_branch(take_branchE)
    );

    pcsrc_logic pcsrc(
        .JumpE(JumpE),
        .JalrE(JalrE),
        .BranchE(BranchE),
        .take_branchE(take_branchE),
        .PCSrcE(PCSrcE)
    );


    // Registros Execute/Memory
    wire [31:0] PCPlus4M;
    wire [4:0]  RdM;
    wire RegWriteM;
    wire [1:0]  ResultSrcM;
    wire [31:0] InstrM;
    wire [31:0] PCM;

    flopr #(32) r_exmem_alures(clk, reset, ALUResultE, ALUResultM);
    flopr #(32) r_exmem_wdata(clk, reset, WriteDataE, WriteDataM);
    flopr #(32) r_exmem_pc4(clk, reset, PCPlus4E, PCPlus4M);
    flopr #(5)  r_exmem_rd(clk, reset, RdE, RdM);

    flopr #(1)  r_exmem_rwr(clk, reset, RegWriteE, RegWriteM);
    flopr #(2)  r_exmem_rsrc(clk, reset, ResultSrcE, ResultSrcM);
    flopr #(1)  r_exmem_mwr(clk, reset, MemWriteE, MemWriteM);
    flopr #(32) r_exmem_instr(clk, reset, InstrE, InstrM);   // solo para waveform
    flopr #(32) r_exmem_pc(clk, reset, PCE, PCM);           // solo para waveform


    // Memory
    
    // MemWriteM, ALUResultM y WriteDataM son outputs, se conectan a Data Memory
    // El puerto ReadDataM ingresa como dato fresco desde el exterior (output de Data Memory)

    // Registros Memory/WriteBack
    wire [31:0] ALUResultW, ReadDataW, PCPlus4W;
    wire [1:0]  ResultSrcW;
    wire [31:0] InstrW;
    wire [31:0] PCW;

    flopr #(32) r_memwb_alures(clk, reset, ALUResultM, ALUResultW);
    flopr #(32) r_memwb_rdata(clk, reset, ReadDataM, ReadDataW);
    flopr #(32) r_memwb_pc4(clk, reset, PCPlus4M, PCPlus4W);
    flopr #(5)  r_memwb_rd(clk, reset, RdM, RdW);

    flopr #(1)  r_memwb_rwr(clk, reset, RegWriteM, RegWriteW);
    flopr #(2)  r_memwb_rsrc(clk, reset, ResultSrcM, ResultSrcW);
    flopr #(32) r_memwb_instr(clk, reset, InstrM, InstrW);   // solo para waveform
    flopr #(32) r_memwb_pc(clk, reset, PCM, PCW);           // solo para waveform


    // WriteBack
    
    mux3 #(WIDTH) resultmux(
        .d0(ALUResultW),
        .d1(ReadDataW),
        .d2(PCPlus4W),
        .s(ResultSrcW),
        .y(ResultW)
    );

endmodule