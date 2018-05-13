
.include "m16def.inc"	  ;προσθήκη αρχείου κεφαλίδας που επιτρέπει την διαχείριση των PORTs μέσω των                                                                                                    ;συνολικών ετικετών τους			
.def ledStatus=r16	  ;καταχωρητής για το ενεργό bit
.def temp=r17		 ;προσωρινός καταχωρητής
.def foraKinhshs=r18      ;σημαία που δηλώνει την φορά της κίνησης των LEDs (11..11->δεξιά ολίσθηση, 00…00->
		              ; αριστερή ολίσθηση	                                            
.def pushButtonStatus=r19  ;σημαία για το αν είναι πατημένο ή όχι το κουμπί ( 00..00->αφημένο, 11..11->πατημένο)
	
main:
ldi temp,low(RAMEND)     ;αρχικοποίηση δείκτη στοίβας αφού γίνεται κάλεσμα ρουτίνας
out SPL,temp
ldi temp,high(RAMEND)
out SPH,temp
clr temp
out DDRA,temp	                  ;η θύρα Α ορίζεται ως είσοδος δηλαδή από εκεί θα διαβάζουμε τα δεδομένα
out PORTA,temp
ser temp 
out DDRB,temp                     ;η θύρα β ορίζεται ως έξοδος δηλαδή από εκεί θα εμφανίζουμε τα δεδομένα εξόδου
ldi ledStatus,0b00000001    ; τα LEDs είναι αρνητικής λογικής
clr foraKinhshs	                     ;ορίζω αριστερή φορά κίνησης
clr pushButtonStatus
flash:
	rcall pushButtonState	; κλήση υποπρογράμματος για τον έλεγχο του push button (LSB θύρας Α)
	rcall flashLed		; κλήση υποπρογράμματος για άναμμά των LEDs
	cpi pushButtonStatus,0x00
	breq flash
	rcall halfSecDelay	; κλήση υποπρογράμματος για χρονοκαθυστέρηση 0,5 sec
	rcall enhmerwshLed	; κλίση υποπρογράμματος για ενημέρωση των LEDs με την φορά περιστροφής και 
				;τις ακραίες περιπτώσεις
	rjmp flash		; το πρόγραμμα είναι συνεχούς λειτουργίας

pushButtonState:
	in temp,PINA	 	   ; διάβασμα της θύρας Α
	andi temp,0x01		   ;θέλουμε να εξετάζεται μόνο το LSB
	cpi temp,0x01		   ;έλεγχος για το αν πατήθηκε το PA0
	brne stop		   ;αν όχι πήγαινε στο stop
	ldi pushButtonStatus,0xff ; αλλιώς ενημέρωσε την σημαία για την κατάσταση του push button 	
	rjmp exitPush
stop:
	ldi pushButtonStatus,0x00  ;ενημέρωσε την σημαία για το push button ώστε να δηλώνει το άφημα 
exitPush:
	ret 

flashLed:		
	out PORTB,ledStatus
	ret
	
halfSecDelay:                           ;ρουτίνα χρονοκαθυστέρησης 
	ldi r24,low(500)
	ldi r25,high(500)
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

enhmerwshLed:
testMSB:
	cpi ledStatus,0b10000000    ;έλεγχος αν το αναμμένο led είναι το MSB 
	brne testLSB
	ldi foraKinhshs,0xFF	       ;αν ναι άλλαξε την φορά της κίνησης
	jmp shiftBlock
testLSB:
	cpi ledStatus,0b00000001    ;έλεγχος αν το αναμμένο led είναι το MSB
	brne shiftBlock
	ldi foraKinhshs,0x00	        ;αν ναι άλλαξε την φορά της κίνησης
shiftBlock:
	cpi foraKinhshs,0	        ;έλεγχος για το αν το led κινείται προς τα αριστερά
	brne prosDeksia	        ;αν όχι τότε κάνε άλμα
prosAristera:						
	lsl ledStatus		        ;αριστερή ολίσθηση
	rjmp exitProc
prosDeksia:
	lsr ledStatus		        ;δεξιά ολίσθηση
exitProc:
	ret
