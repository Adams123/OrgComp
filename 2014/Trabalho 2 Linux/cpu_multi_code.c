#define DEBUG
#include "Debug-c.h"

void dec2bin(int c)
{
   int i = 0;
   for(i = 31; i >= 0; i--){
     if((c & (1 << i)) != 0){
       printf("1");
     }else{
       printf("0");
     } 
   }
}

/* Unidade de Controle secundaria que recebe como
  argumento ALUop (bits para operacao da ULA) */
int UC_secundaria(int ALUop, int IR){
	int mask_campo_funct = 0b00000000000000000000000000111111;
	int campo_funcao;
	int codigo_ula; //retorno da funcao (o codigo para a ula)

	campo_funcao = (IR & mask_campo_funct);//isola IR[5..0]

	switch(ALUop){
		case 0: //000 lw ou sw
			codigo_ula = 2; //0010
			break;		
		case 1:
			codigo_ula = 6; //0110
			break;
		case 2:
			if(campo_funcao == 32)  //add 100000 
				codigo_ula = 2; //0010

			if(campo_funcao == 34) //sub 100010
				codigo_ula = 6; //0110

			if(campo_funcao == 36) //and 100100
				codigo_ula = 0; //0000
		
			if(campo_funcao == 37) //or 100101
				codigo_ula = 1; //0001

			if(campo_funcao == 42) //slt 101010
				codigo_ula = 7; //0111

			break;
	}

	return codigo_ula;
}


/* Mux da unidade de controle que retorna o estado 
	de acordo com Controle de Endereço (CtlEnd - seletor do mux)
	- opcode eh usado para as tabelas de despacho
	- uestado eh usado para incrementar o estado (sequencial)
*/
int mux_UC(int CtlEnd, int opcode, int uestado){
	int estado; //estado de retorno do mux
	int rom_despacho1[5];	//rom de despacho 1
	int rom_despacho2[2];	//rom de despacho 2

	rom_despacho1[0] = 6; //0110 Formato R
	rom_despacho1[1] = 9; //1001 jmp
	rom_despacho1[2] = 8; //0100 beq
	rom_despacho1[3] = 2; //0010 lw
	rom_despacho1[4] = 2; //0010 sw

	rom_despacho2[0] = 3; //0011 lw
	rom_despacho2[1] = 5; //0101 sw
	
	//estado 0
	if(CtlEnd == 0) estado = 0;

	//tabela de despacho 1
	if(CtlEnd == 1){
		switch(opcode){
			case 0: //000000 - Formato R
				estado = rom_despacho1[0];
				break;			
			case 2: //000010 - jmp
				estado = rom_despacho1[1];
				break;
			case 4: //000100 - beq
				estado = rom_despacho1[2];
				break;
			case 35: //100011 - lw
				estado = rom_despacho1[3];
				break;
			case 43: //101011 - sw
				estado = rom_despacho1[4];
				break;
		} 
	}

	//tabela de despacho 2
	if(CtlEnd == 2){
		switch(opcode){
			case 35: //100011 - lw
				estado = rom_despacho2[0];
				break;
			case 43: //101011 - sw
				estado = rom_despacho2[1];
				break;
		} 
	}
			
	//sequencial
	if(CtlEnd == 3){
		estado = uestado + 1;
	}
	
	return estado;
}

/* Unidade de controle microprogamada conforme estabelecido em aula
   - retorna como parametro implicito o sinal de controle *sc
*/
void UnidadeControle(int IR, int *sc){
	static int uestado = 0; //micro estado interno da UC
	unsigned int opcode;
	int rom_u_instrucao[21]; // rom de micro instrucao
	int ctlend;// controle de enderecamento do mux da UC
	int mask_opcode = 0b11111100000000000000000000000000;
	
	rom_u_instrucao[0] = 0b00000000000111000101000000010000; 
	rom_u_instrucao[1] = 0b00000000000010000000000000110000;
	rom_u_instrucao[2] = 0b00000000000100000000000000101000;
	rom_u_instrucao[3] = 0b00000000000110000110000000000000;
	rom_u_instrucao[4] = 0b00000000000000010000000000000010;
	rom_u_instrucao[5] = 0b00000000000000000000000000000011;
	rom_u_instrucao[6] = 0b00000000000110000000000010001000;
	rom_u_instrucao[7] = 0b00000000000000000000000000000011;
	rom_u_instrucao[8] = 0b00000000000000000000101001001000;
	rom_u_instrucao[9] = 0b00000000000000001001010000000000;

	*sc = rom_u_instrucao[uestado];
	
	opcode =  ((unsigned)IR & mask_opcode) >> 26; //IR[31...26]
	
	ctlend =  *sc >> 19; // ctlend = ControleSeq1 e ControleSeq0
	uestado = mux_UC(ctlend, opcode, uestado);
	
}

