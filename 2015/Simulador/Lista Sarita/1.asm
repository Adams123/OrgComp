	jmp main
vetor: var #10	
static vetor + #0, #0
static vetor + #1, #0
static vetor + #2, #0
static vetor + #3, #0
static vetor + #4, #1
static vetor + #5, #0
static vetor + #6, #1
static vetor + #7, #0
static vetor + #8, #1
static vetor + #9, #0
	
main:
	
	loadn r0,#vetor
	loadn r1,#10
	loadn r7,#0		;contagem de 0s
	loadn r3,#0		;carrega 0 para comparar
	
loop:
	loadi r2,r0		;copia pos do vetor
	inc r0			;avanca no vetor
	cmp r2,r3		;verifica se o valor no vetor eh 0
	jeq incN		;se for, incrementa contador

contLoop:	
	dec r1			;decrementa quantidade de pos do vetor
	jnz loop
	
	loadn r1,#48
	add r7,r7,r1
	outchar r7,r3
	halt
	
incN:
	inc r7
	jmp contLoop	;continua o vetor
	halt