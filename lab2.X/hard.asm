List p=18f4520
    include<p18f4520.inc>
    CONFIG OSC = INTIO67
    CONFIG WDT = OFF
    org 0x00
    
    setup:
	LFSR 0, 0x320
	MOVLW 0xC4
	MOVWF POSTINC0
	MOVLW 0xBB
	MOVWF POSTINC0
	MOVLW 0xBB
	MOVWF POSTINC0
	MOVLW 0x00
	MOVWF POSTINC0
	MOVLW 0x4C
	MOVWF POSTINC0
	MOVLW 0x8B
	MOVWF POSTINC0
	MOVLW 0xBB
	MOVWF POSTINC0
	MOVLW 0x00
	MOVWF POSTINC0
	LFSR 0, 0x320
	
	;[0x00] set i as 7
	MOVLW 0x07
	MOVWF 0x00
	
    main:
	loop_i:
	    LFSR 0, 0x320
	    LFSR 1, 0x321
	    
	    ;[0x01] set j as 7
	    MOVLW 0x07
	    MOVWF 0x01
	    GOTO loop_j
	    done_loop_j:
		DECF 0x00
		TSTFSZ 0x00 
		    GOTO loop_i
	GOTO find_pairs
	loop_j:
	    MOVF INDF1, W
	    CPFSLT INDF0
		GOTO bubble_swap
		done_bubble_swap:
	    MOVF POSTINC0, W
	    MOVF POSTINC1, W
	    DECF 0x01
	    TSTFSZ 0x001
		GOTO loop_j
	    GOTO done_loop_j
	bubble_swap:
	    MOVFF INDF0, 0x02
	    MOVFF INDF1, INDF0
	    MOVFF 0x02, INDF1
	    GOTO done_bubble_swap
	find_pairs:
	    LFSR 0, 0x320
	    LFSR 1, 0x17
	    CLRF 0x03 ;temp
	    CLRF 0x04 ;pair_times
	    
	    MOVLW 0x08
	    MOVWF 0x00
	    LFSR 2, 0x20 ;0x20: flag_array, 0x10:new_array
	    init_flag_array:
		CLRF POSTINC2
		DECF 0x00
		TSTFSZ 0x00 
		    GOTO init_flag_array
	    
	    MOVLW 0x08
	    MOVWF 0x00 ;i=8
	    loop_find_pair_i:
	        DECF 0x00
		TSTFSZ 0x00
		    GOTO do_loop_find_pair_i
		GOTO pair_done
		do_loop_find_pair_i:
		    MOVF FSR0L, W
		    ANDLW b'00011111'
		    ADDLW 0x20
		    MOVWF FSR2L
		    MOVFF POSTINC0, 0x03 ;temp = arr[i]
		    TSTFSZ INDF2
			GOTO loop_find_pair_i
		    MOVLW 0x01
		    MOVWF INDF2
		    CLRF 0x01 ;j=0
		    GOTO loop_find_pair_j
	    loop_find_pair_j:
		INCF 0x01
		MOVLW 0x08
		CPFSLT 0x01
		    GOTO loop_find_pair_i
		MOVLW 0x20
		ADDWF 0x01, W
		LFSR 2, 0x20
		MOVWF FSR2L
		TSTFSZ INDF2
		    GOTO loop_find_pair_j
		MOVLW 0x03
		MOVWF FSR2H
		SWAPF INDF2, W
		CPFSEQ 0x03
		    GOTO loop_find_pair_j
		MOVFF INDF2,  POSTDEC1
		MOVLW 0x00
		MOVWF FSR2H
		MOVLW 0x01
		MOVWF INDF2
		
		LFSR 2, 0x00
		MOVF 0x04, W
		ADDLW 0x10
		MOVWF FSR2L
		MOVFF 0x03,  INDF2
		INCF 0x04 ;pair_times++
		GOTO loop_find_pair_i
	    pair_done:
		LFSR 0, 0x30
		MOVLW 0x08
		MOVWF 0x00 ;i=8
		init_fail_array:
		    MOVLW 0xFF
		    MOVWF POSTINC0
		    DECF 0x00
		    TSTFSZ 0x00
			GOTO init_fail_array
	
	
		LFSR 0, 0x10
		LFSR 1, 0x320
		MOVLW 0x04
		CPFSEQ 0x04
		    LFSR 0, 0x30
		
		MOVLW 0x08
		MOVWF 0x00 ;i=8
		loop_copy:
		    MOVFF POSTINC0, POSTINC1
		    DECF 0x00
		    TSTFSZ 0x00
			GOTO loop_copy
    end