#include "setting_hardaware/setting.h"
#include <xc.h>
#include <stdio.h>
#include "setting_hardaware/uart.h"

// Global variable for counter
volatile unsigned int counter = 0;

void __interrupt(high_priority) Hi_ISR(void)
{
    // Handle INT0 (RB0) Interrupt
    if(INTCONbits.INT0IF)
    {
        // Simple Debounce: Delay
        for(int i=0; i<3000; i++);

        // Check if button is really pressed (Active Low)
        if(PORTBbits.RB0 == 0)
        {
            unsigned int old_val = counter;
            counter++;
            if(counter > 15) counter = 0; // Modulo 16

            // Update LEDs (RD4-RD7)
            LATD = (LATD & 0x0F) | (counter << 4);

            // Update UART: Backspace old value, write new value
            int digits = (old_val >= 10) ? 2 : 1;
            for(int i=0; i<digits; i++) UART_Write('\b');
            for(int i=0; i<digits; i++) UART_Write(' ');
            for(int i=0; i<digits; i++) UART_Write('\b');

            char str_buf[10];
            sprintf(str_buf, "%d", counter);
            UART_Write_Text(str_buf);

            // Wait for release to avoid multiple counts
            while(PORTBbits.RB0 == 0);
        }
        
        // Clear INT0 Flag
        INTCONbits.INT0IF = 0;
    }
}

void main(void) {
    SYSTEM_Initialize(); // Init Osc, UART, Interrupts

    // GPIO Config
    TRISBbits.TRISB0 = 1; // RB0 Input
    TRISD &= 0x0F;        // RD4-RD7 Output
    LATD &= 0x0F;         // Clear LEDs

    // INT0 Config
    INTCONbits.INT0IF = 0;   // Clear flag
    INTCON2bits.INTEDG0 = 0; // Trigger on Falling Edge
    INTCONbits.INT0IE = 1;   // Enable INT0 Interrupt

    // Initial Display
    UART_Write_Text("0");
    
    while(1) {
    }
}