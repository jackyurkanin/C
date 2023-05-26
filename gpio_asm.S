.section .text      # indicates a code segment
.align 2            # specifies how data should be arranged in memory
.globl pinSetup   # makes pinSetup able to be used outside of this file
.globl pinWrite     # makes pinWrite able to be used outside of this file
.globl pinRead      # makes pinRead able to be used outside of this file
.globl setPixel     # makes setPixel able to be used outside of this file
.globl eraseBuffer  # makes eraseBuffer able to be used outside of this file

# C declaration: int pinRead(int pin_num)
# ARGUMENTS a0: pin_num
# RETURNS bit read from GPIO pin 
pinRead:
    li a2, 0x6000403C   # GPIO_IN_ADDR
    lw a1, 0(a2)
    srl a1, a1, a0
    andi a0, a1, 1
    ret


# C declaration: void pinWrite(int pin_num, int value)
# ARGUMENTS a0: pin_num, a1: value
# RETURNS: Nothing
pinWrite:
    li a2, 0x60004004   # GPIO_OUT_ADDR
    lw a3, 0(a2)
    beqz a1, z
    sll a1, a1, a0
    or a0, a1, a3
    j d
z:
    addi a1, a1, 1
    sll a1, a1, a0
    not a4, a1
    and a0, a3, a4

d:
    sw a0, 0(a2)
    ret



# C declaration: void pinSetup(int pin_num, int mode)
# ARGUMENTS a0: pin_num, a1: mode
# RETURNS: Nothing
pinSetup:
    li a2, 0x60009004   # IO_MUX_GPIOn_ADDR
    li a3, 0x60004020   # GPIO_ENABLE_ADDR
    addi a6, zero, 1
    bnez a1, o
    slli a5, a0, 2
    add a2, a2, a5
    lw a4, 0(a2)
    slli a0, a6, 8
    or a4, a4, a0
    slli a0, a0, 1
    or a4, a4, a0
    sw a4, 0(a2)
    ret
o:
    lw a4, 0(a3)
    sll a0, a6, a0
    or a4, a4, a0
    sw a4, 0(a3)
    ret
 


# C declaration: void setPixel(uint32_t* screen_buffer_addr, uint8_t x, uint8_t y, uint8_t val)
# ARGUMENTS a0: screen buffer starting address, a1: x, a2: y, a3: val
# RETURNS: Nothing
setPixel:
    slli a2, a2, 2
    add a0, a0, a2
    lw a4, 0(a0)
    beqz a3, ze
    sll a3, a3, a1
    or a4, a4, a3
    j don
ze:
    addi a5, zero, 1
    sll a5, a5, a1
    not a5, a5
    and a4, a4, a5
don:
    sw a4, 0(a0)
    ret


# C declaration: void eraseBuffer(uint32_t* screen_buffer_addr)
# ARGUMENTS a0: screen_buffer starting address
# RETURNS: Nothing
eraseBuffer:
    li a1, 8            # upper bound on for loop
    li a2, 0            # "i" for for loop
looping: 
    slli a3, a2, 2      # calculate 4*i
    add a4, a0, a3      # get address of array element by adding base address + 4*i 
    sw zero, 0(a4)      # write 0 to memory address
    addi a2, a2, 1      # increment i 
    bne a2, a1, looping # continue looping if i < 8
    ret                 # return from eraseBuffer