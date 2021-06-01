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
MAX_USER_INPUT_SIZE = 11


.data

intro1			BYTE		"PROJECT 6: String Primitives and Macros by Adam Okasha",13,10,0
intro2			BYTE		"Please input 10 signed decimal integers that can fit inside a 32 bit register",13,10,
							"The program will then display the integers, their sum, and the average",13,10,0
prompt			BYTE		"Please enter a signed integer: ",0
userInput		BYTE		MAX_USER_INPUT_SIZE DUP(?)
userInputLen	DWORD		?
userNum			SDWORD		?
userNums		SDWORD		10 DUP(?)
errorMsg		BYTE		"The number you entered is invalid. Please try again.",13,10,0
setNegative		DWORD		0

.code
main PROC

	push	OFFSET userNums
	push	OFFSET setNegative
	push	OFFSET errorMsg
	push	OFFSET prompt
	push	OFFSET userInput
	push	OFFSET userInputLen
	call	ReadVal
	;mDisplayString	OFFSET userInput

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; (insert additional procedures here)

ReadVal PROC
	push	EBP
	mov		EBP, ESP

	mov		ECX, MAX_USER_INPUT_SIZE - 1	; sub 1 for sign when using as counter
	mov		EDI, [EBP + 28]	
	push	ECX

	_prompt:
		mGetString		[EBP + 16], [EBP + 12], MAX_USER_INPUT_SIZE, [EBP + 8]
		
		mov		ECX, [EBP + 8]			; set ECX as the count of userInput
		mov		EAX, [ECX]
		mov		ECX, EAX

		mov		ESI, [EBP + 12]			; reset userInput mem location
		push	EBX
		
		mov		EBX, 0
		mov		[EBP + 24], EBX			; reset negation variable
		
		cld

	_checkSign:
		lodsb
		cmp		AL, 45
		je		_setNegative
		jmp		_validate

	_setNegative:
		push	EBX
		mov		EBX, 1
		mov		[EBP + 24], EBX
		pop		EBX

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
		jmp		_prompt
		
	_accumulate:
		sub		AL, LO_NUM_ASCII
		add		[EDI], AL
		dec		ECX
		cmp		ECX, 0
		ja		_moveForward
		;mov		EAX, [EDI]
		;neg		EAX
		;mov		[EDI], EAX

		add		EDI, 4
		pop		ECX
		loop	_prompt
	
	RET
ReadVal ENDP

END main
