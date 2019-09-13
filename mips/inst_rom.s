.org 0x0            # start from 0x0
.global __start      # difine global symbol "_start"
.set noat           # free to use register $1

__start:

lui     $1, 0x0000
lui     $2, 0xffff
lui     $3, 0x0505
lui     $4, 0x0000
movz    $4, $2, $1
movn    $4, $3, $1
movn    $4, $3, $2
movz    $4, $2, $3
mthi    $0
mthi    $2
mthi    $3
mfhi    $4
mtlo    $3
mtlo    $2
mtlo    $1
mflo    $4

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
