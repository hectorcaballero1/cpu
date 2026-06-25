module imem(input  [31:0] a,
            output [31:0] rd);

    reg [15:0] RAM[127:0];   // 128 halfwords = 64 words

    reg [31:0] WORDS[63:0];
    integer i;
    initial begin
        $readmemh("p1.mem", WORDS);
        for (i = 0; i < 64; i = i + 1) begin
            RAM[2*i]   = WORDS[i][15:0];
            RAM[2*i+1] = WORDS[i][31:16];
        end
    end

    assign rd = {RAM[a[31:1] + 1], RAM[a[31:1]]};
endmodule
