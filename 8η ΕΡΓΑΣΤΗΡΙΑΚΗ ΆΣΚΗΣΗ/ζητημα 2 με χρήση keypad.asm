.include "m16def.inc"								; Prosthhkh arxeiou kefalidas gia ton xeirismo twn thurwsn E/E mesw twn sumvolikwn etiketwn tous
.def temp = r16
.def r25High = r17
.def r25Low = r18
.def r24High = r19
.def r24Low = r20
.def counter = r21
.def proshmo = r22
.def dekadikos = r23
.def monades = r15
.def dekades = r27
.def ekatontades = r26

.DSEG
_tmp_: .byte 2 

.CSEG
reset:
	ldi temp, high(ramend)							; arxikopoihsh deikth stoivas
	out sph, temp
	ldi temp, low(ramend)
	out spl, temp
	ldi temp, 0b11110000							; gia to xeirismo tou plhktrologiou tha prepei oi akrodektes PC7 - PC4 na ruthmistoun gia eksodo kai oi PC3 - PCO gia eisodo
	out ddrc, temp	
	ldi temp, 0b11111111							; eksodoi ta 6 MSB, eisodoi ta 2 LSB ths thuras PORTD (gia xrhsh tou screen)
	out DDRD, temp
	rcall lcd_init
	ldi r24, 20
	rcall scan_keypad_rising_edge

main:
	rcall temperatureRoutine
	ldi r24, 0x80									// thetoume ton kersora sthn arxh ths othonhs
	rcall lcd_command
	ldi r24,0x20									// sthn othonh mporoun na emfanistoun to polu 8 xarakthres gia th thermokrasia
	rcall lcd_data									// se kathe epanalhpsh ths main, katharizoume thn othonh
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
	ldi r24,0x20
	rcall lcd_data
	ldi r24, 0x80									// thetoume ton kersora sthn arxh ths othonhs
	rcall lcd_command
									     
	sbrc r25, 0
	dec r24
	tst r24
	brne deviceOn									; an r24 <> 0 tote einai sundedemeno to aisthhthrio thermokrasias
	cpi r25, 0x80
	brne deviceOn									; r25:r24 <> 0x8000 opote uparxei aisthhthrio
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


print_dec:						
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
	ldi r24, 0xB2							; emfanish '°' sthn othonh							
	rcall lcd_data
	ldi r24, 0x43							; emfanish 'C' sthn othonh
	rcall lcd_data
	ret


temperatureRoutine:
	rcall wait_for_keypad					; routina pou diavazei pleon th thermokrasia apo to plhktrologio kai thn epistrefei sto zeugoss r25:r24
	rcall keypad_to_hex
	rcall hex_to_bin
	mov r25High, r24
	rcall wait_for_keypad
	rcall keypad_to_hex
	rcall hex_to_bin
	mov r25Low, r24
	rcall wait_for_keypad
	rcall keypad_to_hex
	rcall hex_to_bin
	mov r24High, r24
	rcall wait_for_keypad
	rcall keypad_to_hex
	rcall hex_to_bin
	mov r24Low, r24
	rcall marry									; pantrema r25high and r25low to r25, pantrema r24high and r24low to r24
	ret

keypad_to_hex:								
	movw r26 ,r24
	ldi r24 ,'E'								; tropopoihsh kwdika ascii
	sbrc r26 ,0
	ret
	ldi r24 ,'0'
	sbrc r26 ,1
	ret
	ldi r24 ,'F'								; tropopoihsh kwdika ascii
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
	
hex_to_bin:										; routina eksetashs r24 gia metatroph kwdika ascii se duadikh morfh 
												; krithrio metatrophs se duadiko arithmo einai to TI tha afairesoume
												; analoga me to ean to sumvolo mas einai sto [0, 9] h [A, F] wste
												; na afairesoume antistoixa 30Hex or 37Hex(see ascii table)
	
	cpi r24, 0x3A
	brlo minus30Hex
	subi r24, 0x37
	rjmp end_hex_to_bin
minus30Hex:
	subi r24, 0x30
end_hex_to_bin:
	ret
	
marry:
	lsl r25High									; den paw apeuteias na prosthesw ton rHigh me ton rLow, giati de tha lavw th swsth timh
	lsl r25High
	lsl r25High
	lsl r25High									; r25High <-- 16 * r25High
	add r25High, r25Low
	mov r25, r25High
	lsl r24High									; den paw apeuteias na prosthesw ton rHigh me ton rLow, giati de tha lavw th swsth timh
	lsl r24High
	lsl r24High
	lsl r24High									; r24High <-- 16 * r24High
	add r24High, r24Low
	mov r24, r24High
	ret

;--------------------------------------------------------------------------------------------------------
wait_usec:    
	sbiw r24 ,1
	nop
	nop
	nop
	nop
	brne wait_usec
	ret

;***********************************************************************************************

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

;***********************************************************************************************

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

;***********************************************************************************************

scan_keypad_rising_edge: 
	mov r22 ,r24
	rcall scan_keypad									; klhsh routinas diavasmatos plhktrologiou gia piesmenous diakoptes
	push r24											; apothukeush sth stoiva twn 16 xarakthrwn tou plhktrologiou
	push r25
	mov r24 ,r22
	ldi r25 ,0
	rcall wait_msec 
	rcall scan_keypad									; ksana klhsh routinas diavasmatos plhktrologiou gia piesmenous diakoptes
	pop r23
	pop r22 
	and r24 ,r22 
	and r25 ,r23 
	ldi r26 ,low(_tmp_)									; fortwsh katastashs diakopwn sthn PROHGOUMENH klhsh ths routinas sto zeugos kataxwrhtwn r27:r26
	ldi r27 ,high(_tmp_)
	ld r23 ,X+
	ld r22 ,X
	st X ,r24											; apothukeush sth RAM ths neas katastashs twn diakoptwn
	st -X ,r25
	com r23 
	com r22												; euresh diakoptwn pou MOLIS exoun paththei
	and r24 ,r22
	and r25 ,r23
	ret

;***********************************************************************************************

wait_for_keypad:
	ldi r24, 20
	rcall scan_keypad_rising_edge
	tst r24
	brne next1
	tst r25
	breq wait_for_keypad
next1:
	ret

