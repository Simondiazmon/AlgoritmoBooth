INIT_LOOP:  
    MOV ACC, Count  ; Cargamos el número de bits de la arquitectura- CTE dirección de count
    MOV DPTR, ACC   ; Cargamos la dirección de count al DPTR
    MOV ACC, [DPTR] ; Cargamos el valor en la dirección apuntada por DPTR en el ACC
    JZ END_LOOP     ; Salta al final del bucle, Etiqueta duplicada: Final del bucle
    JMP COMPQ   ; Compara ACC con 0 y salta si es negativo, Si (ITERATOR - Count) < 0, ITERATOR < Count
COMPQ: 
    MOV ACC, Q  ; Cargamos una CTE en ACC, CTE - dirección de Q
    MOV DPTR, ACC   ; Movemos Q al puntero
    MOV ACC, [DPTR] ; Dejamos Q en el ACC
    MOV A, ACC  ; Guardamos esa Q en A
    MOV ACC, 0b00000001; Cargamos un 1 para compara con el LSB de Q
    AND ACC, A ; Utilizamos un and para saber si Q0 es 1 o 0
    MOV A, ACC ; guardamos Q0 en el registro A
    MOV ACC, Q_0    ; Cargamos la dirección de Q_0, CTE – Dirección de Q_0
LSB_Q:  
    MOV DPTR, ACC   ; Mueve la dirección de Q_0 al DPTR
    MOV ACC, A  ; Mueve el valor a guardar del registro A al ACC
    MOV [DPTR], ACC ; Q desplazada a la izquierda se guarda en Q_0
load_Q0: ; Vemos si 00 11 y los desplaza a la derecha -> Booth
    MOV ACC, Q_0    ; Carga la dirección de Q0 en el ACC, CTE -> dirección de Q0
    MOV DPTR, ACC   ; Mueve la dirección de Q0 a DPTR
    MOV ACC, [DPTR] ; Carga el valor de Q0 en el ACC
    MOV A, ACC  ; Carga el valor de Q0 en el registro A
load_Q-1:   
    MOV ACC, Q-1    ; Carga la dirección de Q0 en el ACC, CTE - dirección de Q-1
    MOV DPTR, ACC   ; Mueve la dirección de Q-1 a DPTR
    MOV ACC, [DPTR] ; Carga [Q-1] en el ACC
    AND ACC, A  ; Q-1 AND Q0
    MOV A, ACC  ; Carga Q-1 AND Q0 al registro A
CHK_11:
    MOV ACC, 0b11111111
    ADD ACC, A
    JZ  SRA ; Evaluamos si da 0, vamos al caso SHIFT
load_Q0: ; Vemos si 00 11 y los desplaza a la derecha -> Booth
    MOV ACC, Q_0    ; Carga la dirección de Q0 en el ACC, CTE -> dirección de Q0
    MOV DPTR, ACC   ; Mueve la dirección de Q0 a DPTR
    MOV ACC, [DPTR] ; Carga el valor de Q0 en el ACC
    INV ACC         ; si Q0 es 0, pasa a ser 1
    MOV A, ACC  ; Carga el valor de Q0 en el registro A
load_Q-1:   
    MOV ACC, Q-1    ; Carga la dirección de Q0 en el ACC, CTE - dirección de Q-1
    MOV DPTR, ACC   ; Mueve la dirección de Q-1 a DPTR
    MOV ACC, [DPTR] ; Carga [Q-1] en el ACC
    INV ACC     ; si Q-1 es 0, pasa a ser 1
    AND ACC, A  ; Q-1 AND Q0
    MOV A, ACC  ; Carga Q-1 AND Q0 al registro A
CHK_00:
    MOV ACC, 0b00000001
    ADD ACC, A
    JZ  SRA ; Evaluamos si da 0, vamos al caso SHIFT
TEST_10or01:
    MOV ACC, Q_0   ; Carga la dirección de Q0, CTE - dirección de Q_0
    MOV DPTR, ACC   ; Mueve la dirección de Q0 a DPTR
    MOV ACC, [DPTR] ; Carga el valor de Q0 en ACC
    MOV A, ACC  ; Carga el valor de Q0 en el registro A
    MOV ACC, 0b00000001    ; CTE - constante 1, CTE = 1
    AND ACC, A  ; Realiza una operación lógica AND con 1
    JZ  AUX_0   ; Salta si el resultado del AND es igual a 0 (Q_0 es 0), Si no salta, carga la dirección de AND_1
    JMP AND_1   ; Salta a restar uno
AUX_0:  
    MOV ACC, 0b0   ; Carga 0 en ACC
    MOV A, ACC  ; Almacena 0 en AUX_0
    JMP LoadQ-1 ; salta para no hacer inst AND_1
AND_1:  
    MOV ACC, 0b11111111    ; Carga la dirección de AUX_0, Carga un valor de -1
    MOV A, ACC  ; Guarda -1 en el registro A
