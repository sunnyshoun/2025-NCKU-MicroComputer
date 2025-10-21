#include "xc.inc"
BCF WDTCON, 0
GLOBAL _count_primes
PSECT mytext, local, class=CODE, reloc=2

_count_primes:
    ; current_n
    MOVFF 0x01, 0x31
    MOVFF 0x02, 0x30
    ; m
    MOVFF 0x03, 0x33
    MOVFF 0x04, 0x32

    ; count
    CLRF 0x40
    CLRF 0x41
    
    ; check if m == 0xFFFF (65535), if so m -= 1 to prevent overflow
    MOVF 0x32, W
    SUBLW 0xFF
    BNZ check_loop
    MOVF 0x33, W
    SUBLW 0xFF
    BNZ check_loop
    ; m == 65535, decrement m (65535 is not prime anyway)
    DECF 0x33, F
    BTFSS STATUS, 0 ; check if borrow: high byte -= 1
    DECF 0x32, F

    check_loop:
        ; if current_n > m, done
        MOVF 0x31, W
        SUBWF 0x33, W
        MOVF 0x30, W
        SUBWFB 0x32, W
        BNC done_count

        RCALL check_prime

        ;n += 1
        INCF 0x31, F
        BTFSC STATUS, 2 ; check if overflow: high byte += 1
        INCF 0x30, F

        GOTO check_loop

    done_count:
        MOVFF 0x41, 0x01
        MOVFF 0x40, 0x02
        RETURN

check_prime:
    ; i = 1
    CLRF 0x24
    MOVLW 0x01
    MOVWF 0x25 

    ; check if n != 1, do check_prime_loop
    ; if n_low != 1, do check_prime_loop
    DECF 0x31, W
    BNZ check_prime_loop
    ; if n_high != 0, do check_prime_loop
    MOVF 0x30, F
    BNZ check_prime_loop

    ; n == 1, return not_prime
    GOTO not_prime
    
    check_prime_loop:
        MOVFF 0x30, 0x20 ; n high
        MOVFF 0x31, 0x21 ; n low
        ;i += 1
        INCF 0x25, F
        BTFSC STATUS, 2 ; check if overflow: high byte += 1
        INCF 0x24, F

        ; i*i save to res[0x50:0x51]
        ; Result = i_low^2 + 2*i_high*i_low*256 + i_high^2*65536
        MOVF 0x25, W
        MULWF 0x25
        MOVFF PRODL, 0x51
        MOVFF PRODH, 0x50

        MOVF 0x24, W
        MULWF 0x25
        MOVF PRODL, W
        ADDWF 0x50, F
        MOVF PRODL, W
        ADDWF 0x50, F

        ; if i*i > n, return prime
        MOVF 0x51, W
        SUBWF 0x31, W
        MOVF 0x50, W
        SUBWFB 0x30, W
        BNC prime

        ; if n % i == 0, return not_prime
        RCALL division
        TSTFSZ 0x12
            GOTO check_prime_loop
        TSTFSZ 0x13
            GOTO check_prime_loop
        GOTO not_prime

    not_prime:
        RETURN
    prime:
        INCF 0x41, F
        BTFSC STATUS, 2 ; check if overflow: high byte += 1
        INCF 0x40, F
	RETURN

division: ;a[0x20:0x21] / b[0x24:0x25]
    ; Quotient
    CLRF 0x10
    CLRF 0x11
    ; Remainder
    CLRF 0x12
    CLRF 0x13
    
    ; [0x14] set i as 16
    MOVLW 0x10
    MOVWF 0x14
    
division_loop:
    BCF STATUS, 0
    RLCF 0x21, F
    RLCF 0x20, F
    
    RLCF 0x13, F
    RLCF 0x12, F
    
    MOVF 0x24, W
    SUBWF 0x12, W
    BNC next_bit
    BNZ do_subtract
    
    MOVF 0x25, W
    SUBWF 0x13, W
    BNC next_bit
    
do_subtract:
    MOVF 0x25, W
    SUBWF 0x13, F

    MOVF 0x24, W
    SUBWFB 0x12, F
    
    BSF 0x21, 0
    
next_bit:
    DECFSZ 0x14, F
    GOTO division_loop
    
    MOVFF 0x20, 0x10
    MOVFF 0x21, 0x11
    
    RETURN