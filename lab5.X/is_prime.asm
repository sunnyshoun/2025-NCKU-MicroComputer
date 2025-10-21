#include "xc.inc"
BCF WDTCON, 0
GLOBAL _is_prime
PSECT mytext, local, class=CODE, reloc=2

_is_prime:
    MOVWF 0x20 ; input number
    MOVWF 0x22
    
    DECF 0x20, W
    BNZ setup_loop
    GOTO not_prime
    setup_loop:
        MOVLW 0x01
        MOVWF 0x21 ; i = 1
        GOTO check_prime

    check_prime:
        MOVFF 0x22, 0x20
        INCF 0x21, F ; i++

        ; if i*i > n, return prime
        MOVF 0x21, W
        MULWF 0x21
        MOVF PRODL, W
        SUBWF 0x20, W
        BNC prime

        ; if n % i == 0, return not_prime
        RCALL division
        TSTFSZ 0x11
            GOTO check_prime
        GOTO not_prime

    not_prime:
        MOVLW 0x00
        RETURN
    prime:
        MOVLW 0xFF
	RETURN

division: ;0x20 / 0x21
    CLRF 0x10
    CLRF 0x11
    
    ; [0x14] set i as 8
    MOVLW 0x08
    MOVWF 0x14
    
division_loop:
    BCF STATUS, 0
    RLCF 0x20, F
    
    RLCF 0x11, F
    
    MOVF 0x21, W
    SUBWF 0x11, W
    BNC next_bit

do_subtract:
    MOVF 0x21, W
    SUBWF 0x11, F
    
    BSF 0x20, 0
    
next_bit:
    DECFSZ 0x14, F
    GOTO division_loop
    
    MOVFF 0x20, 0x10
    
    RETURN