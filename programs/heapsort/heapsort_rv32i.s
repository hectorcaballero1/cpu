# Heapsort con instrucciones de 32 bits (RV32I)

# Array de 15 enteros cargado en dmem a partir de la direccion base 0.
# Entrada : 14 3 27 8 21 11 1 19 6 30 24 9 17 5 12
# Esperado: mem[0..14] (base=0, byte 0..56) = 1 3 5 6 8 9 11 12 14 17 19 21 24 27 30

# Registros (heapify escribe x10..x15; asi x6/x7/x8/x9 sobreviven a la llamada):
#   x8  = base del array (= 0)
#   x9  = n = 15
#   x6  = contador de build_heap (i = n/2-1 .. 0)
#   x7  = limite de sort (end = n-1 .. 1)
#   x10 = size (arg de heapify)      x11 = i (arg de heapify) / temp
#   x12 = largest                    x13 = hijo (l/r) / &arr / temp
#   x14 = &arr / valor temp          x15 = &arr / valor temp

# init: cargar el array con li + sw usando x8 como puntero base explicito
    addi x8, x0, 0          # base = 0
    addi x10, x0, 14        # arr[0]
    sw   x10, 0(x8)
    addi x10, x0, 3         # arr[1]
    sw   x10, 4(x8)
    addi x10, x0, 27        # arr[2]
    sw   x10, 8(x8)
    addi x10, x0, 8         # arr[3]
    sw   x10, 12(x8)
    addi x10, x0, 21        # arr[4]
    sw   x10, 16(x8)
    addi x10, x0, 11        # arr[5]
    sw   x10, 20(x8)
    addi x10, x0, 1         # arr[6]
    sw   x10, 24(x8)
    addi x10, x0, 19        # arr[7]
    sw   x10, 28(x8)
    addi x10, x0, 6         # arr[8]
    sw   x10, 32(x8)
    addi x10, x0, 30        # arr[9]
    sw   x10, 36(x8)
    addi x10, x0, 24        # arr[10]
    sw   x10, 40(x8)
    addi x10, x0, 9         # arr[11]
    sw   x10, 44(x8)
    addi x10, x0, 17        # arr[12]
    sw   x10, 48(x8)
    addi x10, x0, 5         # arr[13]
    sw   x10, 52(x8)
    addi x10, x0, 12        # arr[14]
    sw   x10, 56(x8)
    addi x9, x0, 15         # n = 15

# build_heap: for i = n/2-1 .. 0 -> heapify(n, i)

    addi x6, x0, 6          # i = n/2 - 1 = 6
build_loop:
    blt  x6, x0, sort_init  # i < 0 -> heap construido
    add  x10, x9, x0        # size = n
    add  x11, x6, x0        # i    = contador
    jal  x1, heapify
    addi x6, x6, -1
    jal  x0, build_loop


# sort: for end = n-1 .. 1 -> swap(arr[0],arr[end]); heapify(end, 0)

sort_init:
    addi x7, x9, -1         # end = n - 1 = 14
sort_loop:
    bge  x0, x7, fin        # end <= 0 -> ordenado
    lw   x12, 0(x8)         # arr[0]
    slli x13, x7, 2
    add  x13, x13, x8       # &arr[end]
    lw   x14, 0(x13)        # arr[end]
    sw   x14, 0(x8)         # arr[0]   = arr[end]
    sw   x12, 0(x13)        # arr[end] = arr[0]
    add  x10, x7, x0        # size = end
    addi x11, x0, 0         # i    = 0
    jal  x1, heapify
    addi x7, x7, -1
    jal  x0, sort_loop
fin:
    jal  x0, fin            # loop infinito = punto de parada


# heapify(size=x10, i=x11); sift-down iterativo, unica subrutina

heapify:
heapify_loop:
    add  x12, x11, x0       # largest = i
    slli x13, x11, 1
    addi x13, x13, 1        # l = 2*i + 1
    bge  x13, x10, h_done   # l >= size -> sin hijo izquierdo
    slli x14, x13, 2
    add  x14, x14, x8
    lw   x14, 0(x14)        # arr[l]
    slli x15, x12, 2
    add  x15, x15, x8
    lw   x15, 0(x15)        # arr[largest]
    bge  x15, x14, h_check_r # arr[largest] >= arr[l] -> no actualizar
    add  x12, x13, x0       # largest = l
h_check_r:
    addi x13, x13, 1        # r = 2*i + 2
    bge  x13, x10, h_done   # r >= size -> sin hijo derecho
    slli x14, x13, 2
    add  x14, x14, x8
    lw   x14, 0(x14)        # arr[r]
    slli x15, x12, 2
    add  x15, x15, x8
    lw   x15, 0(x15)        # arr[largest]
    bge  x15, x14, h_done   # arr[largest] >= arr[r] -> no actualizar
    add  x12, x13, x0       # largest = r
h_done:
    beq  x12, x11, h_ret    # largest == i -> ya cumple max-heap
    slli x13, x11, 2
    add  x13, x13, x8       # &arr[i]
    slli x14, x12, 2
    add  x14, x14, x8       # &arr[largest]
    lw   x11, 0(x13)        # tmp = arr[i]  (x11=i ya no se necesita)
    lw   x15, 0(x14)        # arr[largest]
    sw   x15, 0(x13)        # arr[i]   = arr[largest]
    sw   x11, 0(x14)        # arr[largest] = tmp
    add  x11, x12, x0       # i = largest
    jal  x0, heapify_loop
h_ret:
    jalr x0, x1, 0          # ret
