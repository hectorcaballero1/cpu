module branch_unit(input [2:0] branch_type, 
                   input zero, less,
                   output reg take_branch);

    always @(*) begin
        case (branch_type)
            3'b000: take_branch = zero;   // beq: salta si a == b
            3'b001: take_branch = ~zero;  // bne: salta si a != b
            3'b100: take_branch = less;   // blt: salta si a < b
            3'b101: take_branch = ~less;  // bge: salta si a >= b
            default: take_branch = 1'b0;  
        endcase
    end
endmodule