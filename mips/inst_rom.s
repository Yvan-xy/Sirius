.org 0x0            # start from 0x0
.global __start      # difine global symbol "_start"
.set noat           # free to use register $1

__start:
    ori     $1, $0, 0x1100
    ori     $1, $1, 0x0020
    ori     $1, $1, 0x4400
    ori     $1, $1, 0x0044
