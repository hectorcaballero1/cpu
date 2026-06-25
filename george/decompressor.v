module decompressor(input  [31:0] instr_in,
                    output [31:0] instr32,
                    output is_compressed);

    wire [15:0] inst = instr_in[15:0];

    assign is_compressed = (inst[1:0] != 2'b11);

    // Opcodes de 32 bits
    localparam [6:0] OP_R     = 7'b0110011; // R-type
    localparam [6:0] OP_I     = 7'b0010011; // I-type ALU
    localparam [6:0] OP_LOAD  = 7'b0000011; // lw
    localparam [6:0] OP_STORE = 7'b0100011; // sw
    localparam [6:0] OP_LUI   = 7'b0110111; // lui
    localparam [6:0] OP_BR    = 7'b1100011; // branch
    localparam [6:0] OP_JAL   = 7'b1101111; // jal
    localparam [6:0] OP_JALR  = 7'b1100111; // jalr

    // Registers
    wire [4:0] rd_full  = inst[11:7]; // rd / rs1
    wire [4:0] rs2_full = inst[6:2];  // rs2
    wire [4:0] regp_h = {2'b01, inst[9:7]}; // rs1'/rd'
    wire [4:0] regp_l = {2'b01, inst[4:2]}; // rs2'/rd'

    // Immediates por tipo
    // CI signed de 6 bits (c.addi, c.andi): imm[5]=inst[12], imm[4:0]=inst[6:2]
    wire [11:0] imm_ci = {{7{inst[12]}}, inst[6:2]};

    // c.lw/c.sw: offset = {inst[5], inst[12:10], inst[6], 2'b00}  (unsigned, 7-bit)
    //   imm[6]=inst[5], imm[5:3]=inst[12:10], imm[2]=inst[6]
    wire [11:0] imm_clw = {5'b0, inst[5], inst[12:10], inst[6], 2'b00};

    // c.lwsp: offset = {inst[3:2], inst[12], inst[6:4], 2'b00}  (unsigned, 8-bit)
    wire [11:0] imm_lwsp = {4'b0, inst[3:2], inst[12], inst[6:4], 2'b00};

    // c.swsp: offset = {inst[8:7], inst[12:9], 2'b00}  (unsigned, 8-bit)
    wire [11:0] imm_swsp = {4'b0, inst[8:7], inst[12:9], 2'b00};

    // CB (c.beqz/c.bnez): offset signed de 9 bits
    wire [12:0] imm_cb = {{4{inst[12]}}, inst[12], inst[6:5], inst[2], inst[11:10], inst[4:3], 1'b0};

    // CJ (c.j/c.jal): offset signed de 12 bits
    wire [20:0] imm_cj = {{9{inst[12]}}, inst[12], inst[8], inst[10:9], inst[6], inst[7], inst[2], inst[11], inst[5:3], 1'b0};

    reg [31:0] instr32_reg;
    assign instr32 = instr32_reg;

    always @(*) begin
        instr32_reg = 32'h00000013; // nop por default

        case (inst[1:0])

        // No comprimida
        2'b11: instr32_reg = instr_in;

        // Quadrant 0
        2'b00: case (inst[15:13])
            3'b010: // c.lw rd', imm(rs1') -> lw rd, imm(rs1)
                instr32_reg = {imm_clw, regp_h, 3'b010, regp_l, OP_LOAD};
            3'b110: // c.sw rs2', imm(rs1') -> sw rs2, imm(rs1)
                instr32_reg = {imm_clw[11:5], regp_l, regp_h, 3'b010, imm_clw[4:0], OP_STORE};
        endcase

        // Quadrant 1
        2'b01: case (inst[15:13])
            3'b000: // c.addi rd, imm -> addi rd, rd, imm
                instr32_reg = {imm_ci, rd_full, 3'b000, rd_full, OP_I};

            3'b001: // c.jal offset -> jal x1, offset
                instr32_reg = {imm_cj[20], imm_cj[10:1], imm_cj[11], imm_cj[19:12], 5'd1, OP_JAL};

            3'b010: // c.li rd, imm -> addi rd, x0, imm  (rd==0 es HINT -> nop)
                instr32_reg = {imm_ci, 5'd0, 3'b000, rd_full, OP_I};

            3'b011: // c.lui rd, nzimm -> lui rd, nzimm
                if (rd_full != 5'd0 && rd_full != 5'd2)
                    // nzimm[17]=inst[12], nzimm[16:12]=inst[6:2] -> imm20 sign-ext
                    instr32_reg = {{15{inst[12]}}, inst[6:2], rd_full, OP_LUI};

            3'b100: case (inst[11:10])
                2'b00: // c.srli rd', shamt -> srli rd, rd, shamt
                    instr32_reg = {7'b0000000, inst[6:2], regp_h, 3'b101, regp_h, OP_I};
                2'b01: // c.srai rd', shamt -> srai rd, rd, shamt
                    instr32_reg = {7'b0100000, inst[6:2], regp_h, 3'b101, regp_h, OP_I};
                2'b10: // c.andi rd', imm -> andi rd, rd, imm
                    instr32_reg = {imm_ci, regp_h, 3'b111, regp_h, OP_I};
                2'b11: case (inst[6:5]) // inst[12]=0 para sub/xor/or/and
                    2'b00: // c.sub rd', rs2' -> sub rd, rd, rs2
                        instr32_reg = {7'b0100000, regp_l, regp_h, 3'b000, regp_h, OP_R};
                    2'b01: // c.xor rd', rs2' -> xor rd, rd, rs2
                        instr32_reg = {7'b0000000, regp_l, regp_h, 3'b100, regp_h, OP_R};
                    2'b10: // c.or rd', rs2' -> or rd, rd, rs2
                        instr32_reg = {7'b0000000, regp_l, regp_h, 3'b110, regp_h, OP_R};
                    2'b11: // c.and rd', rs2' -> and rd, rd, rs2
                        instr32_reg = {7'b0000000, regp_l, regp_h, 3'b111, regp_h, OP_R};
                endcase
            endcase

            3'b101: // c.j offset -> jal x0, offset
                instr32_reg = {imm_cj[20], imm_cj[10:1], imm_cj[11], imm_cj[19:12], 5'd0, OP_JAL};

            3'b110: // c.beqz rs1', offset -> beq rs1, x0, offset
                instr32_reg = {imm_cb[12], imm_cb[10:5], 5'd0, regp_h, 3'b000, imm_cb[4:1], imm_cb[11], OP_BR};

            3'b111: // c.bnez rs1', offset -> bne rs1, x0, offset
                instr32_reg = {imm_cb[12], imm_cb[10:5], 5'd0, regp_h, 3'b001, imm_cb[4:1], imm_cb[11], OP_BR};
        endcase

        // Quadrant 2
        2'b10: case (inst[15:13])
            3'b000: // c.slli rd, shamt -> slli rd, rd, shamt
                instr32_reg = {7'b0000000, inst[6:2], rd_full, 3'b001, rd_full, OP_I};

            3'b010: // c.lwsp rd, imm(x2) -> lw rd, imm(x2)
                instr32_reg = {imm_lwsp, 5'd2, 3'b010, rd_full, OP_LOAD};

            3'b100: begin // c.jr / c.jalr / c.mv / c.add
                if (inst[12] == 1'b0) begin
                    if (rs2_full == 5'd0) // c.jr rs1 -> jalr x0, rs1, 0
                        instr32_reg = {12'b0, rd_full, 3'b000, 5'd0, OP_JALR};
                    else // c.mv rd, rs2 -> add rd, x0, rs2
                        instr32_reg = {7'b0000000, rs2_full, 5'd0, 3'b000, rd_full, OP_R};
                end else begin
                    if (rs2_full == 5'd0) // c.jalr rs1 -> jalr x1, rs1, 0
                        instr32_reg = {12'b0, rd_full, 3'b000, 5'd1, OP_JALR};
                    else // c.add rd, rs2 -> add rd, rd, rs2
                        instr32_reg = {7'b0000000, rs2_full, rd_full, 3'b000, rd_full, OP_R};
                end
            end

            3'b110: // c.swsp rs2, imm(x2) -> sw rs2, imm(x2)
                instr32_reg = {imm_swsp[11:5], rs2_full, 5'd2, 3'b010, imm_swsp[4:0], OP_STORE};
        endcase

        endcase
    end
endmodule
