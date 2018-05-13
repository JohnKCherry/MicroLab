.include "m16def.inc"							; prosthhkh arxeiou kefalidas gia xeirismo thurwn E/E mesw twn sumvolikwn etiketwn tous
.def temp = r16
.def r24Temp = r17
.def r25Temp = r18
.def result = r19
.def counter = r20
.def dekadikos = r21							; ditimh logikh metavlhth (0: den exoume .5, 0xFF: exoume .5)
.def ekatontades = r22
.def dekades = r23
.def monades = r28
ldi temp, high(ramend)							; arxikopoihsh deikth stoivas, diadikasia APARAITHTH efoson exoume klhsh toulaxiston enos upoprogrammatos
out sph, temp
ldi temp, low(ramend)
out spl, temp
ldi temp, 0b11111100							; eksodoi ta 6 MSB, eisodoi ta 2 LSB ths thuras PORTD (gia xrhsh tou screen)
out DDRD, temp
main:

	ldi r24,0x20							// sthn othonh mporoun na emfanistoun to polu 8 xarakthres gia th thermokrasia
	rcall lcd_data							// se kathe epanalhpsh ths main, katharizoume thn othonh
	ldi r24,0x20
	rcall lcd_data						
	ldi r24,0x20						
	rcall lcd_data						
	ldi r24,0x20
	rcall lcd_data
	ldi r24,0x20
	rcall lcd_data
	ldi r24,0x20
	rcall lcd_data
	ldi r24,0x20
	rcall lcd_data
	ldi r24,0x20
	rcall lcd_data		
	ldi r24, 0x80							// thetoume ton kersora sthn arxh ths othonhs
	rcall lcd_command
	//rcall lcd_init						

	rcall temperatureRoutine					; klhsh routinas epistrofhs thermokrasias sto zeugos kataxwrhtwn r25:r24
	tst r24
	brne deviceOn
	cpi r25, 0x80
	brne deviceOn							; r25:r24 <> 0x8000 opote uparxei aisthhthrio
deviceOff:
	rcall messageOff
	rjmp main
deviceOn:
	rcall messageOn
	rjmp main

messageOff:
	rjmp labelOff
messageOFF1:
	.db 'N', 'o', ' ', 'D', 'e', 'v', 'i', 'c', 'e', 0x00
labelOff:		
	ldi zh, high(MessageOFF1*2)
	ldi zl, low(MessageOFF1*2)
	ldi counter, 9	
parse_loop0:
	lpm r24, Z
	rcall lcd_data
	adiw zl, 1
	dec counter
	brne parse_loop0
	ret

messageOn:
	clr dekadikos							; upothetoume oti den tha exei dekadiko .5 h thermokrasia
	tst r25
	breq thetikos
arnhtikos:
	com r24
	push r24
	ldi r24, 0x2D							; apostolh proshmou '-' sthn othonh
	rcall lcd_data
	pop r24
	rjmp apotimhsh
thetikos:
	push r24
	ldi r24, 0x2B							; apostolh proshmou '+' sthn othonh
	rcall lcd_data
	pop r24
apotimhsh:
	lsr r24
	brcc noDekadikos
	ser dekadikos
noDekadikos:

ekat_dek:
	ldi dekades, 0xff					
	ldi ekatontades, 0xff
ekat:
	inc ekatontades
	subi r24, 0x64							; inputValue -= 100
	brge ekat
	ldi temp, 0x64
	add r24, temp							; inputValue += 100
dek:
	inc dekades
	subi r24, 0x0a							; inputValue -= 10
	brge dek
	ldi temp, 0x0a
	add r24, temp							; inputValue += 10
mon:
	mov monades, r24
	ser temp
	out ddrb, temp
	out ddrc, temp
	out portb, dekades
	out portc, monades

print_dec:								
	ldi temp, 0							
	mov temp, monades
	add temp, dekades
	add temp, ekatontades
	tst temp							; an monades=dekades=ekatontades=0, tote tupwnei mhden (xwris proshmo) kai epistrefei
	brne prnte
	ldi r24, 48
	rcall lcd_data
	rjmp end_print
prnte:
	ldi temp,48							; apothikeuoume ston temp thn timh 48, gia xrhsh ston upologismo kwdikwn ascii																						
	tst ekatontades
	breq testd							; an oi ekatontades einai 0, elegxoume tis dekades (testd)
	add ekatontades, temp
	mov r24, ekatontades				; alliws tis emfanizoume kai proxwrame sthn emfanish twn dekadwn kai twn monadwn.
	rcall lcd_data
	rjmp prntd
testd:
	tst dekades							; an oi ekatontades einai 0, tote elegxoume tis dekades. an einai mhden tote emfanizoume
	breq prntm							; tis monades (pou de tha einai mhden afou mphkame edw), alliws emfanizoume dekades kai monades.
prntd:
	ldi temp,48								
	add dekades, temp
	mov r24, dekades
	rcall lcd_data
prntm:
	ldi temp,48								
	add monades, temp
	mov r24, monades
	rcall lcd_data
