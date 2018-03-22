.global main

			
.equ pcb_flag, 19			#Sets up all the constants needed
.equ pcb_time, 18
.equ pcb_link, 0
.equ pcb_reg1, 1
.equ pcb_reg2, 2
.equ pcb_reg3, 3
.equ pcb_reg4, 4
.equ pcb_reg5, 5
.equ pcb_reg6, 6
.equ pcb_reg7, 7
.equ pcb_reg8, 8
.equ pcb_reg9, 9
.equ pcb_reg10, 10
.equ pcb_reg11, 11
.equ pcb_reg12, 12
.equ pcb_reg13, 13
.equ pcb_sp, 14
.equ pcb_ra, 15
.equ pcb_ear, 16
.equ pcb_cctrl, 17

main:					#main program routine
	
	movsg $2, $cctrl		#copy value of cctrl into $2
	andi $2, $2, 0x000f		#disable all interrupts
	ori $2, $2, 0x42		#enable IRQ2 and IE
	movgs $cctrl, $2		#copy new back to cctrl
		
	movsg $2, $evec			#copy older handler to $2
	sw $2, old_vector($0)		#save this to memory
	la $2, handler			#load our handler address into $2
	movgs $evec, $2			#load this $2 back into $evec register

	addi $2, $0, 24			#set register $2 to the value of 1/100th second
	sw $2, 0x72001($0)		#load $2 into the timer load register
		
	addi $2, $0, 0x3		#set $2 to have prepare to set control register on (11)
	sw $2, 0x72000($0)		#load $2 into the timer control register to set auto restart

	addi $2, $0, 3			#and enable timer
	sw $2, p_count($0)

	addi $5, $0, 0x4d		#sets the masks needed to initialise
	addi $4, $0, 1
	la $6, exit



	la $1, pcb_serial		#sets the pcb we want to initialise

	la $2, pcb_parallel		#sets the pcb that we want to link to
	sw $2, pcb_link($1)		#links this pcb to the next one
	
	la $2, serial_stack		#initialises the stack of the serial pcb
	sw $2, pcb_sp($1)
		
	la $2, serial_main		#initialises the main address for this pcb
	sw $2, pcb_ear($1)
	
	sw $5, pcb_cctrl($1)		#sets the cctrl value for this pcb
	addi $3, $0, 1			#sets a mask of one to use for the timeslice
	sw $3, pcb_time($1)		#sets timeslice to 1

	sw $6, pcb_ra($1)

	sw $4, pcb_flag($1)		#sets flag to 1



	la $1, pcb_parallel		#sets the pcb we want to initialise

	la $2, pcb_rocks		#sets the pcb that we want to link to
	sw $2, pcb_link($1)		#links this pcb to the next one
	
	la $2, parallel_stack		#initialises the stack of this pcb
	sw $2, pcb_sp($1)
		
	la $2, parallel_main		#initialises the main address for this pcb
	sw $2, pcb_ear($1)
	
	sw $5, pcb_cctrl($1)		#sets the cctrl value for this pcb
	addi $3, $0, 1			#sets a mask of one to use for the timeslice
	sw $3, pcb_time($1)		#sets timeslice to 1

	sw $6, pcb_ra($1)		

	sw $4, pcb_flag($1)		#sets flag to 1



	la $1, pcb_rocks		#sets the pcb we want to initialise

	la $2, pcb_idle			#sets the pcb that we want to link to
	sw $2, pcb_link($1)		#links this pcb to the next one
	
	la $2, rocks_stack		#initialises the stack of this pcb
	sw $2, pcb_sp($1)		
		
	la $2, rocks_main		#initialises the main address for this pcb
	sw $2, pcb_ear($1)
	
	sw $5, pcb_cctrl($1)		#sets the cctrl value for this pcb
	addi $3, $0, 4			#sets a mask of four to use for the timeslice
	sw $3, pcb_time($1)		#sets timeslice to 4

	sw $6, pcb_ra($1)		
	
	sw $4, pcb_flag($1)		#sets the flag to 1



	la $1, pcb_idle			#sets the pcb we want to initialise

	la $2, pcb_serial		#sets the pcb that we want to link to
	sw $2, pcb_link($1)		#links this pcb to the next one
	
	la $2, idle_stack		#initialises the stack of this pcb
	sw $2, pcb_sp($1)
		
	la $2, idle_main		#initialises the main address for this pcb
	sw $2, pcb_ear($1)
	
	addi $3, $0, 1			#sets a mask of one to use for the timeslice
	sw $3, pcb_time($1)		#sets timeslice to 1

	sw $0, pcb_flag($1)		#sets flag to 0

	la $1, pcb_serial		#sets the first task to serial task
	sw $1, current_task($0)

	j load_context			#starts the first task

	

