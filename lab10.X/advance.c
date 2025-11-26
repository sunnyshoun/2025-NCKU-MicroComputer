#include "setting_hardaware/setting.h"
#include <xc.h>
#include <stdio.h>
#include "string.h"
#include "setting_hardaware/uart.h"

// Globals
volatile unsigned int counter = 0;       // Counter 0-15
volatile int t2_ticks = 0;               // Timer ticks accumulator
volatile int t2_threshold = 100;         // Default 1.0s (100 * 10ms)
char rx_buf[10];                         // UART Buffer
int rx_idx = 0;

// High Priority ISR: UART RX (Control Speed)
void __interrupt(high_priority) Hi_ISR(void)
{
    if(PIR1bits.RCIF)
    {
        char c = RCREG;
        
        if(c == '\r') // Enter key pressed
        {
            rx_buf[rx_idx] = '\0';
            if(strcmp(rx_buf, "1.0") == 0) {
                t2_threshold = 100;
            } 
            else if(rx_buf[0] == '0' && rx_buf[1] == '.') {
                int val = rx_buf[2] - '0';
                if(val >= 1 && val <= 9) t2_threshold = val * 10;
            }
            rx_idx = 0; // Reset buffer
        }
        else if(c != '\n' && rx_idx < 9)
        {
            rx_buf[rx_idx++] = c;
        }
        PIR1bits.RCIF = 0;
    }
}

// Low Priority ISR: Timer2 (Counting)
void __interrupt(low_priority) Lo_ISR(void)
{
    if(PIR1bits.TMR2IF)
    {
        PIR1bits.TMR2IF = 0;
        t2_ticks++;

        // Check if interval reached
        if(t2_ticks >= t2_threshold)
        {
            t2_ticks = 0;
            counter++;
            if(counter > 15) counter = 0;

            // Update LEDs (RD4-RD7)
            LATD = (LATD & 0x0F) | (counter << 4);
        }
    }
}

void main(void) {
    SYSTEM_Initialize();
    
    // GPIO Config: RD4-RD7 Output
    TRISD &= 0x0F;
    LATD &= 0x0F;

    // Timer2 Config: 10ms Interrupt
    // Fosc=4MHz, Tcy=1us. (124+1)*4*16*5 = 10000us = 10ms
    T2CONbits.T2OUTPS = 4; // Postscaler 1:5
    T2CONbits.T2CKPS = 2;  // Prescaler 1:16
    PR2 = 124;
    T2CONbits.TMR2ON = 1;  // Start Timer2

    // Interrupt Priority Config
    RCONbits.IPEN = 1;     // Enable Priority Levels
    
    // UART -> High Priority
    IPR1bits.RCIP = 1;
    PIE1bits.RCIE = 1;
    
    // Timer2 -> Low Priority
    IPR1bits.TMR2IP = 0;
    PIE1bits.TMR2IE = 1;
    PIR1bits.TMR2IF = 0;

    // Enable Interrupts
    INTCONbits.GIEH = 1;
    INTCONbits.GIEL = 1;

    UART_Write_Text("Advance Mode: Enter 0.1-1.0\r\n");

    while(1); // Logic handled in ISRs
}