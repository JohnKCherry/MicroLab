.include "m16def.inc"			;prosthhkh arxeiou kefalidas gia xeirismo thurwn I/0 mesw twn sumvolikwn onomatwn tous
.def flag = r19
.def temp = r16				;orismos proswrinou kataxwrhth gia ektelesh arithmhtikwn kai logikwn praksewn
.def portAValue = r17			;kataxwrhths apothukeushs dedomenwn thuras eisodou A
.def ledValue = r18			;kataxwrhths odhghshs fwtistikou swmatos sto led PB0
.equ fourSec = 34286			;orismos statherwn timwn pou tha odhghthoun ston 16bito xronisth Timer 1
.equ halfSec = 61629			;me vash thn parapanw sullogistikh poreia
.equ threeAndHalfSec = 38192
.org 0					;orismos dianusmatwn arxikopoihshs, ekswterikhs diakophs kai diakophs xronisth
jmp reset
.org 4
jmp int1Routine
.org 0x10
jmp timer1Routine
reset:
	ldi temp, high(ramend)		;arxikopoihsh deikth stoivas, wste na deixnei sto telos ths SRAM, diadikasia APARAITHTH efoson
	out sph, temp			;exoume klhsh estw enos upoprogrammatos h exoume energopoihsei thn uposthriksh diakopwn
	ldi temp, low(ramend)
	out spl, temp
	clr temp
	out DDRA, temp			;oi thures A kai D thures eisodou dedomenwn
	out DDRD, temp
	out PORTA, temp			;me tautoxrono pull - up twn antistasewn tous
	out PORTD, temp
	ser temp
	out DDRB, temp			;h thura B thura eksodou dedomenwn
	//Setarisma anagnwrishs diakopwn tupou INT1
	ldi temp, 0b10000000
	out gicr, temp			;epitrepsh ekswterikwn diakopwn MONO tupou INT1
	ldi temp, 0b00001100
	out mcucr, temp			;ALLAGH h diakoph INT1 orizoume na prokaleitai sthn akmh ptwshs
	ldi temp,0b00000101
	out TCCR1B, temp
	sei				;Energopoihsh GIE bit tou SR. PROSOXH! Oi timer interrupts DEN mporoun na diakopsoun akomh th roh tou programmatos
	ser flag			//shmaia pou apotrepei to na pairnei to pathma tou PA7 perissoterew apo mia fores. 
	clr ledValue
main:
	in portAValue, PINA		;diavasma thuras eisodou A
	and flag, portAValue				        
	lsl portAvalue			;meleth MSB
	brcc main			;MSB = 0? An nai, kane alma sthn main
	sbrc flag, 7			//an h flag einai 0 agnohse to kaiphgaine apo thn arxh
	rjmp main
	ser flag			//ksanakane thn flag 1

	rcall ledupdate

	rjmp main			;programma diarkous leitourgias

int1Routine:
	rcall ledupdate			;energopoihsh maskas diakophs timer 1 
	reti

timer1Routine:
	sbrs ledValue,2			//einai kapoio apo to led anoikto ektos tou 1ou?
	rjmp turnoff			//an nai tote krathse to 1o led gia akoma 3.5sec anoikto. an oxi kleise ta
	andi ledValue, 0x01
	//set timer 3.5 seconds
	ldi temp, high(threeAndHalfSec)	;arxikopoihsh tou TCNT1
	out TCNT1H, temp		;gia uperxeilish meta apo 4 sec
	ldi temp, low(threeAndHalfSec)
	out TCNT1L, temp
	ldi temp, 1<<TOIE1
	out timsk, temp	

	rjmp timer1Routine_end
turnoff:
	clr ledValue

timer1Routine_end:
	out PORTB, ledValue
	reti				;den xreiazetai na epanasetaroume ton xrono treksimatos ths routinas logw tou oti ginetai apo th main kai th diakoph

ledupdate:
	sbrc ledValue,0			//elegxoume an einai anoikto to 1o led. an den einai tote tha meinei anoikto gia 4sec, allios tha meinoun ola gia 0,5sec
	rjmp renew

	//set timer 4 seconds
	ldi temp, high(fourSec)		;arxikopoihsh tou TCNT1
	out TCNT1H, temp		;gia uperxeilish meta apo 4 sec
	ldi temp, low(fourSec)
	out TCNT1L, temp
	ldi temp, 1<<TOIE1
	out timsk, temp	

	ldi ledValue,0x01
	rjmp ledupdate_end
renew:
	//settimer 0.5 seconds
	ldi temp, high(halfSec)		;arxikopoihsh tou TCNT1
	out TCNT1H, temp		;gia uperxeilish meta apo 4 sec
	ldi temp, low(halfSec)
	out TCNT1L, temp
	ldi temp, 1<<TOIE1
	out timsk, temp	

	ldi ledValue,0xFF
ledupdate_end:
	out PORTB,ledValue
	ret

