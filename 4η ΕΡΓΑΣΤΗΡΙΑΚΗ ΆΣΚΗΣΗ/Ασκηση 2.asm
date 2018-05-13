.include "m16def.inc"	  ;προσθήκη αρχείου κεφαλίδας που επιτρέπει την διαχείριση των PORTs μέσω των        
			              ; συνολικών ετικετών τους                                                                                              
.def temp=r16					
.def dipSwitchesValue=r17
ldi temp,low(RAMEND)    ;αρχικοποίηση δείκτη στοίβας αφού γίνεται κάλεσμα ρουτίνας	
out SPL,temp
ldi temp,high(RAMEND)
out SPH,temp
clr temp
out DDRA,temp	          ;η θύρα Α ορίζεται ως είσοδος δηλαδή από εκεί θα διαβάζουμε τα δεδομένα		
out PORTA,temp     
ser temp
out DDRB,temp	         ;η θύρα Β ορίζεται ως έξοδος δηλαδή από εκεί θα εμφανίζουμε τα δεδομένα εξόδου
main:
	rcall on
	in dipSwitchesValue,PINA
	rcall dipSwitchesState
	rcall delay
	rcall off
	in dipSwitchesValue,PINA
	swap dipSwitchesValue
	rcall dipSwitchesState
	rcall delay
	rjmp main
on:
	clr temp
	out PORTB,temp
	ret
off:
	ser temp				
	out PORTB,temp
	ret
dipSwitchesState:
	andi dipSwitchesValue,0x0F
	inc dipSwitchesValue			;σχηματισμός του (χ+1)
	ldi temp,200
	mul dipSwitchesValue,temp		;R1:R0<-(x+1)* 200
	mov r24,r0
	mov r25,r1
	ret
delay:	                   ;συνάρτηση που προκαλεί τόση χρονοκαθυστέρηση όσο είναι η τιμή του καταχωρητή r25:r24		push r24
	push r25
	ldi r24,low(998)         ;998 γιατί τα δύο είναι τα δύο push
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
	brne delay
	ret
