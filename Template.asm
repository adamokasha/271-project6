TITLE Program Template     (template.asm)

; Author: Adam Okasha
; Last Modified: 6 Jun 2021
; OSU email address: okashaa@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:  6               Due Date: 6 Jun 2021
; Description: This program reads in 10 integers that fit in a 32 bit register,
;			   converts them to SDWORD integers and saves them in an array, 
;			   converts them back to strings and displays them and their sums 
;			   and averages as string. 

INCLUDE Irvine32.inc

;--------------------------------------------------------------------------
; name: mGetString
;
; Reads string input
;
; Precondition: none
;
; Postconditions: userNums SDWORD array will be filled with 10 SDWORD integers
;				  setNegative & userInputLen will be changed
;
; Receives: buffer			 = Message to write to prompt for input
;			usrInput		 = Empty BYTE array to hold user input (mem location of current index)
;			usrInputCount	 = The max allowed length of input
;			usrInputLen		 = Unitialized DWORD variable to caputre input length
;			
;
; Returns:  usrInput		 = User input string
;			usrInputLen		 = The length of the user input
;--------------------------------------------------------------------------
mGetString MACRO buffer, usrInput, usrInputCount, usrInputLen
	push	EDX
	push	ECX
	push	EAX

	mov		EDX, buffer
	call	WriteString
	mov		EDX, usrInput
	mov		ECX, usrInputCount
	call	ReadString
	mov		userInputLen, EAX

	pop		EAX
	pop		ECX
	pop		EDX
ENDM

;--------------------------------------------------------------------------
; name: mDisplayString
;
; Displays string passed to macro 
;
; Precondition: none
;
; Postconditions: none
;
; Receives: display_string	 = string to display			
;
; Returns:  none
;--------------------------------------------------------------------------
mDisplayString MACRO display_string
	push	EDX

	mov		EDX, display_string
	call	WriteString

	pop		EDX
ENDM

LO					= -2147483648
HI					= 2147483647
LO_NUM_ASCII		= 48
HI_NUM_ASCII		= 57
POS_ASCII			= 43
NEG_ASCII			= 45
SPACE_ASCII			= 32
MAX_USER_INPUT_SIZE = 11
MAX_NUM_LENGTH		= 10
NULL_BIT			= 0


.data

intro1				BYTE		"PROJECT 6: String Primitives and Macros by Adam Okasha",13,10,0
intro2				BYTE		"Please input 10 signed decimal integers that can fit inside a 32 bit register.",13,10,0
intro3				BYTE		"The maximum length of any entry should be 11 with sign or 10 without.",13,10,0
intro4				BYTE		"The program will then display the integers, their sum, and the average.",13,10,0
prompt				BYTE		"Please enter a signed integer: ",0
numbersEnteredMsg	BYTE		"The numbers you entered are:",0
sumDisplayMsg		BYTE		"The sum is:     ",0
avgDisplayMsg		BYTE		"The average is: ",0
goodByeMsg			BYTE		"Goodbye!",0
userInput			BYTE		MAX_USER_INPUT_SIZE DUP(?)
userInputLen		DWORD		?
userNum				SDWORD		?
userNums			SDWORD		10 DUP(?)
errorMsg			BYTE		"The number you entered is invalid. Try again.",0
setNegative			DWORD		0
outString			BYTE		1 DUP(?)
avgString			BYTE		1 DUP(?)
sum					SDWORD		0
average				SDWORD		0

.code
main PROC

	mDisplayString	OFFSET intro1
	call	Crlf

	mDisplayString  OFFSET intro2
	mDisplayString  OFFSET intro3
	mDisplayString  OFFSET intro4
	call	Crlf
	
	push	OFFSET userNums
	push	OFFSET setNegative
	push	OFFSET errorMsg
	push	OFFSET prompt
	push	OFFSET userInput
	push	OFFSET userInputLen
	call	ReadVal

	call	Crlf

	mDisplayString OFFSET numbersEnteredMsg
	call	Crlf

	push	OFFSET outString
	push	OFFSET userNums
	call	DisplayNumbers

	call	Crlf
	call	Crlf

	push	OFFSET sum
	push	OFFSET userNums
	call	CalculateSum

	mDisplayString  OFFSET sumDisplayMsg

	push	OFFSET	outString
	push	sum
	call	WriteVal

	call	Crlf

	push	OFFSET average
	push	sum
	call	CalculateAverage

	mDisplayString  OFFSET avgDisplayMsg

	push	OFFSET	outString
	push	average
	call	WriteVal

	call	Crlf
	call	Crlf

	mDisplayString OFFSET goodByeMsg

	Invoke ExitProcess,0	; exit to operating system
