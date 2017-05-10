
	jmp main
str1: string "Teste"
str2: string "Oi"

main:	
	load r0,str1
	load r1,str2
	call Strcmp
	mov r1,r7
	call f_imprime
	halt
	
Strcmp: 	;Compara duas strings r0 e r1, retorna em r7, se forem iguais retorna 1, se não retorna 0;
  
  	push r0
	push r1
	push r2
	push r3
	push r4
	push r5
	push r6
	
	loadn r3, #'\0'
	loadi r4, r1
	cmp r4, r3
	jne strcmp_loop
	jmp strcmp_false
	
strcmp_loop:
						;r0 = endereço de string1[0] inicialmente / r1 = endereço de string2[0] inicialmente
	loadi r5, r0		;r5 = valor de r0
	loadi r6, r1		;r6 = valor de r1
	inc r0				
	inc r1
	cmp r5, r6
	jne strcmp_false	;se uma vez r5 != r6 já paro e retorno 0
						
	loadi r4, r6		;comparo r6 pra ver se r5 = r6 = \0, se sim retorno 1, pois se uma vez eles forem diferentes ele nao chegaria nessa linha
	cmp r4, r3
	jne strcmp_loop
	jmp strcmp_true
	
strcmp_false:

	loadn r7, #0
	
	jmp strcmp_exit
	
strcmp_true:

	loadn r7, #1
	
	jmp strcmp_exit
	
strcmp_exit:
  
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	
	rts
	
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