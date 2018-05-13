#include <avr/io.h>
/*#define DDRC (* (int *)0x34)
#define PORTC (* (int *)0x35)
#define PINC (* (int *)0x33)
#define DDRA (* (int *)0x3A)
#define PORTA (* (int *)0x3B)
#define PINA (* (int *)0x39)*/
int main(void) {

unsigned char input;
unsigned char A;
unsigned char B;
unsigned char C;
unsigned char D;
unsigned char E; 
unsigned char F0;
unsigned char F1;
unsigned char F2;


	
	DDRA = 0x00;           //orizoume thn thura A os eisodo
	PORTA = 0x00;          //ta pull-up ths thuras eisodou A (den xreiazontai aparaithta)
	DDRC = 0xFF;           //orizoume thn thura C os eksodo
	
	while(1) {             //atermon epanalhpsh
	input = (PINA & 0x1F); //sto input exoume thn eisodo me maska 00011111 afou mas endiaferoun ta 5 prota bits
	A= (input & 0x01);     //A=000000x
	B= (input & 0x02);     //B=00000x0
	C= (input & 0x04);     //C=0000x00
	D= (input & 0x08);     //D=000x000
	E= (input & 0x10);     //E=00x0000, opou x 0 h 1
	
	F0 = ((A && B && C )) || (C && D) || (D && E);   //h logikh praksh gia thn F0. otan exoume && kanei thn sugkrisi leksis. to F0 einai 1 h 0
	F0 = !F0;                                        //sumbhroma tou F0
	F0 = F0 << 5;                                    //5 deksies olisthiseis oste na bgei sthn eksodo 00x00000
	
	
	F1=(A && B && C) || (!D && !E);                  //h logikh praksh gia thn F1.
	F1=F1<<6;                                        //6 deksies olisthiseis oste na bgei sthn eksodo 0x000000
	
	F2 = F0 || F1;                                   //h logikh praksh gia thn F2.
	F2=F2<<7;                                        //7 deksies olisthiseis oste na bgei sthn eksodo x0000000
	PORTC= F0 | F1 | F2;                             //logikh praksh OR ana bit metaksi ton F0,F1,F2 oste na emfanistei h eksodos sthn morfh F2 F1 F0 0 0 0 0 0
	}
return 0;
}

