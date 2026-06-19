# RISC-V Pipelined CPU

Procesador RISC-V de 32 bits con pipeline de 5 etapas implementado en Verilog.

## Implementaciones

| Carpeta | Descripción |
|---|---|
| `john/` | Pipelined base (sin hazard unit) |
| `paul/` | Pipelined con hazard unit (forwarding, load-use stall, branch flush) |

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

## Simulación

Abrir el proyecto en Vivado y correr la simulación con `sim/tb_john.v`. Los programas de prueba están en `programs/`:

- `p1_no_dependencies` sin dependencias de datos
- `p2_forwarding` prueba forwarding
- `p3_stalling` prueba stall por load-use
- `p4_flushing` prueba flush por branches/jumps
