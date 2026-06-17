module aludec(input            opb5,     
              input      [2:0] funct3,   
              input            funct7b5,  
              input      [1:0] ALUOp,     
              output reg [3:0] ALUControl);

    wire RtypeSub;
    // Solo es resta si es R-type y funct7[5] es 1
    assign RtypeSub = funct7b5 & opb5; 

    always @(*) case(ALUOp)
        2'b00: ALUControl = 4'b0000; // lw, sw, jal, jalr: add
        2'b01: ALUControl = 4'b0001; // beq, bne, blt, bge: sub
        2'b11: ALUControl = 4'b1001; // lui (el alu tiene una operacion personalizada para luis :))
        
        2'b10: case(funct3) // R-type o I-type ALU
            3'b000: if (RtypeSub) ALUControl = 4'b0001; // sub
                    else          ALUControl = 4'b0000; // add, addi
            3'b001: ALUControl = 4'b0110;               // sll, slli
            3'b010: ALUControl = 4'b0101;               // slt, slti
            3'b100: ALUControl = 4'b0100;               // xor, xori
            3'b110: ALUControl = 4'b0011;               // or, ori
            3'b111: ALUControl = 4'b0010;               // and, andi
            
            3'b101: if (funct7b5) ALUControl = 4'b1000; // sra, srai 
                    else          ALUControl = 4'b0111; // srl, srli 
            default: ALUControl = 4'bxxxx;
        endcase
        default: ALUControl = 4'bxxxx;
    endcase
endmodule