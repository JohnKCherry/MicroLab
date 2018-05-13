.include "m16def.inc"
.def temp = r16
.def counter = r17
.def flag = r18

.DSEG
_tmp_: .byte 2 

.CSEG
rjmp main


main:
	ldi temp, low(RAMEND)            ;orosmos tou deikth ths stoibas afou tha ginei klhsh routinon
	out spl, temp
	ldi temp, high(RAMEND)
	out sph, temp
	ldi temp, (1<<PC7)|(1<<PC6)|(1<<PC5)|(1<<PC4)	; eksodoi ta 4 MSB, eisodoi ta 4 LSB
	out DDRC, temp
	clr temp
	out PORTC, temp					; apenergopoihsh pull-up antistasewn
	ser temp
	out DDRB, temp					; PORTB os eksodos
	rcall scan_keypad_rising_edge			; klhsh gia thn arxikopoihsh tou _tmp_ se 0000
	
eternal_loop:
	ser flag						; flag <- FF

	rcall wait_for_keypad					; if first key pressed is 1 then flag <- 00
	sbrs r25, 4
	clr flag
	
	rcall wait_for_keypad					; if second key pressed is 6 then flag <- 00
	sbrs r25, 2
	clr flag
	
	tst flag						; if flag=00, den patithike o arithmos ths omadas mas (16) allios patithike
	breq incorrect_password
	
correct_password:
	rcall leds_on							; anamma twn leds ths thyras PORTB
	
	ldi r24, low(4000)						; xronokathisterisi 4 seconds = 4000ms
	ldi r25, high(4000)
	rcall wait_msec
	
	rcall leds_off
	rjmp eternal_loop						; synexis leitourgeia
	
incorrect_password:
	ldi counter, 8							; orismos plithous epanalipsewn sto 8
	
blink_loop:									
	ldi r24, low(250)
	ldi r25, high(250)
	rcall leds_on							; opote, ektelountai 8 epanalhpseis pou h kathemia
	rcall wait_msec							; krataei 0.25+0.25=0.5 sec, ara synolikos xronos 8*0.5=4 sec
	
	rcall leds_off
	ldi r24, low(250)
	ldi r25, high(250)
	rcall wait_msec
	dec counter
	brne blink_loop
	
	rjmp eternal_loop						; synexis leitourgeia
;************************************ Etoimes routines *****************************************
wait_usec:    
	sbiw r24 ,1
	nop
	nop
	nop
	nop
	brne wait_usec
	ret

wait_msec: 
	push r24
	push r25
	ldi r24 , low(998)
	ldi r25 , high(998)
	rcall wait_usec
	pop r25
	pop r24
	sbiw r24 , 1
	brne wait_msec
	ret

scan_row: 
	ldi r25 , 0x08
back_:
	lsl r25
	dec r24
	brne back_ 
	out PORTC , r25
	nop 
	nop
	in r24 , PINC
	andi r24 ,0x0f
	ret

scan_keypad: 
	ldi r24 , 0x01
	rcall scan_row 
	swap r24
	mov r27 , r24
	ldi r24 ,0x02
	rcall scan_row 
	add r27 , r24
	ldi r24 , 0x03
	rcall scan_row 
	swap r24
	mov r26 , r24
	ldi r24 ,0x04
	rcall scan_row 
	add r26 , r24
	movw r24 , r26
	ret

scan_keypad_rising_edge: 
	mov r22 ,r24
	rcall scan_keypad
	push r24
	push r25
	mov r24 ,r22
	ldi r25 ,0
	rcall wait_msec 
	rcall scan_keypad
	pop r23
	pop r22 
	and r24 ,r22 
	and r25 ,r23 
	ldi r26 ,low(_tmp_)
	ldi r27 ,high(_tmp_)
	ld r23 ,X+
	ld r22 ,X
	st X ,r24
	st -X ,r25
	com r23 
	com r22
	and r24 ,r22
	and r25 ,r23
	ret
;***********************************************************************************************

leds_on:
	ser temp
	out PORTB, temp
	ret
leds_off:
	clr temp
	out PORTB, temp
	ret

; edw kanoume synexes polling sto plhktrologio, mexri na patithei kapoio koumpi
; h plhroforia gia to koumpi pou paththike epistrefetai akrivw opws thn epistrefei kai h scan_keypad_rising_edge,
; stous kataaxwrites r24 kai r25.
wait_for_keypad:
	ldi r24, 20
	rcall scan_keypad_rising_edge
	tst r24
	brne next1
	tst r25
	breq wait_for_keypad
next1:
	ret

