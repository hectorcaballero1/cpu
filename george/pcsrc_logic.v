module pcsrc_logic(
    input  JumpE,
    input  JalrE,
    input  BranchE,
    input  take_branchE,
    output [1:0] PCSrcE
);
    assign PCSrcE[1] = JalrE;
    assign PCSrcE[0] = JumpE | (BranchE & take_branchE);
endmodule
