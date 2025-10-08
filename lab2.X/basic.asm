List p=18f4520
    #include<p18f4520.inc>
    CONFIG OSC = INTIO67
    CONFIG WDT = OFF
    org 0x00
    
    LFSR 0, 0x120
    MOVLW 0xA2
    MOVWF POSTINC0
    MOVWF 0x00
    
    MOVLW 0xD9
    MOVWF POSTINC0
    MOVWF 0x01
    
    MOVLW 0x05
    MOVWF 0x02
    
    loop:
	MOVF 0x01, W
	BTFSC FSR0L, 0
	    GOTO odd
	even:
	    ADDWF 0x00, W
	    GOTO done_loop
	odd:
	    SUBWF 0x00, W
	done_loop:
	    MOVWF POSTINC0
	    MOVFF 0x01, 0x00
	    MOVWF 0x01

	    DECF 0x02
	    TSTFSZ 0x02
	    GOTO loop
    end