end_print:
	tst dekadikos
	breq sumvoloKelsiou
	ldi r24, 0x2E
	rcall lcd_data
	ldi r24, 0x35
	rcall lcd_data
sumvoloKelsiou:
	ldi r24, 0xB2							; emfanish '�' sthn othonh							
	rcall lcd_data
	ldi r24, 0x43							; emfanish 'C' sthn othonh
	rcall lcd_data
	ret


temperatureRoutine:
ldi r24, 0
ldi r25, 0x80									; upothetoume oti den einai sundedemenh suskeuh (kalupsh ksekremasths periptwshs)
mainSub:
	rcall one_wire_reset						; arxikopoihsh ths suskeuhs
	tst r24
	brne yesDevice1
noDevice1:
	ldi r25, 0x80
	ldi r24, 0
	ret
yesDevice1:
	ldi r24, 0xCC
	rcall one_wire_transmit_byte				
	ldi r24, 0x44
	rcall one_wire_transmit_byte
oloklhrwshMetrhshs:								; diavase ton kataxwrhth r24 mexris otou r24 = 1 <> 0
	rcall one_wire_receive_bit
	tst r24
	breq oloklhrwshMetrhshs
	rcall one_wire_reset						; ek neou arxikopoihsh ths suskeuhs
	tst r24
	brne yesDevice2
noDevice2:
	ldi r25, 0x80
	ldi r24, 0
	ret
yesDevice2:
	ldi r24, 0xCC
	rcall one_wire_transmit_byte
	ldi r24, 0xBE								; This command allows the master to read the contents
										; of the Scratchpad. It is 9-bytes long and it is
										; transferred starting with the ***LEAST*** significant byte. If all
										; bytes are not needed transfer can be stopped by master
										; issuing a reset.
	rcall one_wire_transmit_byte
	rcall one_wire_receive_byte
	mov r24Temp, r24							; LSB
	ldi r24, 0xBE
	rcall one_wire_receive_byte
	mov r25Temp, r24							; MSB
diamorfwshSumplhrwmatos:
	mov r24, r24Temp
	mov r25, r25Temp

	sbrc r25, 0
	dec r24

	ldi temp, 0xff
	out DDRA, temp								//????
	out PORTA, r24
	ret

;---------------------------------------------------------------------------------------------------------------------------------------------
; 
; File Name: one_wire.asm
; Title: one wire protocol
; Target mcu: atmega16
; Development board: easyAVR6
; Assembler: AVRStudio assembler
; Description:
; Routine: one_wire_receive_byte
; Description:
; This routine generates the necessary read
; time slots to receives a byte from the wire.
; return value: the received byte is returned in r24.
; registers affected: r27:r26 ,r25:r24
; routines called: one_wire_receive_bit
one_wire_receive_byte:
ldi r27 ,8
clr r26
loop_:
rcall one_wire_receive_bit
lsr r26
sbrc r24 ,0
ldi r24 ,0x80
or r26 ,r24
dec r27
brne loop_
mov r24 ,r26
ret
; Routine: one_wire_receive_bit
; Description:
; This routine generates a read time slot across the wire.
; return value: The bit read is stored in the lsb of r24.
; if 0 is read or 1 if 1 is read.
; registers affected: r25:r24
; routines called: wait_usec
one_wire_receive_bit:
sbi DDRA ,PA4
cbi PORTA ,PA4 ; generate time slot
ldi r24 ,0x02
ldi r25 ,0x00
rcall wait_usec
cbi DDRA ,PA4 ; release the line
cbi PORTA ,PA4
ldi r24 ,10
; wait 10 탎
ldi r25 ,0
rcall wait_usec
clr r24
; sample the line
sbic PINA ,PA4
ldi r24 ,1
push r24
ldi r24 ,49
; delay 49 탎 to meet the standards
ldi r25 ,0
; for a minimum of 60 탎ec time slot
rcall wait_usec ; and a minimum of 1 탎ec recovery time
pop r24
ret

; Routine: one_wire_transmit_byte
; Description:
; This routine transmits a byte across the wire.
; parameters:
; r24: the byte to be transmitted must be stored here.
; return value: None.
; registers affected: r27:r26 ,r25:r24
; routines called: one_wire_transmit_bit
one_wire_transmit_byte:
mov r26 ,r24
ldi r27 ,8
_one_more_:
clr r24
sbrc r26 ,0
ldi r24 ,0x01
rcall one_wire_transmit_bit
lsr r26
dec r27
brne _one_more_
ret
; Routine: one_wire_transmit_bit
; Description:
; This routine transmits a bit across the wire.
; parameters:
; r24: if we want to transmit 1
; then r24 should be 1, else r24 should
; be cleared to transmit 0.
; return value: None.
; registers affected: r25:r24
; routines called: wait_usec
one_wire_transmit_bit:
push r24
; save r24
sbi DDRA ,PA4
cbi PORTA ,PA4 ; generate time slot
ldi r24 ,0x02
ldi r25 ,0x00
rcall wait_usec
pop r24
; output bit
sbrc r24 ,0
sbi PORTA ,PA4
sbrs r24 ,0
cbi PORTA ,PA4
ldi r24 ,58
; wait 58 탎ec for the
ldi r25 ,0
; device to sample the line
rcall wait_usec
cbi DDRA ,PA4 ; recovery time
cbi PORTA ,PA4
ldi r24 ,0x01
ldi r25 ,0x00
rcall wait_usec
ret

