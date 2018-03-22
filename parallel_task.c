#include "rex.h"

//The main method for parallel task
void parallel_main()
{
	//Defines the variables neededi n the program
	char num, right, left;
	//Sets the initial mode to 1
	int button = 1;
	
	while(1)
	{
		//Gets the switch values
		num = RexParallel->Switches;

		//if the button is not zero
		if(RexParallel->Buttons != 0)
		{
			//Set button to the buttons value
			button = RexParallel->Buttons;
		}
		//If the button is 1, set to hex
		if(button == 1)
		{
			right = num % 16;
			left = (num >> 4) % 16;
		}
		else if(button == 2)
		{
			//Otherwise if button is 2, set to decimal
			right = num % 10;
			left = (num / 10) % 10;			
		}
		else if(button == 3)
		{
			//otherwise if button is 3, return
			return;
		}

		//Display the number on the left and right SSD
		RexParallel->RightSSD = right;
		RexParallel->LeftSSD = left;
		
		//Until a switch is changed or a button is pressed, do nothing.
		while(num == RexParallel->Switches && RexParallel->Buttons == 0);
		
	}
}

