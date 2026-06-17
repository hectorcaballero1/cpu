module hazard_unit(input  [4:0] Rs1D, Rs2D,
                   input  [4:0] Rs1E, Rs2E,
                   input  [4:0] RdE, RdM, RdW,
                   input        RegWriteM, RegWriteW,
                   input        ResultSrcE0,
                   output reg [1:0] ForwardAE, ForwardBE,
                   output       StallF, StallD, FlushE);

    // 2'b10: forward from MEM (ALUResultM)
    // 2'b01: forward from WB  (ResultW)
    // 2'b00: no forward
    // MEM has priority over WB since it carries more recent data

    always @(*) begin
        if      (Rs1E == RdM && Rs1E != 5'b0 && RegWriteM) ForwardAE = 2'b10;
        else if (Rs1E == RdW && Rs1E != 5'b0 && RegWriteW) ForwardAE = 2'b01;
        else                                               ForwardAE = 2'b00;

        if      (Rs2E == RdM && Rs2E != 5'b0 && RegWriteM) ForwardBE = 2'b10;
        else if (Rs2E == RdW && Rs2E != 5'b0 && RegWriteW) ForwardBE = 2'b01;
        else                                               ForwardBE = 2'b00;
    end

    // Load-use hazard: la instruccion en EX es un lw (ResultSrcE0 == 1) y la instruccion en Decode usa su Rd.
    // Congelamos Fetch y Decode un ciclo, y flusheamos Execute (NOP) para que el lw avance a WB y luego un little forwarding.
    wire lwStall;
    assign lwStall = ResultSrcE0 & (RdE != 5'b0) & ((Rs1D == RdE) | (Rs2D == RdE));

    assign StallF = lwStall;
    assign StallD = lwStall;
    assign FlushE = lwStall;

endmodule
