.org 0x0            # start from 0x0
.global __start      # difine global symbol "_start"
.set noat           # free to use register $1

__start:

ori     $1, $0, 0xffff      
sll     $1, $1, 16          
ori     $1, $1, 0xfffb
ori     $2, $0, 6

mult    $1, $2              # hi = 0xffffffff lo = 0xffffffe2

madd    $1, $2              # hi = 0xffffffff lo = 0xffffffc4 

maddu   $1, $2              # hi = 0x5        lo = 0xffffffa6

msub    $1, $2              # hi = 0x5        lo = 0xffffffc4

msubu   $1, $2              # hi = 0xffffffff lo = 0xffffffe2