main ENDP

;--------------------------------------------------------------------------
; name: ReadVal
;
; Reads integer input as string converting storing each number input into
; an SDWORD array
;
; Precondition: none
;
; Postconditions: userNums SDWORD array will be filled with 10 SDWORD integers
;				  setNegative & userInputLen will be changed
;
; Receives: [EBP + 8]	 = userInputLen (holds the length of user input)
;			[EBP + 12]	 = userInput (string input array)
;			[EBP + 16]	 = prompt (Message)
;			[EBP + 20]	 = errorMsg
;			[EBP + 24]	 = setNegative (Acts as flag when a negative int entered)
;			[EBP + 28]	 = userNums (Array to saved converted string nums to SDWORD)
;
; Returns: userNums array filled with SDWORD ints
;--------------------------------------------------------------------------
ReadVal PROC
	push	EBP
	mov		EBP, ESP

	push	EAX
	push	EBX
	push	ECX
	push	EDI
	push	ESI

	mov		ECX, MAX_NUM_LENGTH
	mov		EDI, [EBP + 28]	

	_prompt:
		push	ECX
		mGetString		[EBP + 16], [EBP + 12], MAX_USER_INPUT_SIZE, [EBP + 8]

		push	EAX
		mov		EAX, [EBP + 8]			; set ECX as the count of userInput
		mov		ECX, [EAX]
		pop		EAX

		mov		ESI, [EBP + 12]			; reset userInput mem location
		
		mov		EBX, 0
		mov		[EBP + 24], EBX			; reset negation variable


	_checkSign:
		lodsb
		cmp		AL, 45
		je		_setNegativeFlag
		cmp		AL, 43
		je		_withPositiveSign
		jmp		_validate

	_setNegativeFlag:
		push	EBX
		mov		EBX, 1
		mov		[EBP + 24], EBX			; modify setNegative to 1
		pop		EBX
		dec		ECX
		jmp		_moveForward

	_withPositiveSign:
		dec		ECX


	_moveForward:
		cld
		lodsb
		jmp		_validate

	_validate:
		cmp		AL, 48
		jb		_invalid
		cmp		AL, 57
		ja		_invalid
		jmp		_accumulate

	_invalid:
		mDisplayString		[EBP + 20]
		call	Crlf
		pop		ECX					; restore ECX to outer loop count
		mov		EBX, 0
		mov		[EDI], EBX			; reset accumulated value in destination register
		jmp		_prompt
		
	_accumulate:
		mov		EBX, [EDI]			; save prev accumulated value

		push	EAX					; preserve EAX/AL
		push	EBX
		mov		EAX, EBX			; 10 * (EAX <= EBX)
		mov		EBX, 10
		mul		EBX					
		mov		[EDI], EAX
		pop		EBX
		pop		EAX

		sub		AL, LO_NUM_ASCII
		add		[EDI], AL

		dec		ECX
		cmp		ECX, 0
		ja		_moveForward

		push	EAX
		mov		EAX, [EBP + 24]		; check is setNegative is 1, move to _negate
		cmp		EAX, 1
		je		_negate
		jmp		_continue

		_negate:
			mov		EAX, [EDI]
			neg		EAX
			mov		[EDI], EAX
		
		

		_continue:
			pop		EAX
			add		EDI, 4
			pop		ECX
			dec		ECX
			cmp		ECX, 0
			jnz		_prompt
	
	pop		ESI
	pop		EDI
	pop		ECX
	pop		EBX
	pop		EAX
	pop		EBX
	RET		28
ReadVal ENDP

