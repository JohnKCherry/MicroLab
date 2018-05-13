#define DDRC (* (int *)0x34)
#define PORTC (* (int *)0x35)
#define PINC (* (int *)0x33)
#define DDRA (* (int *)0x3A)
#define PORTA (* (int *)0x3B)

int main(void)
{
	/*#ifdef NO_HEADER
	volatile int *DDRC = (int *)0x34;
	volatile int *PORTC = (int *)0x35;
	volatile int *PINC = (int *)0x33;
	volatile int *DDRA = (int *)0x3A;
	volatile int *PORTA = (int *)0x3B;
	#endif*/

	DDRC = 0x00;		// port c = input
	PORTC = 0x00;		// disable pull-up resistances
	
	DDRA = 0xFF;		// port a = output
	
	unsigned char input, output = 0x80, state = 0, state_tmp;
	
	while (1) {
		PORTA = output;
		
		input = (PINC & 0x1F) << 3;	
		state = state | input;

		state_tmp = state;
		
		int operation;
		for (operation = 4; operation >= 0; operation--) {
			if ( (state_tmp & 0x80) && !(input & 0x80) ) break;
			state_tmp = state_tmp << 1;
			input = input << 1;
		}

		switch (operation) {
			case 0:
				output = (output >> 1) | (output << 7); //ROTATE μια θέση δεξιά
				state = state & 0xF7;
				break;
			case 1:
				output = (output << 1) | (output >> 7); // ROTATE μια θέση αριστερά
state = state & 0xEF;
				break;
			case 2:
				output = (output >> 2) | (output << 6); //ROTATE δύο θέσεις δεξιά
				state = state & 0xDF;
				break;
			case 3:
				output = (output << 2) | (output >> 6); //ROTATE δύο θέσεις αριστερά
				state = state & 0xBF;
				break;
			case 4:
				output = 0x80;
				state = state & 0x7F;
				break;
		}
		
	}
	return 0;
}
