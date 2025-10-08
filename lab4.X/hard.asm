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
    
    newtonSqrt:
        ; (N / x_n) -> [0x10:0x11]
        MOVFF 0x20, 0x00
        MOVFF 0x21, 0x01
        MOVFF 0x22, 0x02
        MOVFF 0x23, 0x03
        RCALL division
        
        ; [0x10:0x11] += x_n
        MOVF 0x23, W
        ADDWF 0x11, F
        MOVF 0x22, W
        ADDWFC 0x10, F
        
        ; ([0x10:0x11]) /= 2
        BCF STATUS, C
        RRCF 0x10, F
        RRCF 0x11, F

        ; if |x_n - x_(n+1)| == 0, done
        MOVF 0x22, W
        SUBWF 0x10, W
        BNZ newton_continue
        
        MOVF 0x23, W
        SUBWF 0x11, W
        BZ newton_done
        
    newton_continue:
        MOVFF 0x10, 0x22
        MOVFF 0x11, 0x23
        
        GOTO newtonSqrt
        
    newton_done:
        MOVFF 0x10, 0x24
        MOVFF 0x11, 0x25
        
        RETURN

    main:
        MOVLW 0xFE
        MOVWF 0x20
        MOVLW 0x01
        MOVWF 0x21
        MOVLW 0x55
        MOVWF 0x22
        MOVLW 0x66
        MOVWF 0x23
        
        RCALL newtonSqrt

    end