/*
 * Funcao que retorna o endereco para a memoria
	obs: o endereco pode ser PC ou ALUOUT dependendo
	do bit setado em IorD dentro de sc
*/
int mux_Memoria(int sc, int PC, int ALUOUT){
	int sel_IorD = 0; //seletor do mux (IorD)
	int address;  //endereco de retorno
	int bit_IorD; //mascara para o seletor IorD do mux

	bit_IorD = 0b00000000000000000010000000000000;
	
	if(bit_IorD & sc) sel_IorD = 1;

	if(sel_IorD == 0) address = PC / 4;//divide PC por 4 para fazer o enderecamento a palavra
	if(sel_IorD == 1) address = ALUOUT;	

	return address;

}

/**
* Funcao que define um acesso a memoria. Pode ser leitura ou escrita
	dependendo do sinais de controles contidos em SC.
  - Retorna o dado manipulado se for leitura
  - ou altera variavel memoria se for escrita
*/
int acesso_Memoria(int sc, int address, int B, int *memoria){
	int sinal_leitura = 0;//sinal para definir se a memoria ira realizar leitura
	int sinal_escrita = 0; //sinal para definir se a memoria ira realizar escrita	
	int bit_memread;
	int bit_memwrite;
	int mem_data;

	bit_memread = 0b00000000000000000100000000000000; //bit 15
	if(bit_memread & sc) sinal_leitura = 1;
	
	bit_memwrite = 0b00000000000000001000000000000000; //bit 16
	if(bit_memwrite & sc) sinal_escrita = 1;	

	if(sinal_leitura == 1) {
		mem_data = memoria[address];
	}
	
	if(sinal_escrita == 1) memoria[address] = B;

	return mem_data;
}

/* Funcao que realiza o shift left 2 bits 
   - retorna o valor shifitado  */
int shift_Left2(int bits){
	
	bits = bits << 2;//faz shift left 2 bits
		
	return bits;
}

/* Funcao que realiza o shift left 16 bits 
   - retorna o valor shifitado  */
int shift_Left16(int bits){
	
	bits = bits << 16;//faz shift left 16 bits
		
	return bits;
}
/* Funcao que concatena os 4 bits mais significativos de PC com IR 
   - retorna o resultado da concatenacao*/
int concatena_PC_IR(int IR, int PC){
	int mask_pc = 0b11110000000000000000000000000000;//mascara para selecionar os bits de PC
	int mask_ir = 0b00001111111111111111111111111111;//mascara para selecionar os bits de IR
	
	mask_ir = IR & mask_ir; //isola IR[28..0]
	
	mask_pc = PC & mask_pc; //isola PC[31..28]
	
	return mask_pc | mask_ir; //concatena PC[31..28] com IR [25..0]
}

/** MUX da ULA entrada (a)
    - retorna PC ou A de acordo com o sinal de controle ALUsrcA*/
int mux_ULA_A(int sc, int PC, int A){
	int mask_ALUsrcA = 0b00000000000000000000000000001000;
	int ALUsrcA;

	ALUsrcA = (sc & mask_ALUsrcA) >> 3;	

	if(ALUsrcA == 0) return PC;
	
	if(ALUsrcA == 1) return A;
	
}