;--------------------------------------------------------------------------
; name: WriteVal
;
; Displays an integer by performing ASCII conversion and displaying string number
; Reference: https://nancy-rubin.com/2020/02/18/tech-guide-how-are-decimal-numbers-converted-into-the-ascii-code
; 1. Push null bit to indicate when each ASCII decimal number has been popped off stack 
; 2. SDWORD int gets divided down by 10 consecutively until quotient is 0. 
; 3. Each time 48 is added to remainder and pushed to stack
; 4. The numbers are popped off the stack until 0 is encountered
;
; Precondition: none
;
; Postconditions: outSring will be modified 
;
; Receives: [EBP + 8]	 = userNums (SSWORD array)
;			[EBP + 12]	 = outString address (1 byte, prints and moves back to start address to reuse)
;
; Returns: none
;--------------------------------------------------------------------------
WriteVal PROC
	push	EBP
	mov		EBP, ESP

	push	EAX
	push	EBX
	push	ECX
	push	EDI
	push	EDX


	mov		EDI, [EBP + 12]			; outString address
	mov		EAX, [EBP + 8]			; number to write to outString

	_checkSign:
		cmp		EAX, 0
		jl		_negate
		jmp		_pushNullBit
		cld


	_negate:
		push	EAX
		mov		AL, 45
		stosb	
		mDisplayString		[EBP + 12]

		dec		EDI
		
		pop		EAX
		neg		EAX					; convert to positive int

	_pushNullBit:
		push	0

	_asciiConversion:

		mov		EDX, 0
		mov		EBX, 10
		div		EBX
		
		mov		ECX, EDX
		add		ECX, 48
		push	ECX
		cmp		EAX, 0
		je		_popAndPrint
		jmp		_asciiConversion

	_popAndPrint:
		pop		EAX

		stosb
		mDisplayString		[EBP + 12]
		dec		EDI

		cmp		EAX, 0
		je		_exitAsciiConversion
		jmp		_popAndPrint

	_exitAsciiConversion:
		mov		AL, SPACE_ASCII
		stosb
		mDisplayString		[EBP + 12]
		dec		EDI
	
	pop		EDX
	pop		EDI
	pop		ECX
	pop		EBX
	pop		EAX
	pop		EBP

	RET	8
WriteVal ENDP

;--------------------------------------------------------------------------
; name: DisplayNumbers
;
; Loops over SDWORD numbers array and call WriteVal to display the numbers
;
; Precondition: SDWORD array must be filled
;
; Postconditions: none 
;
; Receives: [EBP + 8]	   = SDWORD integer
;			[EBP + 12]	   = outString address (1 byte, prints and moves back to start address to reuse)
;			MAX_NUM_LENGTH = the length of SDWORD array
; Returns: none
;--------------------------------------------------------------------------
DisplayNumbers PROC
	push	EBP
	mov		EBP, ESP

	push	ESI
	push	EDI
	push	ECX

	mov		ESI, [EBP + 8]					; input array
	mov		EDI, [EBP + 12]					; outString
	mov		ECX, MAX_NUM_LENGTH

	_printNumber:
		push	EDI
		push	[ESI]
		call	WriteVal
		add		ESI, 4
		loop	_printNumber

	pop		ECX
	pop		EDI
	pop		ESI
	pop		EBP	
	RET		12
DisplayNumbers ENDP

;--------------------------------------------------------------------------
; name: CalculateSum
;
; Loops over SDWORD numbers array calculates the sum
;
; Precondition: SDWORD array must be filled
;
; Postconditions: sum variable will be chaged 
;
; Receives: [EBP + 8]	   = SDWORD arrray
;			[EBP + 12]	   = sum
;			MAX_NUM_LENGTH = Array length used a loop counter
;
; Returns: sum
;--------------------------------------------------------------------------
CalculateSum PROC
	push	EBP
	mov		EBP, ESP

	push	ESI
	push	EAX
	push	EBX
	push	ECX

	mov		ESI, [EBP + 8]			; input array
	mov		ECX, MAX_NUM_LENGTH

	mov		EAX, 0

	_sumNumbers:
		add		EAX, [ESI]
		add		ESI, 4
		loop	_sumNumbers

	mov		EBX, [ebp + 12]
	mov		[EBX], EAX

	pop	ECX
	pop	EBX
	pop	EAX
	pop	ESI
	pop	EBP
	
	RET		8
CalculateSum ENDP


;--------------------------------------------------------------------------
; name: CalculateAverage
;
; Does signed integer division on passed in sum variable and set result in average variable
;
; Precondition: sum must have a value
;
; Postconditions: average variable will be chaged 
;
; Receives: [EBP + 8]	   = sum
;			[EBP + 12]	   = average
;
; Returns: average
;--------------------------------------------------------------------------
CalculateAverage PROC
	push	EBP
	mov		EBP, ESP
	push	ECX
	push	EAX
	push	EBX

	mov		ECX, MAX_NUM_LENGTH
	mov		EAX, [EBP + 8]					
	
	_divide:
		mov		EBX, MAX_NUM_LENGTH
		mov		EDX, 0
		cdq
		idiv	EBX

	mov		EBX, [ebp + 12]					
	mov		[EBX], EAX

	pop		EBX
	pop		EAX
	pop		ECX
	pop		EBP

	RET		12
CalculateAverage ENDP

END main