handler:
	movsg $13, $estat		#get value of exception status register
	andi $13, $13, 0xffb0		#check if IQR2 needs to be handled
	beqz $13, handle_interrupt	#if equal to zero, go to our interrupt handler
	
	lw $13, old_vector($0)		#otherwise load normal interrupt handler
	jr $13				#jump to normal interrupt handler
	

handle_interrupt:

	lw $13, counter($0)		#load counter into $13
	addi $13, $13, 0x1		#add 1 to $13
	sw $13, counter($0)		#load $13 back into counter

	sw $0, 0x72003($0)		#set timer count to zero

	lw $13, timeslice($0)		#loads in the timeslice value
	subi $13, $13, 0x1		#take one away
	beqz $13, dispatcher		#if its zero, go to dispatcher
	sw $13, timeslice($0)		#saves the timeslice value
		
	rfe				#return from the exception


dispatcher:				#the dispatcher
save_context:
	lw $13, current_task($0)	#loads the pcb for the current task
	
	sw $1, pcb_reg1($13)		#saves all of the register to the current task pcb
	sw $2, pcb_reg2($13)
	sw $3, pcb_reg3($13)
	sw $4, pcb_reg4($13)
	sw $5, pcb_reg5($13)
	sw $6, pcb_reg6($13)
	sw $7, pcb_reg7($13)
	sw $8, pcb_reg8($13)
	sw $9, pcb_reg9($13)
	sw $10, pcb_reg10($13)
	sw $11, pcb_reg11($13)
	sw $12, pcb_reg12($13)
	sw $sp, pcb_sp($13)
	sw $ra, pcb_ra($13)
	
	movsg $1, $ers			#get the olf value of $13
	sw $1, pcb_reg13($13)		#save it to the pcb

	movsg $1, $ear			#save ear
	sw $1, pcb_ear($13)
	
	movsg $1, $cctrl		#save cctrl
	sw $1, pcb_cctrl($13)

schedule:
	lw $13, current_task($0)	#get the current task
	lw $13, pcb_link($13)		#get the next task from the current tasks link
	sw $13, current_task($0)	#set the current task to the next task

	lw $13, pcb_flag($13)		#load in the value of the current tasks flag
	beqz $13, schedule		#if the flag is 0 (program disabled) schedule the next task

load_context:

	lw $13, current_task($0)	#get the pcb of the current task
	lw $1, pcb_reg13($13)		#restore the value of $ers
	movgs $ers, $1			

	lw $1, pcb_ear($13)		#restore the value of $ear
	movgs $ear, $1

	lw $1, pcb_cctrl($13)		#restore cctrl
	movgs $cctrl, $1
	
	lw $1, pcb_reg1($13)		#restore all the registers needed
	lw $2, pcb_reg2($13)
	lw $3, pcb_reg3($13)
	lw $4, pcb_reg4($13)
	lw $5, pcb_reg5($13)
	lw $6, pcb_reg6($13)
	lw $7, pcb_reg7($13)
	lw $8, pcb_reg8($13)
	lw $9, pcb_reg9($13)
	lw $10, pcb_reg10($13)
	lw $11, pcb_reg11($13)
	lw $12, pcb_reg12($13)
	lw $sp, pcb_sp($13)
	lw $ra, pcb_ra($13)
	
	lw $13, pcb_time($13)		#load the value of the task time allocations
	sw $13, timeslice($0)		#set this as the timeslice

	rfe				#return from exception

exit:
	lw $13, current_task($0)	#load in the current task
	sw $0, pcb_flag($13)		#set the flag of current task to 0
	lw $13, p_count($0)		#take one away from the program count
	subi $13, $13, 1
	sw $13, p_count($0)
	beqz $13, enable_idle		#if the program count is 0 (no active programs)
					#enable the idle program
	j schedule			#otherwise jump back to schedule


enable_idle:	
	la $13, pcb_idle		#get the address of the idle program
	addi $1, $0, 0x1		#set $1 to 1
	sw $1, pcb_flag($13)		#save 1 into the idle programs flag to enable it
	lw $13, p_count($0)		#add one to the program counter so there is 1 active program
	addi $13, $13, 0x1
	sw $13, p_count($0)
	j schedule			#jump to the schedule

idle_main:				#the idle program
	sw $0, 0x73004($0)		#set hex decode to false
	addi $1, $0, 0x40		#load in the value of -
	sw $1, 0x73002($0)		#display - on both ssd
	sw $1, 0x73003($0)
	j idle_main			#repeat idle main


				#the follow .bss contains all the pcbs, stacks, and data needed.
.bss
	.space 200
serial_stack:

	.space 200
parallel_stack:

	.space 200
rocks_stack:

	.space 200
idle_stack:

old_vector:
	.word

current_task:
	.word
	
pcb_serial:
	.space 20

pcb_parallel:
	.space 20

pcb_rocks:
	.space 20

pcb_idle:
	.space 20

timeslice:
	.word

p_count:
	.word