/* Realiza a extensao de sinal */
int Extensao_Sinal(int IR){
	int mask_bit_sinal = 0b00000000000000001000000000000000;
	int mask_IR_15_0 = 0b00000000000000001111111111111111;
	int bit_sinal;	
	int IR_extendido;
	int IR_15_0;

	IR_15_0 = (IR & mask_IR_15_0);//isola IR[15..0]	

	if(IR_15_0 & mask_bit_sinal) bit_sinal = 1;
	else bit_sinal = 0;

	//se o bit_sinal for igual a 0 entao replica o sinal (0) nos 16 bits mais significativos
	if(bit_sinal == 0){
		int mask_sinal_1 = 0b00000000000000001111111111111111;
		IR_extendido = IR_15_0 & mask_sinal_1;		
	} 

	//se o bit_sinal for igual a 1 entao replica o sinal (1) nos 16 bits mais significativos
	if(bit_sinal == 1){
		int mask_sinal_1 = 0b11111111111111110000000000000000;
		IR_extendido = IR_15_0 | mask_sinal_1;		
	} 

	return IR_extendido;
}


/** MUX da ULA entrada (b)
    - retorna B ou 
      4 ou 
      Extensao de Sinal ou 
      Extensao de sinal shift left 2 
    de acordo com o sinal de controle ALUsrcB*/
int mux_ULA_B(int sc,  int IR, int B){
	int mask_ALUsrcB = 0b00000000000000000000000000110000;
	int mask_IR_15_0 = 0b00000000000000001111111111111111;	
	int IR_15_0; //IR com os bits de 15 a 0
	int ALUsrcB; //valor do seletor do mux
	
	ALUsrcB = (sc & mask_ALUsrcB) >> 4;//ALUsrcB contem o valor do seletor do mux

	IR_15_0 = IR & mask_IR_15_0;//isola IR[15..0]

	if(ALUsrcB == 0) return B;

	if(ALUsrcB == 1) return 4;

 	if(ALUsrcB == 2) return Extensao_Sinal(IR_15_0);
	
	if(ALUsrcB == 3) return shift_Left2(Extensao_Sinal(IR_15_0));
	


}

/* Funcao que retorna os "bits" da operacao que a Unidade de Controle Secundaria ira utilizar */
int ULA_OP(int sc){
	int mask_ula_op = 0b00000000000000000000000111000000;
	char ula_op; //valores para ALUOp
	
	ula_op = sc & mask_ula_op;//isola os bits de sc referentes a operacao da ULA
	ula_op = ula_op >> 6;//desloca para direita 6 bits para que o valor seja referente a operacao da ULA

	return ula_op;
}

/** MUX da saida da ULA
    - retorna 
	ula_direto ou 
	ALUOUT ou
	IR concatenado com os 4 bits mais significativos de PC
     de acordo com o sinal de controle PCSource*/
int mux_ULAdireto_ALUOUT_PC(int sc, int ula_direto, int ALUOUT, int IR_PC_concat){
	int mask_pcsource = 0b00000000000000000000011000000000;
	int PCSource;
	
	PCSource = (sc & mask_pcsource) >> 9;
	if(PCSource == 0) return ula_direto;
	
	if(PCSource == 1) return ALUOUT;

	if(PCSource == 2) { return IR_PC_concat;}


}

/* Atualiza PCNew caso os sinais de controle estejam setados (igual ao caminho de dados) */
void escreve_PC(int sc, int valor_PC, int zero, int *PCnew){
	int mask_iszero = 0b00000000000000000000000000000100;
	int mask_pcwritecond = 0b00000000000000000000100000000000;
	int mask_pcwrite = 0b00000000000000000001000000000000;

	int iszero;
	int pcwritecond;
	int pcwrite;
	int mux_iszero;

	iszero = (sc & mask_iszero) >> 2;//isola o sinal de controle IsZero
	pcwritecond = (sc & mask_pcwritecond) >> 11; //isola o sinal de controle PCWriteCond
	pcwrite = (sc & mask_pcwrite) >> 12; //isola o sinal de controle PCWrite
	
	
	if(iszero == 0) mux_iszero = ~zero;//mux_iszero recebe not(zero)
	if(iszero == 1) mux_iszero = zero;
	
	//aqui estao implementadas as portas logicas do caminho de dados referente a PCWrite e PCWriteCond
	//PCNew soh sera escrito caso a condicao seja satisfeita
	if( (pcwrite | (pcwritecond & mux_iszero)) == 1){ 
		*PCnew = valor_PC;
	}
}

