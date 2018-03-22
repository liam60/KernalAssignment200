#include "rex.h"

//The global counter
int counter = 0;


//Method to print a character
void printChar(int c) {
	//Loop while the TDR bit is not set
	while(!(RexSp2->Stat & 2));
	
	//Write the character to the Tx register
	RexSp2->Tx = c;
}

//The global main method for serial task
void serial_main()
{
	//Defines variables needed
	int sec, min, t1, t2, t3, t4, t5, t6;
	int button = 1;
	int temp, n;
	//infinite loop
	while(1)
	{
		//if a character has been received
		if((RexSp2->Stat & 1) != 0)
		{
			//If the char is q
			if(RexSp2->Rx == 'q')
			{
				return;
			}
			//Set the button variable to the char recieved 
			button = (RexSp2->Rx & 3);
		}

		//Return to the start of the line
		printChar('\r');
		//Delete any previous times by writing over with spaces
		for(n = 0; n < 8; n = n + 1)
		{
			printChar(' ');
		}


		//Return back to the start of the line
		printChar('\r');

		//If the char was 1
		if(button == 1)
		{
			//Calculate sec and min
			temp = counter/100;
			sec = temp % 60;
			min = (temp/60) % 60;


			//Get indiviual characters
			t4 = (sec % 10) + '0';
			t3 = ((sec/10) % 10) + '0';

			t2 = (min % 10) + '0';
			t1 = ((min/10) % 10) + '0';
			
			//Prints the characters in the correct format for this mode
			printChar(t1);
			printChar(t2);			
			printChar(':');
			printChar(t3);
			printChar(t4);
		}
	
		//If the char is 2 or 3
		if(button == 2 || button == 3)
		{
			//Gets the seconds
			sec = counter/100;
			
			//gets the individual characters
			t6 = (counter % 10) + '0';
			t5 = ((counter / 10) % 10) + '0';
			
			t4 = (sec % 10) + '0';
			t3 = ((sec / 10) % 10) + '0';
			
			t2 = ((sec / 100) % 10) + '0';
			t1 = ((sec / 1000) % 10) + '0';

			//Prints the characters in the correct format for this mode
			printChar(t1);
			printChar(t2);			
			printChar(t3);
			printChar(t4);

			//If the char is 2, add a dot
			if(button == 2)
			{
				printChar('.');
			}

			printChar(t5);
			printChar(t6);
					
		}




		//until the counter changers or a char is recieved, do nothing
		temp = counter;
		while((RexSp2->Stat & 1) == 0 && (counter == temp));
	} 
}

