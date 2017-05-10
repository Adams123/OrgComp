	jmp main
numero : var #0
static numero + #0, #2

multiplicador : var #0
static multiplicador + #0, #3
main:

	loadn r0, #numero
	loadn r1, #multiplicador
	loadn r2, #1
	loadn r4, #0

loop:
	add r3,r0,r4
	inc r2
	cmp r2,r1
	jne loop
	
	loadn r2,#0
	outchar r3,r2
	halt