/* Atualiza IRnew com mem_data caso o sinal IRWrite esteja setado */
void escreve_IR(int sc, int mem_data, int *IRnew){
	int mask_IR_write = 0b00000000000001000000000000000000;
	int IRWrite;

	IRWrite = (sc & mask_IR_write) >> 18;

	if(IRWrite == 1) *IRnew = mem_data;
}


/* Mux que retorna RT ou RD dependendo do sinal de controle RegDst (bit 1) */
int mux_RegDst(int sc, int IR, int rt){
	
	int mask_rd = 0b00000000000000001111100000000000;
	int mask_RegDst = 0b0000000000000000000000000001;
	int rd;
	int RegDst;
	
	rd = (IR & mask_rd) >> 11; //isola os bits de RD que eh IR[11..15]

	RegDst = (sc & mask_RegDst);
	if(RegDst == 0) return rt;
	if(RegDst == 1) return rd;

}

int mux_MemtoReg(int sc, int IR, int ALUOUT, int MDR, int A){
	int mask_MemtoReg = 0b00000000000000110000000000000000;
	int MemtoReg; //sinal de controle MemtoReg
	int AA = 0; //A precisa ser passado como parametro na main (no momento isso nao acontece)

	MemtoReg = (sc & mask_MemtoReg) >> 16;	

	if(MemtoReg == 0) return ALUOUT;
	
	if(MemtoReg == 1) return MDR;

	if(MemtoReg == 2) return AA = A;

	if(MemtoReg == 3) return shift_Left16(Extensao_Sinal(IR));
}

void Banco_Registradores_Write(int sc, int IR, int ALUOUT, int MDR, int A){
	int mask_RegWrite = 0b00000000000000000000000000000010;
	int mask_rt = 0b00000000000111110000000000000000;	
	int mask_rd = 0b00000000000000001111100000000000;
	int rt, rd;	
	int write_data; //valor para escrever no banco de registradores
	int write_register; //registrador que será escrito caso o sinal de controle RegWrite esteja setado
	int RegWrite; //sinal de controle RegWrite

	
	rt = reg[(IR & mask_rt) >> 16]; //isola os bits de RT que eh IR[20..16]
	rd = reg[(IR & mask_rd) >> 11]; //isola os bits de RD que eh IR[11..15]

	RegWrite = (sc & mask_RegWrite) >> 1;

	if(RegWrite == 1){
		write_register = mux_RegDst(sc, IR, rt);
		write_data = mux_MemtoReg(sc, IR, ALUOUT, MDR, A);
		reg[write_register] = write_data; 
	}
}
void Busca_Instrucao(int sc, int PC, int ALUOUT, int IR, int A, int B, int *PCnew,  int *IRnew, int *MDRnew){
	int address; //serve como endereco da memoria vindo de PC ou ALUOUT (Mux_Memoria)
	int mem_data; //dado vindo da memoria quando lida de PC ou ALUOUT (mux_Memoria)
	int entrada_ula_a, entrada_ula_b;
	int result_ula, ula_direto;
	char zero, overflow, ula_op;	
	int IR_shift2; //IR shift left 2 (IR << 2)
	int IR_PC_concat; //IR concatenado com os 4 bits mais significativos de PC
	int IR_25_0;//IR com os bits 25 a 0 (IR[25..0])
	int mask_IR_25_0 = 0b00000011111111111111111111111111;//mascara para selecionar os bits 25 a 0 de IR
	
	address = mux_Memoria(sc, PC, ALUOUT);

	mem_data = acesso_Memoria(sc, address, B, memoria);
	escreve_IR(sc, mem_data, IRnew);
	
	*MDRnew = mem_data;
	
	IR_25_0 = IR & mask_IR_25_0; //isola IR[25..0]	
	
	IR_shift2 = shift_Left2(IR_25_0);

	IR_PC_concat = concatena_PC_IR(IR_shift2, PC);
	
	entrada_ula_a = mux_ULA_A(sc, PC, A);
	entrada_ula_b = mux_ULA_B(sc, IR, B);

	ula_op = UC_secundaria(ULA_OP(sc), IR);	
	
	ula(entrada_ula_a, entrada_ula_b, ula_op, &result_ula, &zero, &overflow);

	ula_direto = result_ula;
	escreve_PC(sc, mux_ULAdireto_ALUOUT_PC(sc, ula_direto, ALUOUT, IR_PC_concat), zero, PCnew);
	if(IR==0) loop=0;
}

