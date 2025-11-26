#include "setting_hardaware/setting.h"
#include <xc.h>
#include <stdio.h>
#include "setting_hardaware/uart.h"

// ADC Read function for Channel 0
int ADC_Read_AN0() {
    ADCON0bits.CHS = 0;   
    ADCON0bits.ADON = 1;  
    
    // Delay for acquisition
    for(int i=0; i<50; i++); 
    
    ADCON0bits.GO = 1;    
    while(ADCON0bits.GO); 
    
    return (ADRESH << 8) + ADRESL;
}

void main(void) {
    SYSTEM_Initialize();
    
    // Configure ADC and GPIO
    ADCON1 = 0x0E; // AN0 Analog
    ADCON2 = 0x92; // Right Justified
    TRISA = 0xFF;  // Input
    
    TRISD &= 0x0F; // RD4-RD7 Output
    LATD &= 0x0F;  // Clear LEDs
    
    int prev_adc = -1;
    
    while(1) {
        // Read ADC and invert value for direction
        int raw = ADC_Read_AN0();
        int adc = 1023 - raw; 
        
        // Ensure value is within valid range
        if(adc < 0) adc = 0;
        if(adc > 1023) adc = 1023;

        // Map ADC range 0-1023 to Output 4-15
        int val_map;
        if(adc < 85)       val_map = 4;
        else if(adc < 170) val_map = 5;
        else if(adc < 256) val_map = 6;
        else if(adc < 341) val_map = 7;
        else if(adc < 426) val_map = 8;
        else if(adc < 512) val_map = 9;
        else if(adc < 597) val_map = 10;
        else if(adc < 682) val_map = 11;
        else if(adc < 767) val_map = 12;
        else if(adc < 852) val_map = 13;
        else if(adc < 938) val_map = 14;
        else               val_map = 15;

        // Display mapped value on RD4-RD7
        LATD = (LATD & 0x0F) | (val_map << 4);
        
        // Update UART if ADC value changed
        if(adc != prev_adc) {
            
            if(prev_adc != -1) {

                int digits = 1;
                if(prev_adc >= 1000) digits = 4;
                else if(prev_adc >= 100) digits = 3;
                else if(prev_adc >= 10)  digits = 2;
                
                // Backspace old value
                for(int i=0; i<digits; i++) UART_Write('\b');
                for(int i=0; i<digits; i++) UART_Write(' ');
                for(int i=0; i<digits; i++) UART_Write('\b');
            }
            
            // write new ADC value
            char buf[10];
            sprintf(buf, "%d", adc);
            UART_Write_Text(buf);
            
            prev_adc = adc;
        }
    }
}