LoadQ-1:
    MOV ACC, Q-1    ; Carga la dirección de Q-1, Obtiene el valor de Q-1
    MOV DPTR, ACC   ; Mueve la dirección de Q-1 a DPTR
    MOV ACC, [DPTR] ; Obtiene el valor de Q-1
    ADD ACC, A  ; Realiza una suma entre Q-1 y AUX_0
    JN  A-M ; Salta si el resultado de la suma es negativo (Q_0 = -1), Realiza la operación A-M
A+M:
    MOV ACC, VAR_A  ; Carga la dirección de VAR_A
    MOV DPTR, ACC   ; Mueve la dirección de VAR_A a DPTR
    MOV ACC, [DPTR] ; Obtiene el valor de VAR_A
    MOV A, ACC  ; Carga el valor de VAR_A en el registro A
    MOV ACC, M  ; Carga la dirección de la constante M, Obtiene el valor de la constante M
    MOV DPTR, ACC   ; Mueve la dirección de la constante M a DPTR
    MOV ACC, [DPTR]  ; Obtiene el valor de la constante M
    ADD ACC, A  ; Realiza una suma entre VAR_A y M
    MOV A, ACC  ; Carga el resultado en el registro A
STORE_A:
    MOV ACC, VAR_A  ; Carga la dirección de VAR_A, Obtiene la dirección de VAR_A
    MOV DPTR, ACC   ; Mueve la dirección de VAR_A a DPTR
    MOV ACC, A  ; Mueve el valor a guardar del registro A al ACC
    MOV [DPTR], ACC ; Almacena el valor en VAR_A
    JMP SRA ; Salta a la dirección especificada en CTE, Realiza una operación de desplazamiento aritmético a la derecha
A-M:
    MOV ACC, M  ; Carga la dirección de la constante M, Obtiene el valor de la constante M
    MOV DPTR, ACC   ; Mueve la dirección de la constante M a DPTR
    MOV ACC, [DPTR]  ; Obtiene el valor de la constante M
    INV ACC ; Realiza el complemento a 1 de la constante M
    MOV A, ACC  ; Carga el valor complementado en el registro A
    MOV ACC, 0b00000001    ; Carga la dirección de la constante 1, CTE - dirección de la constante 1
    ADD ACC, A  ; Realiza una suma entre 1 y el valor complementado
    MOV A, ACC  ; Carga el resultado en el registro A
    MOV ACC, VAR_A  ; Carga la dirección de VAR_A
    MOV DPTR, ACC   ; Mueve la dirección de la constante VAR_A a DPTR
    MOV ACC, [DPTR] ; Obtiene el valor de A
    ADD ACC, A      ; A - M
    MOV A, ACC      ; guarda A-M en el registro A
STORE_A:    ; Obtiene la dirección de VAR_A
    MOV ACC, VAR_A; 
    MOV DPTR, ACC   ; Mueve la dirección de VAR_A a DPTR
    MOV ACC, A  ; Mueve el valor a guardar del registro A al ACC
    MOV [DPTR], ACC ; Almacena el valor en VAR_A
    JMP SRA ; Salta a la dirección especificada en CTE, Realiza una operación de desplazamiento aritmético a la derecha
SRA:
Des_Q0_Q-1: ; Desplazamos el valor de Q0 a Q-1
    MOV ACC, Q_0    ; Carga la dirección de Q0, Obtiene el valor de Q0
    MOV DPTR, ACC   ; Mueve la dirección de Q0 a DPTR
    MOV ACC, [DPTR] ; Obtiene el valor de [Q0] y lo coloca en ACC
    MOV A, ACC  ; Mueve el valor obtenido a A
    MOV ACC, Q-1    ; Carga la dirección de Q-1, Obtiene el valor de Q-1
    MOV DPTR, ACC   ; Mueve la dirección de Q-1 a DPTR
    MOV ACC, A  ; Mueve el valor de A (Q0) a ACC
    MOV [DPTR], ACC ; Almacena el valor de A (Q0) en Q-1
Des_A0_Q:   ; Desplaza el valor de A hacia la derecha y coloca el MSB en A
    MOV ACC, VAR_A  ; Carga la dirección de A, Obtiene la dirección de A
    MOV DPTR, ACC   ; Mueve la dirección de A a DPTR
    MOV ACC, [DPTR] ; Obtiene el valor de A
    MOV A, ACC  ; Mueve el bit más significativo (MSB) de A a A
    MOV ACC, 0b00000001    ; Carga la dirección de la constante 1, CTE = 1
    AND ACC, A  ; Realiza una operación AND entre 1 y el MSB de A
    MOV A, ACC  ; Mueve el resultado de la operación al registro A
    JZ SHIFTQ ; Comprueba si el MSB de A es 0, Realiza un desplazamiento en Q
    MOV ACC, 0b10000000    ; Carga la dirección de A nuevamente, CTE = 128
    MOV A, ACC  ; Mueve el MSB de A al registro A
    JMP SHIFTQ  ; Salta a la dirección especificada en CTE, Continúa con el desplazamiento en Q