void Decodifica_BuscaRegistrador(int sc, int IR, int PC, int A, int B, int *Anew, int *Bnew, int *ALUOUTnew){
	int mask_rt = 0b00000000000111110000000000000000;
	int mask_rs = 0b00000011111000000000000000000000;
	int rt;
	int rs;
	int IR_15_0, IR_shift2, IR_sinal_estendido;
	int entrada_ula_a, entrada_ula_b, result_ula;
	char ula_op, zero, overflow;

	rt = reg[(IR & mask_rt) >> 16]; //isola os bits de RT que eh IR[20..16]
	rs = reg[(IR & mask_rs) >> 21]; //isola os bits de RS que eh IR[25..21]

	*Anew = rs;
	*Bnew = rt;

	IR_sinal_estendido = Extensao_Sinal(IR); //estende o sinal de IR[15..0]
	IR_shift2 = shift_Left2(IR_sinal_estendido);//shifita IR estendido de left 2

	entrada_ula_a = mux_ULA_A(sc, PC, A);
	entrada_ula_b = mux_ULA_B(sc, IR, B);
	
	ula_op = UC_secundaria(ULA_OP(sc), IR);	
	
	ula(entrada_ula_a, entrada_ula_b, ula_op, &result_ula, &zero, &overflow);

	*ALUOUTnew = result_ula;	
}


void Execucao_CalcEnd_Desvio(int sc, int A, int B, int IR, int PC, int ALUOUT, int *ALUOUTnew, int *PCnew){
	int entrada_ula_a, entrada_ula_b;
	int result_ula;	
	char ula_op, zero, overflow;
	int IR_shift2; //IR shift left 2 (IR << 2)
	int IR_PC_concat; //IR concatenado com os 4 bits mais significativos de PC
	int IR_25_0;//IR com os bits 25 a 0 (IR[25..0])
	int mask_IR_25_0 = 0b00000011111111111111111111111111;//mascara para selecionar os bits 25 a 0 de IR
	
	IR_25_0 = IR & mask_IR_25_0; //isola IR[25..0]	
	
	IR_shift2 = shift_Left2(IR_25_0);
	IR_PC_concat = concatena_PC_IR(IR_shift2, PC);

	entrada_ula_a = mux_ULA_A(sc, PC, A);
	entrada_ula_b = mux_ULA_B(sc, IR, B);	

	ula_op = UC_secundaria(ULA_OP(sc), IR);
	ula(entrada_ula_a, entrada_ula_b, ula_op, &result_ula, &zero, &overflow);

	escreve_PC(sc, mux_ULAdireto_ALUOUT_PC(sc, result_ula, ALUOUT, IR_PC_concat), zero, PCnew);
 		
	*ALUOUTnew = result_ula;
}

void EscreveTipoR_AcessaMemoria(int sc, int B, int IR, int ALUOUT, int PC, int *MDRnew, int *IRnew){
	int address, mem_data;
	int A = 0;//obs: A precisa ser passado como parametro nesta funcao? (falar com o professor)
	int MDR = 0;//obs: MDR precisa ser passado como parametro nesta funcao? (falar com o professor)

	address = mux_Memoria(sc, PC, ALUOUT);

	mem_data = acesso_Memoria(sc, address, B, memoria);
	escreve_IR(sc, mem_data, IRnew);

	*MDRnew = mem_data;

	Banco_Registradores_Write(sc, IR, ALUOUT, MDR, A);	
}


void EscreveRefMem(int sc, int IR, int MDR, int ALUOUT){
	int address, mem_data;
	int A = 0;//obs: A precisa ser passado como parametro nesta funcao? (falar com o professor)
	int PC = 0;//obs: PC precisa ser passado como parametro nesta funcao? (falar com o professor)
	int B = 0;//obs: B precisa ser passado como parametro nesta funcao? (falar com o professor)

	address = mux_Memoria(sc, PC, ALUOUT);

	mem_data = acesso_Memoria(sc, address, B, memoria);
	Banco_Registradores_Write(sc, IR, ALUOUT, MDR, A);
}
