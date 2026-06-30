# Heapsort version comprimida (RVC)

# Misma logica que heapsort_rv32i.s. Las ops restringidas (c.and/or/sub/xor/
# srli/srai/andi/lw/sw) solo aceptan x8..x15, por eso todos los registros de
# trabajo del array y de heapify viven en ese rango (x8..x15).

# Array de 15 enteros cargado en dmem a partir de la direccion base 0.
# Entrada : 14 3 27 8 21 11 1 19 6 30 24 9 17 5 12
# Esperado: mem[0..14] (base=0, byte 0..56) = 1 3 5 6 8 9 11 12 14 17 19 21 24 27 30

# Registros (heapify escribe x10..x15; x6/x7/x8/x9 sobreviven a la llamada):
#   x8  = base del array (= 0)       x9  = n = 15
#   x6  = contador build_heap        x7  = limite sort (end)
#   x10 = size (arg)  x11 = i (arg)/temp  x12 = largest
#   x13/x14/x15 = hijo / &arr / valores temp

# Branches: el procesador solo tiene c.beqz/c.bnez (comparan vs 0). Las
# comparaciones de aqui son entre dos registros o "< 0 / <= 0", asi que
# se quedan en 32 bits (no comprimibles). El resto se comprime.
# NOTA: los valores del array son <= 30 para que entren en el inmediato de
# 6 bits con signo de c.li ([-32,31]).


# init: cargar el array con c.li + c.sw usando x8 como puntero base explicito

    c.li x8, 0             # base = 0
    c.li x10, 14           # arr[0]
    c.sw x10, 0(x8)
    c.li x10, 3            # arr[1]
    c.sw x10, 4(x8)
    c.li x10, 27           # arr[2]
    c.sw x10, 8(x8)
    c.li x10, 8            # arr[3]
    c.sw x10, 12(x8)
    c.li x10, 21           # arr[4]
    c.sw x10, 16(x8)
    c.li x10, 11           # arr[5]
    c.sw x10, 20(x8)
    c.li x10, 1            # arr[6]
    c.sw x10, 24(x8)
    c.li x10, 19           # arr[7]
    c.sw x10, 28(x8)
    c.li x10, 6            # arr[8]
    c.sw x10, 32(x8)
    c.li x10, 30           # arr[9]
    c.sw x10, 36(x8)
    c.li x10, 24           # arr[10]
    c.sw x10, 40(x8)
    c.li x10, 9            # arr[11]
    c.sw x10, 44(x8)
    c.li x10, 17           # arr[12]
    c.sw x10, 48(x8)
    c.li x10, 5            # arr[13]
    c.sw x10, 52(x8)
    c.li x10, 12           # arr[14]
    c.sw x10, 56(x8)
    c.li x9, 15            # n = 15


# build_heap: for i = n/2-1 .. 0 -> heapify(n, i)

    c.li x6, 6             # i = n/2 - 1 = 6
build_loop:
    blt  x6, x0, sort_init # 32b: i < 0 -> heap construido
    c.mv x10, x9           # size = n
    c.mv x11, x6           # i    = contador
    c.jal heapify          # jal x1, heapify
    c.addi x6, -1
    c.j  build_loop


# sort: for end = n-1 .. 1 -> swap(arr[0],arr[end]); heapify(end, 0)

sort_init:
    addi x7, x9, -1        # 32b (rd!=rs1): end = n - 1 = 14
sort_loop:
    bge  x0, x7, fin       # 32b: end <= 0 -> ordenado
    c.lw x12, 0(x8)        # arr[0]
    slli x13, x7, 2        # 32b (rd!=rs1)
    c.add x13, x8          # &arr[end]
    c.lw x14, 0(x13)       # arr[end]
    c.sw x14, 0(x8)        # arr[0]   = arr[end]
    c.sw x12, 0(x13)       # arr[end] = arr[0]
    c.mv x10, x7           # size = end
    c.li x11, 0            # i    = 0
    c.jal heapify
    c.addi x7, -1
    c.j  sort_loop
fin:
    c.j  fin               # loop infinito = punto de parada


# heapify(size=x10, i=x11); sift-down iterativo, unica subrutina

heapify:
heapify_loop:
    c.mv x12, x11          # largest = i
    slli x13, x11, 1       # 32b (rd!=rs1)
    c.addi x13, 1          # l = 2*i + 1
    bge  x13, x10, h_done  # 32b: l >= size
    slli x14, x13, 2       # 32b
    c.add x14, x8
    c.lw x14, 0(x14)       # arr[l]
    slli x15, x12, 2       # 32b
    c.add x15, x8
    c.lw x15, 0(x15)       # arr[largest]
    bge  x15, x14, h_check_r # 32b: arr[largest] >= arr[l]
    c.mv x12, x13          # largest = l
h_check_r:
    c.addi x13, 1          # r = 2*i + 2
    bge  x13, x10, h_done  # 32b: r >= size
    slli x14, x13, 2       # 32b
    c.add x14, x8
    c.lw x14, 0(x14)       # arr[r]
    slli x15, x12, 2       # 32b
    c.add x15, x8
    c.lw x15, 0(x15)       # arr[largest]
    bge  x15, x14, h_done  # 32b: arr[largest] >= arr[r]
    c.mv x12, x13          # largest = r
h_done:
    beq  x12, x11, h_ret   # 32b: largest == i -> ya cumple max-heap
    slli x13, x11, 2       # 32b
    c.add x13, x8          # &arr[i]
    slli x14, x12, 2       # 32b
    c.add x14, x8          # &arr[largest]
    c.lw x11, 0(x13)       # tmp = arr[i]  (x11=i ya no se necesita)
    c.lw x15, 0(x14)       # arr[largest]
    c.sw x15, 0(x13)       # arr[i]   = arr[largest]
    c.sw x11, 0(x14)       # arr[largest] = tmp
    c.mv x11, x12          # i = largest
    c.j  heapify_loop
h_ret:
    c.jr x1                # ret
