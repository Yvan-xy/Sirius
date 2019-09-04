.org 0x0            # start from 0x0
.global __start      # difine global symbol "_start"
.set noat           # free to use register $1

__start:
    ori     $1, $0, 0x1100
    ori     $2, $0, 0x0020
    ori     $3, $0, 0xff00
    ori     $4, $0, 0xffff
