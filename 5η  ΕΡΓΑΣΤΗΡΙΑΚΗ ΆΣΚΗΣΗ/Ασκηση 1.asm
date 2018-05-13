
.include "m16def.inc"
.def temp=r20
.def m1=r16     //metrhths kurios programmatos
.def m2=r18     //plhthos diakopon
jmp start
.org 0x4
jmp ISR1
reti

start:
ldi temp,low(RAMEND)    //arxikopoihsh tou deikth stibas afou ginetai klhsh routinas
out SPL,temp
ldi temp,high(RAMEND)
out SPH,temp
ser temp
out DDRB,temp     //h A,B os e9odoi
out DDRA,temp
clr temp              //o D einai h eisodos
out DDRD,temp
ldi temp, (1<<ISC11) | (1<<ISC10)  //shma thetikhs akmhs
out MCUCR,temp
ldi temp, (1<<INT1)   //energopoihsh INT1
out GICR,temp
sei                   // enegropoihsh diakopon
clr m2                
clr m1
loop:
rcall Delay       //kalo thn xronokathisterish 0,2sec
inc m1            //auksanetai o metrhths
out PORTB,m1      //emfanise metrhth kai plithos diakopon
out PORTA,m2
jmp loop

ISR1:
loop1:
	ldi temp, 0b10000000
	out GIFR, temp				
msec5Delay:				;texnhth xronokathusterhsh 5 msec opos dothike stis ekfoniseis ths prohgoumenhs seiras
	ldi r24,low(5)
	ldi r25,high(5)
m_sec1:			
	push r24
	push r25
	ldi r24,low(998)
	ldi r25,high(998)
wait_usecBlock1:
	sbiw r24,1
	nop
	nop
	nop
	nop
	brne wait_usecBlock1
	pop r25
	pop r24
	sbiw r24,1
	brne m_sec1
	
	in temp, GIFR         
	andi temp, 0b10000000     //elegxos gia to an egine klhsh diakophs se ligotero apo 5msec. an egine simenei oti egine spinthirismos ara thn agnooume.
	cpi temp, 0b10000000
	breq loop1
in temp,PIND          //elegxos gia to PD7. an einai 1 tote prosmetrountai oi diakopes allios agnoountai
sbrc temp,7
inc m2                //aukshsh tou metrith

out PORTA,m2 
reti

Delay:                   //xronokathisterish 0,2 sec
	ldi r24,low(200)
	ldi r25,high(200)
m_sec:			
	push r24
	push r25
	ldi r24,low(998)
	ldi r25,high(998)
wait_usecBlock:
	sbiw r24,1
	nop
	nop
	nop
	nop
	brne wait_usecBlock
	pop r25
	pop r24
	sbiw r24,1
	brne m_sec
ret
	

