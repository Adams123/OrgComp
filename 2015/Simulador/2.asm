	jmp main
vetor : string "M"
main:
	
	loadn r0,#vetor
	loadn r1,#3		;adicionando 3 para cifra
	loadn r3,#7		;tamanho do vetor
	loadn r4,#0
loop:
	loadi r2,r0		;carrega valor do vetor
	add r2,r2,r1	;adiciona 3 ao valor
	storei r0, r2	;salva o valor de volta no vetor
	inc r0			;avanca no vetor
	inc r4
	cmp r4,r3		;compara com o tamanho, se for menor continua o loop, cc segue em frente
	jle loop
	
	loadn r1,#vetor
	loadn r0,#0
	call ImprimeStr
	halt


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