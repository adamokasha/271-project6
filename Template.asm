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

intro1			BYTE		"PROJECT 6: String Primitives and Macros by Adam Okasha",13,10,0
intro2			BYTE		"Please input 10 signed decimal integers that can fit inside a 32 bit register.",13,10,
							"The program will then display the integers, their sum, and the average.",13,10,0
prompt			BYTE		"Please enter a signed integer: ",0
userInput		BYTE		MAX_USER_INPUT_SIZE DUP(?)
userInputLen	DWORD		?
userNum			SDWORD		?
userNums		SDWORD		10 DUP(?)
errorMsg		BYTE		"The number you entered is invalid. Try again.",0
setNegative		DWORD		0
testInt			SDWORD		-103
testArr			SDWORD		-103, -109, 110, -2000, 2000, -1, 0, 89, 101, 99
outString		BYTE		1 DUP(?)


.code
main PROC

	mDisplayString	OFFSET intro1

	call	Crlf

	mDisplayString  OFFSET intro2

	call	Crlf
	
	push	OFFSET userNums
	push	OFFSET setNegative
	push	OFFSET errorMsg
	push	OFFSET prompt
	push	OFFSET userInput
	push	OFFSET userInputLen
	call	ReadVal
	mDisplayString	OFFSET userInput

	call	Crlf

	;push	OFFSET outString
	;push	testInt
	;call	WriteVal

	push	OFFSET outString
	push	OFFSET userNums
	call	DisplayNumbers

	call	Crlf

	;push	OFFSET outString
	;push	OFFSET testArr
	;call	DisplayAverage

	push	OFFSET outString
	push	OFFSET userNums
	call	DisplayAverage

	call	Crlf

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
		jmp		_validate

	_setNegativeFlag:
		push	EBX
		mov		EBX, 1
		mov		[EBP + 24], EBX
		pop		EBX
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
	RET		24
ReadVal ENDP

WriteVal PROC
	push	EBP
	mov		EBP, ESP

	push	EAX
	;mov		ESI, [EBP + 8]			; int address
	mov		EDI, [EBP + 12]			; outString address
	mov		EAX, [EBP + 8]
	push	ECX

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

		;mov		AL, 48
		;stosb
		;mDisplayString		[EBP + 12]

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
		

	pop		ECX
	pop		EAX
	pop		EBP

	RET	8
WriteVal ENDP

DisplayNumbers PROC
	push	EBP
	mov		EBP, ESP

	mov		ESI, [EBP + 8]		; input array
	mov		EDI, [EBP + 12]		; outString
	mov		ECX, MAX_USER_INPUT_SIZE - 1

	_printNumber:
		push	EDI
		push	[ESI]
		call	WriteVal
		add		ESI, 4
		loop	_printNumber


	pop		EBP
	RET		8
DisplayNumbers ENDP

DisplayAverage PROC
	push	EBP
	mov		EBP, ESP

	mov		ESI, [EBP + 8]		; input array
	mov		EDI, [EBP + 12]		; outString
	mov		ECX, MAX_USER_INPUT_SIZE - 1

	mov		EAX, 0

	_sumNumbers:
		add		EAX, [ESI]
		add		ESI, 4
		loop	_sumNumbers

	;push	EAX

	push	EDI
	push	EAX
	call	WriteVal

	;pop		EAX

	_divide:
		mov		EBX, MAX_USER_INPUT_SIZE - 1
		mov		EDX, 0
		cdq
		idiv	EBX

	push	EDI
	push	EAX
	call	WriteVal

	pop		EBP
	RET		8
DisplayAverage ENDP

END main
