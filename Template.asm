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
mGetString MACRO buffer, usrInput, usrInputCount, usrInputBytes
	push	EDX
	push	ECX
	push	EAX

	mov		EDX, OFFSET buffer
	call	WriteString
	mov		EDX, OFFSET usrInput
	mov		ECX, usrInputCount
	call	ReadString
	mov		usrInputBytes, EAX

	pop		EAX
	pop		ECX
	pop		EDX
ENDM

mDisplayString MACRO display_string
	push	EDX

	mov		EDX, OFFSET display_string
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

.code
main PROC

	mGetString		prompt, userInput, MAX_USER_INPUT_SIZE, userInputLen
	mDisplayString	userInput

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