SHIFTQ:
    MOV ACC, Q  ; Carga la dirección de Q, CTE - dirección de Q
    MOV DPTR, ACC   ; Mueve la dirección a DPTR
    MOV ACC, [DPTR] ; Obtiene el valor de [Q] y lo coloca en ACC
    RSH ACC, 0b00000001    ; Realiza un desplazamiento a la derecha de 1 bit, CTE = 1 (1 bit)
    ADD ACC, A  ; Realiza una suma entre el valor en ACC y el MSB de A
    MOV A, ACC  ; Mueve el resultado a A
Load_Q: 
    MOV ACC, Q  ; Carga la dirección de Q, CTE - dirección de Q
    MOV DPTR, ACC   ; Mueve la dirección a DPTR
    MOV ACC, A  ; Mueve el valor en A a ACC
    MOV [DPTR], ACC ; Almacena el valor de ACC en Q
Load_A: 
    MOV ACC, VAR_A	; Carga la dirección de A, Obtiene la dirección de A
    MOV DPTR, ACC	; Mueve la dirección de A a DPTR
    MOV ACC, [DPTR]	; Obtiene el valor de A y lo coloca en ACC
    MOV A, ACC      ;
    MOV ACC, 0b10000000	; Realiza un desplazamiento aritmético hacia la derecha (MSB), CTE = 7 (7 bits)
    AND ACC, A      ; 
    MOV A, ACC		; Mueve el MSB de A a A
    MOV ACC, 0b11111111	; Carga la dirección de la constante 1, CTE - 1 (complemento a 2 de 1)
    ADD ACC, A		; Realiza una suma entre el complemento a 2 de 1 y el MSB de VAR_A
    JZ SH+1A		; Comprueba si el resultado es 0, Realiza un desplazamiento aritmético preservando el signo
    JN SHIFTA  ; Comprueba si el resultado es negativo (signo negativo), Realiza un desplazamiento aritmético sin preservar el signo
SH+1A:
    MOV ACC, VAR_A	; Carga la dirección de A, Obtiene la dirección de A
    MOV DPTR, ACC	; Mueve la dirección de A a DPTR
    MOV ACC, [DPTR]	; Obtiene el valor de A y lo coloca en ACC
    RSH ACC, 0b00000001	; Realiza un desplazamiento aritmético hacia la derecha sin preservar el signo, CTE = 1 (1 bit)
    MOV A, ACC		; Mueve el resultado a A
    MOV ACC, 0b10000000	; Carga la dirección de la constante 128
    ADD ACC, A		; Realiza una suma entre 128 y el valor en A
    MOV A, ACC		; Mueve el resultado a A
LoadA:	    
    MOV ACC, VAR_A	; Carga la dirección de A, Obtiene la dirección de A
    MOV DPTR, ACC	; Mueve la dirección de A a DPTR
    MOV ACC, A		; Mueve el valor en A a ACC
    MOV [DPTR], ACC	; Almacena el valor en A
    JMP Inc_it		; Salta a la dirección especificada en CTE  
SHIFTA:;HACER DESPLAZAMiENTO SIN SUMAR 128 (1000 0000)
    MOV ACC, VAR_A  ; Carga la dirección de la variable VAR_A, Obtiene la dirección de VAR_A
    MOV DPTR, ACC   ; Mueve la dirección de VAR_A a DPTR
    MOV ACC, [DPTR] ; Carga el valor de VAR_A en ACC
    RSH ACC, 0b00000001    ; Realiza un desplazamiento aritmético a la derecha en ACC, CTE = 1, indica un desplazamiento de 1 bit
    MOV [DPTR], ACC ; Almacena el valor desplazado de VAR_A en la dirección de VAR_A
    JMP Inc_it  ; Salta a la dirección especificada en CTE
Inc_it: 
	MOV ACC, Count 	    ;CTE - direccion de Count
	MOV DPTR, ACC	    ;Mueve la dirección de Count a DPTR
	MOV ACC, [DPTR]	    ;Carga el valor de VAR_A en ACC
	MOV A, ACC		    ;Carga el valor de VAR_A en el registro A
	MOV ACC, 0b11111111	;CTE = -1
    ADD ACC, A		    ;Count - 1 
    MOV [DPTR], ACC     ;Se almacena el valor de COUNT
    JZ END_LOOP;Si da 0 termina el ciclo
    JMP INIT_LOOP	    ;Volvemos al inicio
END_LOOP:  
    HLT ; Fin del bucle

VAR_A: 0b00
Q: 0b01110011
Q-1: 0b0
M: 0b01100101
Count: 0x8
Q_0:0b00000000
