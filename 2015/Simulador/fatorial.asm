	jmp main
main:
	loadn r0, #25			;valor a ser calculado o fatorial
	call Fatorial
	call f_imprime
	halt
	
Fatorial:					;Calcula o Fatorial de um numero (colocado em r0) e retorna o valor em r1
	loadn r1, #1
	loadn r2, #1

FatorialLoop:
	mul r1, r1, r0			;Multiplica e acumula em r1
	dec r0					;decrementa o numero
	cmp r0, r2				;compara com 1 para parar
	jgr FatorialLoop 		;se maior que 1, goto loop

	rts						;Fim da subrotina: Retorna o valor do fatorial em r1
	
	
f_imprime:
	loadn r0, #0
	loadn r3, #0			;valor para comparar
	add r0, r1, r3 			;valor para imprimir
	loadn r1, #10 			;valor para o mod
	loadn r4, #0
	loadn r5, #48			;valor do ascii
	
loop:
	mod r2, r0, r1			;salva valor em r2
	div r0, r0, r1  		;divide r0 por 10 e salva em r0
	cmp r0, r3				;condição de parada: se r0 for 0
	jeq imprime				;se verdade, começa impressão
	inc r4					;caso contrario, conta mais um digito
	push r2					;empilha o valor para impressão
	jmp loop				;retorna para o loop
	
imprime:
	add r0, r2, r5			;carrega para imprimir
	outchar r0, r3			;imprime na pos r3
	cmp r3,r4				;verifica se imprimiu tudo
	jeq sair
	
	inc r3					;avança pos de impressao
	pop r2					;chama proximo da pilha
	
	jmp imprime
	
sair:
	rts