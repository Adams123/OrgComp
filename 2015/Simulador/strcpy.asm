 	jmp main
 
str1: var#50
str2: string "Teste"

main:	
	loadn r0,#str1
	loadn r1,#str2
	call Strcpy
	
	loadn r1,#str1
	loadn r0,#0
	call ImprimeStr
	halt
 
Strcpy: 	;Copia r1 em r0

	push r0
	push r1
	push r4
	push r5
	push r6

	loadn r4, #'\0'  
	
strcpy_loop:
	
	loadi r6, r1			;pega o valor contido em r1
	storei r0, r6			;copia para r0
	inc r1					;anda as strings
	inc r0
	loadi r5, r1			;pega a proxima posiçao para comparar se continua copiando ou para (se r1 = \0)
	cmp r5, r4
	jne strcpy_loop
	
	loadn r1, #'\0' 		;coloca \0 no final da nova string 
	
	pop r6
	pop r5
	pop r4
	pop r1
	pop r0
	
	rts
	
ImprimeStr:	;Rotina de Impresao de Mensagens:    r0 = Posicao da tela que o primeiro caractere da mensagem sera' impresso;  r1 = endereco onde comeca a mensagem; r2 = cor da mensagem.   Obs: a mensagem sera' impressa ate' encontrar "/0"
	push r0	;protege o r0 na pilha para preservar seu valor
	push r1	;protege o r1 na pilha para preservar seu valor
	push r2	;protege o r1 na pilha para preservar seu valor
	push r3	;protege o r3 na pilha para ser usado na subrotina
	push r4	;protege o r4 na pilha para ser usado na subrotina
	
	loadn r3, #'\0'	; Criterio de parada

ImprimeStrLoop:	
	loadi r4, r1
	cmp r4, r3
	jeq ImprimeStrSai
	add r4, r2, r4
	outchar r4, r0
	inc r0
	inc r1
	jmp ImprimeStrLoop
	
ImprimeStrSai:	
	pop r4	; Resgata os valores dos registradores utilizados na Subrotina da Pilha
	pop r3
	pop r2
	pop r1
	pop r0
	rts