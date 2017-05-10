jmp main

palavra: var #21
tampalavra: var #1
letra: var #1
TryList: var #20
TryListSize: var #1
Acerto: var #1
Erro: var #1
maxtampalavra: var #1
static maxtampalavra + #0, #20	;tamanho maximo da palavra

pospalavra_na_tela: var #1	;posicao da palavra na tela
static pospalavra_na_tela + #0, #780

Msn1: string "Digite a palavra enter para comecar"
Msn2: string "Digite uma letra"
Msn3: string "AAAAAA"
Msn4: string "Voce perdeu!"
Msn5: string "Deseja jogar novamente? (s/n)"
Msn6: string "Voce ganhou!"
Msn7: string "Letra existente..."
Msn8: string "                                           "

main:
	loadn r0,#0
	store Acerto, r0
	store Erro, r0
	store TryList, r0
	store TryListSize, r0
	
	loadn r0,#Msn1
	loadn r1,#0
	call printstr
	
	loadn r0,#0
	call inputPalavra
	call DesForca
	;call printPalavra
	
	loop:
		call inputLetra
		call compara
		call TesteFim
	jmp loop
	
	halt
	
inputLetra:
	push r0
	push r1
	push r2
	push r3
	push r4
	push r5
	push r6
	push r7
	;ro posicao da mensagem
	;r1 mensagem impressa
	;r2 cor,aux
	;r3 trylist
	;r4 trylist[i]
	;r5 trylistsize
	;r6 i
	;r7 letra
	
	loadn r0,#Msn2
	loadn r1,#560
	loadn r2,#0
	call printstr
	
	inputLetra_LeLetraLoop:
		call digLetra
	
	loadn r3,#TryList
	load r5,TryListSize
	loadn r6,#0 ;i=0
	load r7,letra
	loadn r2,#0 ;aux=0
	
inputLetra_CheckTryList:
		;checar se a letra foi digitada
		cmp r6,r5	;trylistsize=0?
		jeq inputLetra_EndInputLetra
		
		add r2,r3,r6
		loadi r4,r2
		
		cmp r4,r7 ;trylist[i]=letra?
		jeq inputLetra_LetraRepetida
		
		inc r6 ;i++
		cmp r6,r5 ;i==TryListSize?
		jle inputLetra_CheckTryList
	jmp inputLetra_EndInputLetra
	
inputLetra_LetraRepetida:
	
	push r0 ; Protege regs de parametro
	push r1
	push r2
	loadn r0,#Msn7
	loadn r1,#560 ;letra ja existe
	loadn r2,#0
	call printstr
	
	loadn r0,#TryList
	loadn r1,#608
	loadn r2,#0
	call printstr
	
	pop r2
	pop r1
	pop r0
	
	jmp inputLetra_LeLetraLoop
	
inputLetra_EndInputLetra:
	add r0,r5,r3
	storei r0,r7
	
	loadn r2,#0
	loadn r6,#1
	add r0,r0,r6 ;r0=Trylist + trylistsize +1
	storei r0,r2
	
	add r0,r5,r6
	store TryListSize,r0
	
	loadn r0,#Msn8 ;apagar mensagens
	loadn r1,#560
	loadn r2, #0
	call printstr
	
	loadn r0,#Msn8
	loadn r1,#600
	loadn r2,#0
	call printstr
	
	pop r7
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	
	rts
	
