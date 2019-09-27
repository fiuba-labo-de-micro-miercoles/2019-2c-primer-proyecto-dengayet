/*
 * ej_parcial_1.asm
 *
 *  Created: 9/26/2019 11:09:49 PM
 *   Author: denise
 */ 

 /* enunciado: dado un vector de 25 números en memoria RAM externa ubicado a partir de la dirección Vec1, 
  * reescribirlo ordenado de mayor a menor a partir de la direccion Vec2. 
  * Los números son enteros sin signo y los vectores no se solapan en ninguna posición. */
  
  .EQU SIZE=25 ;largo del vector
  .DEF INITL=R16
  .DEF INITH=R17
  .DEF CONTADOR=R18
  .DEF V_JMENOS1=R19
  .DEF V_J=R20
  .DEF LARGO=R21

	.DSEG
	.ORG 0x0300 ;declaro los vectores en External SRAM
VEC1: .BYTE SIZE
VEC2: .BYTE SIZE

	.CSEG
	RJMP MAIN

MAIN:
LDI LARGO,SIZE
LDI YL, LOW(VEC1) 
LDI YH, HIGH(VEC1) ;apunto con Y a VEC1

LDI INITL,LOW(VEC1) ;guardo la dirección de memoria de VEC1 
LDI INITH,HIGH(VEC1)
LDI CONTADOR,0 ;inicializo el contador de mi loop 


LOOP1:
	CP LARGO,CONTADOR ;chequeo si estoy en el rango del largo del vector 
	BREQ OUT_1	;si LARGO = CONTADOR salgo del loop
	MOV ZL,YL	
	MOV ZH,YH	;copio el contenido de Y (VEC1 + CONTADOR) en Z
LOOP2:
	CP ZH,INITH	;comparo la parte alta de Z con la parte alta de VEC1
	BREQ CHEQUEO_PARTE_BAJA ;si la parte alta es igual chequeo la parte baja
	BRNE CHEQUEO_ORDEN	;si no es igual entonces Z es mayor, entonces chequeo si VEC1[J-1] >= VEC[J]
CHEQUEO_PARTE_BAJA:
	CP ZL,INITL ;comparo la parte baja de Z con la parte baja de VEC1
	BREQ OUT_2
CHEQUEO_ORDEN:
	LD V_JMENOS1,-Z	;cargo en un registro el contenido de la posición anterior a la que apunta Z (pre-decrementandolo)
	LDD V_J,Z+1	;cargo en otro registro el contendio de la posición siguiente a la que apunta Z (sin incrementarlo)
	CP V_JMENOS1,V_J	;comparo los dos registros
	BRSH OUT_2	;si VEC1[J-1] >= VEC[J] entonces salgo
	STD Z+1,V_JMENOS1 ;para entrar acá debe ser VEC[J-1] < VEC[J]
	ST Z,V_J ;hago el swap de J-1 con J
	JMP LOOP2
OUT_2:
	INC CONTADOR ;incremento el contador
	LD R23,Y+	;incremento el índice que recorre VEC1
	JMP LOOP1 
OUT_1: ;si llegué acá ya ordene el vector, ahora debo guardarlo en VEC2
	LDI CONTADOR,0 ;inicializo el contador en 0
	MOV YL,INITL 
	MOV YH,INITH	;incializo el índice que recorre VEC1
	LDI ZL,LOW(VEC2)	;inicializo el índice que guardará los valores en VEC2
	LDI ZH,HIGH(VEC2)
LOOP3:
	CP LARGO,CONTADOR ;comparo LARGO con CONTADOR
	BREQ OUT_3 ;si LARGO = CONTADOR salgo del loop
	LD R24,Y+	;guardo el contenido de Y (recorre VEC1) y lo post-incremento
	ST Z+,R24 ;guardo el contenido de R24 en Z (apunta VEC2) y lo post-incremento
	INC CONTADOR
	JMP LOOP3	
OUT_3:
	RJMP MAIN


