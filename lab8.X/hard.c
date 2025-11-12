#pragma config OSC = INTIO67
#pragma config PWRT = OFF
#pragma config BOREN = ON
#pragma config WDT = OFF
#pragma config PBADEN = OFF
#pragma config LVP = OFF
#pragma config CPD = OFF

#include <xc.h>
#include <pic18f4520.h>
#include <stdbool.h>

#define _XTAL_FREQ 125000

volatile int t = 0;
volatile bool state = false;

void Set_PWM_Duty(unsigned int dutyValue) {
    CCPR1L = (unsigned char)(dutyValue >> 2); 
    CCP1CONbits.DC1B = (dutyValue & 0x03); 
}

void set_servo_angle(unsigned char angle) {
    unsigned int dutyValue;
    
    if (angle > 180) {
        angle = 180;
    }
    dutyValue = 16 + (unsigned int)((unsigned long)angle * 59 / 180);
    
    Set_PWM_Duty(dutyValue);
}

void __interrupt(high_priority) Hi_ISR(void) {
    if (INTCONbits.INT0IF == 1) {
        INTCONbits.INT0IF = 0;
        __delay_ms(20);
        
        if (PORTBbits.RB0 == 0) {
            while (PORTBbits.RB0 == 0);
            state = !state;
        }
    }
    
    if (PIR1bits.TMR1IF == 1) {
        PIR1bits.TMR1IF = 0;
        TMR1H = 0xFF;
        TMR1L = 0x25;
        if(state){
            t = (t+4) % 360;
            set_servo_angle(180 - abs((t % 360) - 180));
        }
    }
}

void main(void) {
    T2CONbits.TMR2ON = 0b1;
    T2CONbits.T2CKPS = 0b01;
    OSCCONbits.IRCF = 0b001;
    CCP1CONbits.CCP1M = 0b1100;
    TRISC = 0;
    LATC = 0;
    PR2 = 0x9B;

    TRISBbits.TRISB0 = 1;
    
    INTCON2bits.INTEDG0 = 0;
    INTCONbits.INT0IF = 0;
    INTCONbits.INT0IE = 1;
    
    T1CONbits.TMR1CS = 0;
    T1CONbits.T1CKPS = 0b11;
    TMR1H = 0xFF;
    TMR1L = 0x25;
    PIR1bits.TMR1IF = 0;
    PIE1bits.TMR1IE = 1;
    T1CONbits.TMR1ON = 1;
    
    INTCONbits.PEIE = 1;
    INTCONbits.GIE = 1;
    
    set_servo_angle(0);
    
    while(1) {
        
    }
    
    return;
}