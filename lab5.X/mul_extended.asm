#include <xc.inc>
    
GLOBAL _mul_extended
    
PSECT text3, local, class=CODE, reloc=2
    
_mul_extended:
    ; n[0x05:0x06]
    MOVF 0x01, W
    MOVWF 0x05
    MOVF 0x02, W
    MOVWF 0x06
    
    ; m[0x07:0x08]
    MOVF 0x03, W
    MOVWF 0x07
    MOVF 0x04, W
    MOVWF 0x08

    ; check if n is negative
    BTFSS 0x06, 7
    GOTO n_positive

    ; n is negative, convert to positive (two's complement)
    COMF 0x05, F
    COMF 0x06, F
    INCF 0x05, F
    BTFSC STATUS, 0
    INCF 0x06, F

    ; sign_flag[0x09] = 1
    MOVLW 0x01
    MOVWF 0x09
    GOTO check_m
    
n_positive:
    CLRF 0x09

check_m:
    ; check if m is negative
    BTFSS 0x08, 7
    GOTO m_positive
    
    ; m is negative, convert to positive
    COMF 0x07, F
    COMF 0x08, F
    INCF 0x07, F
    BTFSC STATUS, 0
    INCF 0x08, F

    ; toggle sign_flag
    MOVLW 0x01
    XORWF 0x09, F

m_positive:
    ; result[0x0A:0x0B:0x0C:0x0D] = 0
    CLRF 0x0A
    CLRF 0x0B
    CLRF 0x0C
    CLRF 0x0D

    ; n_low * m_low
    MOVF 0x05, W
    MULWF 0x07
    MOVFF PRODL, 0x0A
    MOVFF PRODH, 0x0B

    ; n_low * m_high
    MOVF 0x05, W
    MULWF 0x08
    MOVF PRODL, W
    ADDWF 0x0B, F
    MOVF PRODH, W
    ADDWFC 0x0C, F
    CLRF WREG
    ADDWFC 0x0D, F

    ; n_high * m_low
    MOVF 0x06, W
    MULWF 0x07
    MOVF PRODL, W
    ADDWF 0x0B, F
    MOVF PRODH, W
    ADDWFC 0x0C, F
    CLRF WREG
    ADDWFC 0x0D, F

    ; n_high * m_high
    MOVF 0x06, W
    MULWF 0x08
    MOVF PRODL, W
    ADDWF 0x0C, F
    MOVF PRODH, W
    ADDWFC 0x0D, F
    
    ; if sign_flag == 0, return result
    BTFSS 0x09, 0
    GOTO return_result

    ; negate result (two's complement)
    COMF 0x0A, F
    COMF 0x0B, F
    COMF 0x0C, F
    COMF 0x0D, F
    INCF 0x0A, F
    BTFSC STATUS, 0
    INCF 0x0B, F
    BTFSC STATUS, 0
    INCF 0x0C, F
    BTFSC STATUS, 0
    INCF 0x0D, F

return_result:
    MOVFF 0x0A, 0x01
    MOVFF 0x0B, 0x02
    MOVFF 0x0C, 0x03
    MOVFF 0x0D, 0x04

    RETURN