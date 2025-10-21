#include <xc.h>
#pragma config WDT = OFF

// extern char is_prime(char n);
// void main(void){
//     volatile char ans = is_prime(2);
    
//     while(1);
//     return;
// }

extern unsigned int count_primes(unsigned int n, unsigned int m);
void main(void){
    volatile unsigned int ans = count_primes(1, 100);

    while(1);
    return;
}

// extern long mul_extended(int n, int m);
// void main(void){
//     volatile long ans = mul_extended(79, 997);

//     while(1);
//     return;
// }