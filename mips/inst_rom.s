.org 0x0
.set noat
.set noreorder  
.set nomacro
.global __start

__start:
    ori     $1, $0, 0x0001
    j       0x20
    ori     $1, $0, 0x0002
    ori     $1, $0, 0x1111
    ori     $1, $0, 0x1100


    .org 0x20
    ori     $1, $0, 0x0003
    jal     0x40
    div     $zero, $31, $1


    ori     $1, $0, 0x0005
    ori     $1, $0, 0x0006
    j       0x60
    nop


    .org 0x40
    jalr    $2, $31
    or      $1, $2, $0

    ori     $1, $0, 0x0009
    ori     $1, $0, 0x000a
    j       0x80
    nop

    .org 0x60
    ori     $1, $0, 0x0007
    jr      $2
    ori     $1, $0, 0x0008
    ori     $1, $0, 0x1111
    ori     $1, $0, 0x1100

    .org 0x80
    nop

_loop:
    j _loop
    nop  
