`timescale 1ns / 1ps

module tb_pipeline;

    reg  clk, reset;
    wire [31:0] WriteData, DataAdr;
    wire        MemWrite;

    top dut (
        .clk      (clk),
        .reset    (reset),
        .WriteData(WriteData),
        .DataAdr  (DataAdr),
        .MemWrite (MemWrite)
    );

    initial begin
        reset = 1; #22;
        reset = 0;
    end

    always begin
        clk = 1; #5;
        clk = 0; #5;
    end

    // Corre 80 ciclos utiles y para
    initial #1020 $finish;

endmodule