compara:

	
	push r0
	push r1
	push r2
	push r3
	push r4
	push r5
	push r6
	push r7
	
	loadn r0,#0
	loadn r1,#0
	load r2,tampalavra
	load r3,letra
	loadn r4,#palavra
	
	loadn r6,#780 ;posição inicial da palavra
	
	Compara_Loop:
		cmp r1,r2 ;condição de parada: se acertou tudo
		jeq Compara_Fim
		
		add r5,r4,r1 ;r5=palavra+1
		loadi r7,r5
		cmp r3,r7 ;letra==letra[r1]
		jne Compara_NaoPertence
		
		add r7,r6,r1 	;r7=pos na tela
		outchar r3,r7	;imprime letra na tela no _ correspondente
		
		load r7,Acerto
		inc r7 ;Acerto++
		store Acerto,r7
		
		inc r1 ;i++
		loadn r0,#1
		jmp Compara_Loop
		
	Compara_NaoPertence:
		inc r1
		jmp Compara_Loop
		
		Compara_Fim:
		loadn r7,#0
		cmp r0,r7
		jne Compara_FimSwitch
		
	
		load r7, Erro
		inc r7
		store Erro,r7
		
		loadn r3,#2304
		
		loadn r0,#1
		cmp r7,r0
		jne Compara_Case2
		loadn r1,#'O' 	;desenha a cabeça
		loadn r2,#127
		add r1,r1,r3
		outchar r1,r2
		
		jmp Compara_FimSwitch
		
		Compara_Case2:
		loadn r0,#2
		cmp r7,r0
		jne Compara_Case3
		loadn r1, #'H'
		loadn r2, #167
		add r1,r1,r3
		outchar r1,r2
		jmp Compara_FimSwitch
		
		Compara_Case3:
		loadn r0,#3
		cmp r7,r0
		jne Compara_Case4
		loadn r1, #'U'
		loadn r2,#207
		add r1,r1,r3
		outchar r1,r2
		jmp Compara_FimSwitch
		
		Compara_Case4:
		loadn r0,#4
		cmp r7,r0
		jne Compara_Case5
		loadn r1, #'|'
		loadn r2,#246
		add r1,r1,r3
		outchar r1,r2
		jmp Compara_FimSwitch
		
		Compara_Case5:
		loadn r0,#5
		cmp r7,r0
		jne Compara_Case6
		loadn r1, #'|'
		loadn r2,#248
		add r1,r1,r3
		outchar r1,r2
		jmp Compara_FimSwitch
		
		Compara_Case6:
		loadn r0,#6
		cmp r7,r0
		jne Compara_Case7
		loadn r1, #'\\'
		loadn r2,#168
		add r1,r1,r3
		outchar r1,r2
		jmp Compara_FimSwitch
		
		Compara_Case7:
		loadn r0,#7
		cmp r7,r0
		jne Compara_Case8
		loadn r1, #'/'
		loadn r2,#166
		add r1,r1,r3
		outchar r1,r2
		jmp Compara_FimSwitch
		
		Compara_Case8:
		loadn r0,#8
		cmp r7,r0
		jne Compara_FimSwitch
		
	Compara_FimSwitch:
		pop r7
		pop r6
		pop r5
		pop r4
		pop r3
		pop r2
		pop r1
		pop r0
		rts
		
TesteFim:
	
	push r0
	push r1
	push r2
	push r3
	push r4
	push r5
	push r6
	
	load r5,Erro
	loadn r6,#8
	load r3,Acerto
	load r4,tampalavra
	
	cmp r5,r6
	jeq TesteFim_Perdeu
	
	cmp r3,r4 ;Acerto=TamPalavra?
	jne TestaFim_Sai ;Se nao, vai embora 
	
	loadn r0,#Msn6
	loadn r1,#602
	loadn r2,#0
	call printstr
	
	TestaFim_JogarNovamente:
	
		loadn r0,#Msn5
		loadn r1,#642
		loadn r2,#0
		call printstr
		
		call digLetra
		

		loadn r3, #'s'
		load r4,letra
		cmp r3,r4
		jne TestaFim_Fimogo
		
		call ApagaTela
		
		pop r6
		pop r5
		pop r4
		pop r3
		pop r2
		pop r1
		pop r0
		
		pop r0 ;para nao estourar a pilha
		jmp main
		
	TesteFim_Perdeu:
		
		loadn r0,#Msn4
		loadn r1,#602
		loadn r2,#0
		call printstr
		
		loadn r0,#palavra ;imprime palavra correta
		loadn r1,#780
		loadn r2,#2816
		call printstr
		
		jmp TestaFim_JogarNovamente
		
		TestaFim_Fimogo:
		halt
		
		TestaFim_Sai:
		
		pop r6
		pop r5
		pop r4
		pop r3
		pop r2
		pop r1
		pop r0
		
		rts

		
inputPalavra:
	push r0		;ponteiro para palavra
	push r1		;contem a letra digitada
	push r2		;tecla enter (13)
	push r3		;tamanho maximo da palavra
	push r4		;
	push r5		;
	push r6		;
	push r7		;
	
	loadn r0, #palavra	;r0 contem um ponteiro para palavra
	loadn r2, #13		;tecla enter
	load r3, maxtampalavra  ;armazena em r3 o tamanho maximo da palavra
	loadn r4, #0		;contador de tamanho da palavra
	
	
    inputPalavraloop:
	call digLetra		;aguarda uma letra ser digitada e a armazena na variavel 'letra'

	load r1, letra		;carrega em r1 o conteudo da memoria apontada por letra
	
	cmp r1, r2		;r1 (letra digitada) == 13 (enter)?
	jeq inputPalavraFim

	storei r0, r1		;armazena palavra[r0] = r1
	inc r0
	
	inc r4
	store tampalavra, r4	;tampalavra = r4
	
	cmp r4, r3 		;r4 == max palavra?
	jne inputPalavraloop

    inputPalavraFim:
	loadn r5, #'\0'
	storei r0, r5
	jmp desemp_reg

