TITLE Program Template     (template.asm)

; Author: 
; Last Modified:
; OSU email address: ONID_ID@oregonstate.edu
; Course number/section:   CS271 Section ???
; Project Number:                 Due Date:
; Description: This file is provided as a template from which you may work
;              when developing assembly projects in CS271.

INCLUDE Irvine32.inc

; (insert macro definitions here)
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

mDisplayString MACRO display_string
	push	EDX

	mov		EDX, display_string
	call	WriteString

	pop		EDX
ENDM

; (insert constant definitions here)

LO			 = -2147483648
HI			 = 2147483647
LO_NUM_ASCII = 48
HI_NUM_ASCII = 57
POS_ASCII	 = 43
NEG_ASCII	 = 45
SPACE_ASCII	 = 32
MAX_USER_INPUT_SIZE = 11
NULL_BIT	=	0


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
testInt				SDWORD		-103
testArr				SDWORD		-103, -109, 110, -2000, 2000, -1, 0, 89, 101, 99
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
	
	;push	OFFSET userNums
	;push	OFFSET setNegative
	;push	OFFSET errorMsg
	;push	OFFSET prompt
	;push	OFFSET userInput
	;push	OFFSET userInputLen
	;call	ReadVal

	call	Crlf

	;push	OFFSET outString
	;push	testInt
	;call	WriteVal
	mDisplayString OFFSET numbersEnteredMsg
	call	Crlf

	push	OFFSET outString
	push	OFFSET testArr
	call	DisplayNumbers

	call	Crlf
	call	Crlf

	push	OFFSET sum
	push	OFFSET outString
	push	OFFSET testArr
	call	CalculateSum

	push	OFFSET	outString
	push	sum
	call	WriteVal

	push	OFFSET average
	push	sum
	call	CalculateAverage

	push	OFFSET	outString
	push	average
	call	WriteVal

	;push	OFFSET avgDisplayMsg
	;push	OFFSET sumDisplayMsg
	;push	OFFSET outString
	;push	OFFSET userNums
	;call	DisplayCalculations

	call	Crlf

	mDisplayString OFFSET goodByeMsg

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; (insert additional procedures here)

ReadVal PROC
	push	EBP
	mov		EBP, ESP

	mov		ECX, MAX_USER_INPUT_SIZE - 1	; sub 1 for sign when using as counter
	mov		EDI, [EBP + 28]	

	_prompt:
		push	ECX
		mGetString		[EBP + 16], [EBP + 12], MAX_USER_INPUT_SIZE, [EBP + 8]

		push	EAX
		mov		EAX, [EBP + 8]			; set ECX as the count of userInput
		mov		ECX, [EAX]
		pop		EAX
		;mov		ECX, EAX

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
		mov		[EBP + 24], EBX
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
		mul		EBX					; 0/ 1/ 10 in EAX
		mov		[EDI], EAX
		pop		EBX
		pop		EAX

		sub		AL, LO_NUM_ASCII
		add		[EDI], AL

		;add		EAX, EBX
		;mov		[EDI], EAX

		dec		ECX
		cmp		ECX, 0
		ja		_moveForward

		push	EAX
		mov		EAX, [EBP + 24]
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
	
	pop		EBX
	RET		28
ReadVal ENDP

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
		neg		EAX			; convert to positive int

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

		;mov		AL, EAX
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

DisplayNumbers PROC
	push	EBP
	mov		EBP, ESP

	push	ESI
	push	EDI
	push	ECX

	mov		ESI, [EBP + 8]		; input array
	mov		EDI, [EBP + 12]		; outString
	mov		ECX, MAX_USER_INPUT_SIZE - 1

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

CalculateSum PROC
	push	EBP
	mov		EBP, ESP

	push	ESI
	push	EAX
	push	EBX
	push	ECX



	mov		ESI, [EBP + 8]		; input array
	mov		EDI, [EBP + 12]		; outString
	;mov		EBX, [EBP + 16]
	mov		ECX, MAX_USER_INPUT_SIZE - 1

	mov		EAX, 0

	_sumNumbers:
		add		EAX, [ESI]
		add		ESI, 4
		loop	_sumNumbers

	mov		EBX, [ebp + 16]
	mov		[EBX], EAX

	pop	ECX
	pop	EBX
	pop	EAX
	pop	ESI
	pop	EBP
	
	RET		16
CalculateSum ENDP

CalculateAverage PROC
	push	EBP
	mov		EBP, ESP
	push	ECX
	push	EAX
	push	EBX



	mov		ECX, MAX_USER_INPUT_SIZE - 1
	mov		EAX, [EBP + 8]		; sum
	
	_divide:
		mov		EBX, MAX_USER_INPUT_SIZE - 1
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


;DisplayCalculations PROC
;	push	EBP
;	mov		EBP, ESP
;
;	mov		ESI, [EBP + 8]		; input array
;	mov		EDI, [EBP + 12]		; outString
;	mov		ECX, MAX_USER_INPUT_SIZE - 1
;
;	mov		EAX, 0
;
;	_sumNumbers:
;		add		EAX, [ESI]
;		add		ESI, 4
;		loop	_sumNumbers
;
;	;push	EAX
;
;	mDisplayString [EBP + 16]
;
;	push	EDI
;	push	EAX
;	call	WriteVal
;
;	call	Crlf
;
;	;pop		EAX
;
;	_divide:
;		mov		EBX, MAX_USER_INPUT_SIZE - 1
;		mov		EDX, 0
;		cdq
;		idiv	EBX
;
;	mDisplayString [EBP + 20]
;
;	push	EDI
;	push	EAX
;	call	WriteVal
;
;	call	Crlf
;
;	pop		EBP
;	RET		8
;DisplayCalculations ENDP

END main
