module hazard_unit(input  [4:0] Rs1E, Rs2E,
                   input  [4:0] RdM, RdW,
                   input        RegWriteM, RegWriteW,
                   output reg [1:0] ForwardAE, ForwardBE);

    // 2'b10 -> forward from MEM (ALUResultM)
    // 2'b01 -> forward from WB  (ResultW)
    // 2'b00 -> no forward (use pipeline register)
    // MEM has priority over WB since it carries more recent data

    always @(*) begin
        if      (Rs1E == RdM && Rs1E != 5'b0 && RegWriteM) ForwardAE = 2'b10;
        else if (Rs1E == RdW && Rs1E != 5'b0 && RegWriteW) ForwardAE = 2'b01;
        else                                                 ForwardAE = 2'b00;

        if      (Rs2E == RdM && Rs2E != 5'b0 && RegWriteM) ForwardBE = 2'b10;
        else if (Rs2E == RdW && Rs2E != 5'b0 && RegWriteW) ForwardBE = 2'b01;
        else                                                 ForwardBE = 2'b00;
    end

endmodule
