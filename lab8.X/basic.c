#pragma config OSC = INTIO67
#pragma config PWRT = OFF
#pragma config BOREN = ON
#pragma config WDT = OFF
#pragma config PBADEN = OFF
#pragma config LVP = OFF
#pragma config CPD = OFF

#include <xc.h>
#include <pic18f4520.h>

#define _XTAL_FREQ 125000

volatile int state = 0;
int angles[] = {90, 180, 90, 0};

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
        
        while (PORTBbits.RB0 == 0);
        state = (state + 1) % 4;
        set_servo_angle(angles[state]);
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
    INTCONbits.GIE = 1;
    
    set_servo_angle(90);
    
    while(1) {
        
    }
    
    return;
}