; Routine: one_wire_reset
; Description:
; This routine transmits a reset pulse across the wire
; and detects any connected devices.
; parameters: None.
; return value: 1 is stored in r24
; if a device is detected, or 0 else.
; registers affected r25:r24
; routines called: wait_usec
one_wire_reset:
sbi DDRA ,PA4 ; PA4 configured for output
cbi PORTA ,PA4 ; 480 탎ec reset pulse
ldi r24 ,low(480)
ldi r25 ,high(480)
rcall wait_usec
cbi DDRA ,PA4 ; PA4 configured for input
cbi PORTA ,PA4
ldi r24 ,100
; wait 100 탎ec for devices
ldi r25 ,0
; to transmit the presence pulse
rcall wait_usec
in r24 ,PINA ; sample the line
push r24
ldi r24 ,low(380) ; wait for 380 탎ec
ldi r25 ,high(380)
rcall wait_usec
pop r25
clr r24
sbrs r25 ,PA4
ldi r24 ,0x01
ret

wait_usec:
	sbiw r24, 1
	nop
	nop
	nop
	nop
	brne wait_usec
	ret
wait_msec:
	push r24	
	push r25
	ldi r24, low(998)
	ldi r25, high(998)
	rcall wait_usec
	pop r25
	pop r24
	sbiw r24, 1
	brne wait_msec
	ret

write_2_nibbles:
	push r24
	in r25, PIND 
	andi r25, 0x0f 
	andi r24, 0xf0 
	add r24, r25 
	out PORTD, r24
	sbi PORTD, PD3
	cbi PORTD, PD3
	pop r24 
	swap r24 
	andi r24, 0xf0 
	add r24, r25
	out PORTD, r24
	sbi PORTD, PD3 
	cbi PORTD, PD3
	ret

;***********************************************************************************************
	
lcd_data:
	sbi PORTD, PD2 
	rcall write_2_nibbles 
	ldi r24, 43 
	ldi r25, 0 
	rcall wait_usec
	ret	

;***********************************************************************************************
	
lcd_command:
	cbi PORTD ,PD2 
	rcall write_2_nibbles 
	ldi r24, 39 
	ldi r25, 0 
	rcall wait_usec 
	ret	

;***********************************************************************************************
	
lcd_init:
	ldi r24, 40 
	ldi r25, 0 
	rcall wait_msec 
	ldi r24, 0x30 
	out PORTD, r24 
	sbi PORTD, PD3 
	cbi PORTD, PD3 
	ldi r24, 39
	ldi r25, 0 
	rcall wait_usec 
	ldi r24, 0x30
	out PORTD, r24
	sbi PORTD, PD3
	cbi PORTD, PD3
	ldi r24, 39
	ldi r25, 0
	rcall wait_usec
	ldi r24, 0x20 
	out PORTD, r24
	sbi PORTD, PD3
	cbi PORTD, PD3
	ldi r24, 39
	ldi r25, 0
	rcall wait_usec
	ldi r24, 0x28 
	rcall lcd_command 
	ldi r24, 0x0c
	rcall lcd_command
	ldi r24, 0x01 
	rcall lcd_command
	ldi r24, low(1530)
	ldi r25, high(1530)
	rcall wait_usec
	ldi r24, 0x06 
	rcall lcd_command 
	ret

;***********************************************************************************************

keypad_to_ascii:								; logiko '1' stis theseis tou kataxwrhth r26 dhlwnoun ta parakatw sumvola kai arithmous
	movw r26 ,r24
	ldi r24 ,'*'
	sbrc r26 ,0
	ret
	ldi r24 ,'0'
	sbrc r26 ,1
	ret
	ldi r24 ,'#'
	sbrc r26 ,2
	ret
	ldi r24 ,'D'
	sbrc r26 ,3
	ret
	ldi r24 ,'7'
	sbrc r26 ,4
	ret
	ldi r24 ,'8'
	sbrc r26 ,5
	ret
	ldi r24 ,'9'
	sbrc r26 ,6
	ret
	ldi r24 ,'C'
	sbrc r26 ,7
	ret
	ldi r24 ,'4'								; logiko '1' stis theseis tou kataxwrhth r27 dhlwnoun ta parakatw sumvola kai arithmous
	sbrc r27 ,0
	ret
	ldi r24 ,'5'
	sbrc r27 ,1
	ret
	ldi r24 ,'6'
	sbrc r27 ,2
	ret
	ldi r24 ,'B'
	sbrc r27 ,3
	ret
	ldi r24 ,'1'
	sbrc r27 ,4
	ret
	ldi r24 ,'2'
	sbrc r27 ,5
	ret
	ldi r24 ,'3'
	sbrc r27 ,6
	ret
	ldi r24 ,'A'
	sbrc r27 ,7
	ret
	clr r24
	ret
