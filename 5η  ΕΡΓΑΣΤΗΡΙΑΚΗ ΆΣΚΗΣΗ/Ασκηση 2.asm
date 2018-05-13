.include "m16def.inc"
.def temp=r20
.def m1=r16         //m1 einai o metriths gia to kurio meros ths askhshs. emfanizetai sta PB7-PB0
.def m2=r18         //einai o metriths 
.def reg=r21
.def temp1=r19
.def temp2=r17
jmp start
.org 0x4
jmp ISR2
reti

start:
ldi temp,low(RAMEND)   //  arxikopoihsh tou deikth ths stibas afou kaleitai routina
out SPL,temp
ldi temp,high(RAMEND)
out SPH,temp
ser temp               //oi D,C einai oi e9odoi
out DDRB,temp
out DDRC,temp
clr temp              //o A einai h eisodos
out DDRA,temp

ldi temp, (1<<ISC01) | (1<<ISC00)    //shma thetikhs akmhs
out MCUCR,temp
ldi temp, (1<<INT0)                  //energopoihsh diakophs INT0
out GICR,temp
sei                                 //energopoihsh diakopon
clr m1   
clr m2           

loop:
rcall Delay           //kalo thn xronokathisterish 0,2 sec
inc m1                    
out PORTB,m1         //emfanise ton metrhth m1 sthn eksodo B
out PORTC,temp2      //emfanise ton temp2 sthn e9odo C
jmp loop

ISR2:         
clr reg
ldi r22, 8      //8 epanalipseis thelo
clr r23         //metraei posa "1" exo dosei apo to PINA
in reg,PINA
loop1:          //metrao to plhthos ton "1"
lsr reg
brcc next 
inc r23
next:
dec r22
brne loop1
ldi temp1,1    
ldi temp2,0
loop2:       //sxhmatizo thn e9odo sto C me thn methodo tou OR
cpi r23,0
breq end
or temp2,temp1
lsl temp1
dec r23
jmp loop2

end:                //emfanise kai return
out PORTC, temp2
reti

Delay:
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
reti
	
