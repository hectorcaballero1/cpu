# RISC-V Pipelined Processor

Proyecto de Arquitectura de Computadoras. Para testear, abrir el proyecto en Vivado y correr la simulación con el testbench.

## Instrucciones soportadas

| Instrucción | Descripción |
|---|---|
| `lw rd, imm(rs1)` | Load word |
| `sw rs2, imm(rs1)` | Store word |
| `add rd, rs1, rs2` | Add |
| `sub rd, rs1, rs2` | Subtract |
| `and rd, rs1, rs2` | AND |
| `or rd, rs1, rs2` | OR |
| `xor rd, rs1, rs2` | XOR |
| `sll rd, rs1, rs2` | Shift left logical |
| `srl rd, rs1, rs2` | Shift right logical |
| `sra rd, rs1, rs2` | Shift right arithmetic |
| `addi rd, rs1, imm` | Add immediate |
| `andi rd, rs1, imm` | AND immediate |
| `ori rd, rs1, imm` | OR immediate |
| `xori rd, rs1, imm` | XOR immediate |
| `slli rd, rs1, shamt` | Shift left logical immediate |
| `srli rd, rs1, shamt` | Shift right logical immediate |
| `srai rd, rs1, shamt` | Shift right arithmetic immediate |
| `lui rd, imm` | Load upper immediate |
| `beq rs1, rs2, offset` | Branch if equal |
| `bne rs1, rs2, offset` | Branch if not equal |
| `blt rs1, rs2, offset` | Branch if less than |
| `bge rs1, rs2, offset` | Branch if greater than or equal |
| `jal rd, offset` | Jump and link |
| `jalr rd, rs1, imm` | Jump and link register |
