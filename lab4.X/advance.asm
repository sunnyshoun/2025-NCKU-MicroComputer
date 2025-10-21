List p=18f4520
    #include<p18f4520.inc>
    CONFIG OSC = INTIO67
    CONFIG WDT = OFF
    org 0x00
    
    GOTO main

    division: ;a / b
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
        BCF STATUS, C
        RLCF 0x01, F
        RLCF 0x00, F
        
        RLCF 0x13, F
        RLCF 0x12, F
        
        MOVF 0x02, W
        SUBWF 0x12, W
        BNC next_bit
        BNZ do_subtract
        
        MOVF 0x03, W
        SUBWF 0x13, W
        BNC next_bit
        
    do_subtract:
        MOVF 0x03, W
        SUBWF 0x13, F

        MOVF 0x02, W
        SUBWFB 0x12, F
        
        BSF 0x01, 0
        
    next_bit:
        DECFSZ 0x14, F
        GOTO division_loop
        
        MOVFF 0x00, 0x10
        MOVFF 0x01, 0x11
        
        RETURN

    main:
        ; Dividend
        MOVLW 0x55
        MOVWF 0x00

        MOVLW 0x55
        MOVWF 0x01

        ; Divisor
        MOVLW 0x55
        MOVWF 0x02

        MOVLW 0x55
        MOVWF 0x03

        RCALL division

    end