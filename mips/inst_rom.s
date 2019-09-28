.org 0x0            # start from 0x0
.global __start      # difine global symbol "_start"
.set noat           # free to use register $1

__start:

ori     $1, $0, 0x8000
sll     $1, $1, 16
ori     $1, $1, 0x0010

ori     $2, $0, 0x8000
sll     $2, $2, 16
ori     $2, $2, 0x0001

ori     $3, $0, 0x0000
addu    $3, $2, $1
ori     $3, $0, 0x0000
add     $3, $2, $1

sub     $3, $1, $3
subu    $3, $3, $2

addi    $3, $3, 2
ori     $3, $0, 0x0000
addiu   $3, $3, 0x8000

or      $1, $0, 0xffff
sll     $1, $1, 16
slt     $2, $1, $0
sltu    $2, $1, $0
slti    $2, $1, 0x8000
sltiu   $2, $1, 0x8000

lui     $1, 0x0000
clo     $2, $1
clz     $2, $1

lui     $1, 0xffff
ori     $1, $1, 0xffff
clz     $2, $1
clo     $2, $1

lui     $1, 0xa100
clz     $2, $1
clo     $2, $1

lui     $1, 0x1100
clz     $2, $1
clo     $2, $1

ori     $1, $0, 0xffff
sll     $1, $1, 16
ori     $1, $1, 0xfffb
ori     $2, $0, 6
mul     $3, $1, $2

mult    $1, $2

multu   $1, $2

nop
nop

; lui     $1, 0x0000
; lui     $2, 0xffff
; lui     $3, 0x0505
; lui     $4, 0x0000
; movz    $4, $2, $1
; movn    $4, $3, $1
; movn    $4, $3, $2
; movz    $4, $2, $3
; mthi    $0
; mthi    $2
; mthi    $3
; mfhi    $4
; mtlo    $3
; mtlo    $2
; mtlo    $1
; mflo    $4

; lui     $2, 0x0404
; ori     $2, $2, 0x0404
; ori     $7, $0, 0x7
; ori     $5, $0, 0x5
; ori     $8, $0, 0x8
; sll     $2, $2, 8
; sllv    $2, $2, $7
; srl     $2, $2, 8
; srlv    $2, $2, $5
; nop
; sll     $2, $2, 19
; ssnop
; sra     $2, $2, 16
; srav    $2, $2, $8

; lui     $1, 0x0101
; ori     $1, $1, 0x0101
; ori     $2, $1, 0x1100
; or      $1, $1, $2
; andi    $3, $1, 0x00fe
; and     $1, $3, $1
; xori    $4, $1, 0xff00
; xor     $1, $4, $1
; nor     $1, $4, $1