desemp_reg:
	pop r7
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts

;**********************************************
; aguarda um letra ser digitada
; retorno: uma letra eh armazenada em 'letra'
;**********************************************
digLetra:
	push r0
	push r1
	loadn r1, #255

    digLetraloop:
		inchar r0
		cmp r0, r1
    jeq digLetraloop

	store letra, r0
	pop r1
	pop r0
	rts

printPalavra:
	push r0		;ponteiro para palavra
	push r1		;posicao na tela
	push r2		;
	push r3		;
	push r4		;
	push r5		;
	push r6		;
	push r7		;
	
	loadn r0, #palavra
	load r1, pospalavra_na_tela
	
	call printstr
	
	jmp desemp_reg
	
DesForca:
		push r0
		push r1
		push r2
		push r3
		
		load r3, tampalavra
		
		call ApagaTela
		;desenha topo da forca
		loadn r2,#40
		loadn r0,#'-'
		loadn r1,#42
		outchar r0,r1
		inc r1
		outchar r0,r1
		inc r1
		outchar r0,r1
		inc r1
		outchar r0,r1
		inc r1
		outchar r0,r1
		inc r1
		outchar r0,r1
		push r1 ;salva posicao do final da forca de cima
		
		;desenha pauzinho maior da forca
		loadn r0,#'I'
		loadn r1,#82
		outchar r0,r1
		add r1,r1,r2
		outchar r0,r1
		add r1,r1,r2
		outchar r0,r1
		add r1,r1,r2
		outchar r0,r1
		add r1,r1,r2
		outchar r0,r1
		add r1,r1,r2
		outchar r0,r1
		add r1,r1,r2
		outchar r0,r1
		add r1,r1,r2
		outchar r0,r1
		add r1,r1,r2
		outchar r0,r1
		add r1,r1,r2
		
		;desenha parte de baixo
		loadn r0,#'-'
		loadn r2,#2
		sub r1,r1,r2
		outchar r0,r1
		inc r1
		outchar r0,r1
		inc r1
		outchar r0,r1
		inc r1
		outchar r0,r1
		inc r1
		outchar r0,r1
		
		;desenha corda da forca
		loadn r0,#'I'
		loadn r2,#40
		pop r1 ;restaura posicao do final do topo
		outchar r0,r1
		add r1,r1,r2
		outchar r0,r1
		loadn r0,#'-'
		loadn r1,#820

DesForcaLoop: 	;desenha quantidade de traços necessários

		outchar r0,r1
		inc r1
		dec r3
		jnz DesForcaLoop
		
	pop r3
	pop r2
	pop r1
	pop r0
	
	rts
ApagaTela:
		push r0
		push r1
		
		loadn r0,#1200
		loadn r1,#' '
		
		ApagaTela_Loop:
				dec r0
				outchar r1,r0
				jnz ApagaTela_Loop
		pop r1
		pop r0
		
		rts
		
	

;**************************************************
; Subrotina que imprime uma string na tela
; Parametros: 
; r0 - endereco da string; 
; r1 - posicao na tela a ser impressa a string
;**************************************************
printstr: ; Imprime uma string apontada por r0, ate encontrar o '\0' 
	; Parametros: 
	; r0 - endereco da string; 
	; r1 - posicao na tela a ser impressa a string
	push 	r0
	push 	r1
	push 	r2
	push 	r3
	push	r4
	push	r5
	push	r6
	push	r7
	
	loadn 	r2, #'\0'			; r2 = 0  e eh usado como var auxiliar.  
	
loop_p_string:

	loadi 	r3, r0			; r3 = str[r0]
	cmp 	r3, r2			; compara se str[r0] == zero
	jeq 	sai_loop		; saida do loop caso '\0'

	outchar	r3, r1			; imprime o conteudo de r3 na posicao r1. Neste caso 
					; imprime o ASCII de str[r0].
	inc 	r1			; incrementa posicao para imprimir
	inc 	r0			; incrementa ponteiro da string
	
	jmp 	loop_p_string		; retorna para o inicio do loop_percorre

sai_loop:
	; desempilha registradores empilhados para retornar valores originais
	pop	r7	
	pop	r6
	pop	r5
	pop	r4	
	pop 	r3
	pop 	r2
	pop 	r1
	pop 	r0	

	rts							; retorna para quem chamou Printstr
;****************************************
	
			




