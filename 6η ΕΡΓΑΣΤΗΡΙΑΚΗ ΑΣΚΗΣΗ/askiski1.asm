.include "m16def.inc"  
.def x0=r16           ;arxikopoihsh ton kataxoriton pou xreisimopoioume
.def x1=r17
.def x2=r18
.def x3=r19
.def x4=r20
.def x5=r21
.def x6=r22
.def x7=r23
.def y0=r24
.def y1=r25
.def y2=r26
.def y3=r27
.def temp1=r28
.def temp=r29


ser temp             ;h B os eksodos
out DDRB,temp
clr temp             ;h A,C os eisodoi
out DDRA,temp
out DDRC,temp

loop:
clr temp             ;eisagogh ton timon stis metablhtes 
in temp,PINA         ;diabasma ths eisodou apo thn eisodo A
mov x0,temp          ;sto x0 bazo thn eisodo
andi x0,0x01         ;kai me thn maska 00000001 pairno to LSB 
ror temp             ;deksia olisthisi ths eisodou
mov x1,temp          ;omoios kai gia ta epomena
andi x1,0x01
ror temp
mov x2,temp
andi x2,0x01
ror temp
mov x3,temp
andi x3,0x01
ror temp
mov x4,temp
andi x4,0x01
ror temp
mov x5,temp
andi x5,0x01
ror temp
mov x6,temp
andi x6,0x01
ror temp
mov x7,temp
andi x7,0x01

eor x0,x1    ;ginetai h logikh praksh x0 = x0 xor x1, to apotelesma sto x0
andi x0,0x01 ;apomononoume to LSB
or x2,x3     ;x2 = x2 or x3
and x0,x2    ;x0= (x0 xor x1) and (x2 or x3)
mov y0,x0    ;to apotelesma sto y0
mov y1,x2    ;to x2 sto y1 to opoio theloume na emfanish
or x4,x5     ;x4=x4 or x5
com x4       ;x4= x4 nor x5
andi x4,0x01 
mov y2,x4    ;to apotelesma sto y2
andi y2,0x01
eor x6,x7    ;x6=x6 xor x7
andi x6,0x01
com x6       ;x6=x6 nxor x7
andi x6,0x01
mov y3,x6    ;sto y3 to apotelesma
andi y3,0x01
bclr 0       ;h shmaia c=0
rol y1       ;mia olisthish gia na paei to y1 sthn sosth thesh 
rol y2       ;dio olisthiseis gia na paei sthn sosth thesh to y2
rol y2       
rol y3       ;tris olisthiseis gia ton idio logo
rol y3
rol y3
or y0,y1     ;sxhmatismos ths eksodou y0= y0 | y1 | y2
or y0,y2
or y0,y3
in temp,PINC ;diabasma ths eisodou C 

eor y0,temp  ;PINC xor y0, oste na antistrafei h endeiksh ton leds pou stis antistoixes theseis einai 1
out PORTB, y0 ;emfanish ths eksodou
jmp loop

