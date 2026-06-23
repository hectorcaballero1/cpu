module maindec(
    input  [6:0] op,
    output reg [1:0] ResultSrc,
    output reg MemWrite,
    output reg Branch, ALUSrc,
    output reg RegWrite, Jump, Jalr,
    output reg [2:0] ImmSrc,
    output reg [1:0] ALUOp
);

    always @* begin
        {RegWrite, ALUSrc, MemWrite, Branch, Jump, Jalr, ResultSrc, ImmSrc, ALUOp} = 0;

        case(op)
            7'b0000011: begin // lw
                RegWrite  = 1;
                ImmSrc    = 3'b000;
                ALUSrc    = 1;
                ResultSrc = 2'b01;
            end

            7'b0100011: begin // sw
                ImmSrc   = 3'b001;
                ALUSrc   = 1;
                MemWrite = 1;
            end

            7'b0110011: begin // R-type
                RegWrite = 1;
                ALUOp    = 2'b10;
            end

            7'b1100011: begin // B-type
                ImmSrc = 3'b010;
                Branch = 1;
                ALUOp  = 2'b01;
            end

            7'b0010011: begin // I-type ALU
                RegWrite = 1;
                ImmSrc   = 3'b000;
                ALUSrc   = 1;
                ALUOp    = 2'b10;
            end

            7'b1101111: begin // jal
                RegWrite  = 1;
                ImmSrc    = 3'b011;
                ResultSrc = 2'b10;
                Jump      = 1;
            end

            7'b1100111: begin // jalr
                RegWrite  = 1;
                ImmSrc    = 3'b000;
                ALUSrc    = 1;
                ResultSrc = 2'b10;
                Jalr      = 1;
            end

            7'b0110111: begin // lui
                RegWrite = 1;
                ImmSrc   = 3'b100;
                ALUSrc   = 1;
                ALUOp    = 2'b11;
            end
        endcase
    end
endmodule
