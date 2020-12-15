.data
 /* Definicion de datos */
/* Mapa */
mapa: .asciz "+------------------------------------------------+\n|               ****************                 |\n|               *** VIBORITA ***                 |\n|               ****************                 |\n+------------------------------------------------+\n|                                                |\n|                                                |\n|                                                |\n|                                                |\n|                    M                           |\n|                                                |\n|                                                |\n|                                                |\n|                                                |\n+------------------------------------------------+\n| Puntaje:                      Nivel: 1         |\n+------------------------------------------------+\n" 
longitud = . - mapa

/* Limpiar pantalla */
cls: .asciz "\x1b[H\x1b[2J" @ una manera de borrar la pantalla usando ansi escape codes
lencls = .-cls                @ Borra la pantalla :)

/* GameOver */
gameover: .byte 0 @ 0 = falso , 1 = verdadero
mensajeGameOver: .asciz "GAME OVER"
posicionMensajeGameOver: .int 479

/* Lectura Tecla */
mensajeMovimiento: .asciz "Ingrese instruccion de movimiento:"
lenMen = . - mensajeMovimiento
tecla: .byte ' '
       .align


/* Snake  */
snake: .asciz "@*************************"
posicionesSnake: .int 420,421,422,423,-200,-200,-200,-200,-200,-200,-200,-200,-200,-200,-200,-200,-200,-200,-200,-200,-200,-200,-200
lenSnake: .byte 4
cabeza: .word 420
cola: .word 421


/* Puntaje */
puntos: .int 0000

mil: .int 9999
cien: .int 999
docena: .int 99
unidad: .int 9

divMil: .int 1000

puntosTexto: .asciz "    "
lenPuntosTexto = . - puntosTexto
posicionPuntaje: .word 775

millarRespuesta: .int 0
centenaRespuesta: .int 0
decenaRespuesta: .int 0
unidadRespuesta: .int 0

resultadoDivision: .int 0
restoDivision: .int 0

/* Manzana */
seed: .word 1
const1: .word 1103515245
const2: .word 12345
numero: .word 0

posicionMaxima: .int 661
posicionMinima: .int 256
posicionesNoDisponibles: .int 305,306,356,357,407,408,458,459,509,510,560,561,611,612


.text @ Definición de código del programa

imprimirPantalla: @ Se imprime la pantalla
    .fnstart
        push {lr}

        cmp r12,#1
        beq finalDelJuego

        bl dibujarSnake
        bl imprimirPuntos
        bal imprimirMapa

    finalDelJuego:
        bl imprimirGameOver
        bl imprimirPuntos
        
    imprimirMapa:
        mov r7, #4	@ Salida por pantalla  
        mov r0, #1      @ Indicamos a SWI que será una cadena
        ldr r2, =longitud @Tamaño de la cadena
        ldr r1, =mapa@ Cargamos en r1 la dirección del mensaje
        swi 0		@ SWI, Software interrupt
        
        pop {lr}
        bx lr
    .fnend   

moverSnake: @ Procesar entrada
    .fnstart
        push {lr}

        bl MensajeSiguienteMovimiento

        validarTecla:
            bl leerTecla
            bl validarAWSDQ @ Si tecla no es valida, cambia tecla a ' '
            ldr r0,=tecla
            ldrb r1,[r0]

            cmp r1,#' '
            beq validarTecla @Si r1 (tecla) != ' ' salir, si no loop de pedirTecla

        bl limpiarSnake @ Elimina a snake de pantalla para eleminar rastro.
        bl procesarDireccion @ Procesa el movimiento, solo actualiza el valor de la cabeza
        bl actualizarPosicionesSnake @ Desplaza la posicion de la izquierda a la derecha

    salirMoverSnake:
        pop {lr}
        bx lr
    .fnend    

gameOver:
    .fnstart
        push {lr}
        cmp r12,#1 @ Si r12 = 1 -> Game over
        beq finDelJuego @ fin

        bal salirGameOver

    finDelJuego:
        bl limpiarPantalla
        bl imprimirPantalla
        bal fin

    salirGameOver:    
        pop {lr}
        bx lr
    .fnend    

limpiarPantalla:
    .fnstart
       
        push {lr}
        mov r0, #1
        ldr r1, =cls
        ldr r2, =lencls
        mov r7, #4
        swi #0

        pop {lr}
        bx lr
    .fnend    


/* esta funcion solo dibuja a snake 
    necesita como parametro:
        r1 = Vibora
        r2 = Len
        r3 = posicionSnake
        r4 = Mapa
    ___________________
        r5 = Index cadena snake    
*/
dibujarSnake: 
    .fnstart
        push {lr}

        ldr r0,=lenSnake
        ldrb r2,[r0]

        mov r4,#0  @ R4 = Indice lista posicionesSnake
       
        mov r5,#0 @ Indice Cadena Snake

        ldr r10,=posicionesSnake

    recorrerSnake:
        cmp r5,r2    
        beq salirDibujarSnake

        ldr r0,=snake
        ldrb r1,[r0,r5]

        ldr r3,[r10,r4]

        ldr r0,=mapa
        strb r1,[r0,r3]
        add r4,#4
        add r5,#1
        
        bal recorrerSnake
        
    salirDibujarSnake:
        pop {lr}
        bx lr
    .fnend  


MensajeSiguienteMovimiento:
    .fnstart
        push {lr}   

        mov r7, #4	@ Salida por pantalla  
        mov r0, #1      @ Indicamos a SWI que será una cadena
        ldr r2,=lenMen
        ldr r1, =mensajeMovimiento@ Cargamos en r1 la dirección del mensaje
        swi 0		@ SWI, Software interrupt

        pop {lr}
        bx lr
    .fnend  

leerTecla:
    .fnstart
        push {lr}      

        mov r7,#3 @Lectura teclado
        mov r0,#0 @Ingreso cadena
        mov r2,#2 @cantidad caracteres a escribir
        ldr r1,=tecla
        swi 0

    
        pop {lr}
        bx lr
    .fnend    


/* r3 = tecla */
validarAWSDQ:
    .fnstart
        push {lr}    
            ldr r0,=tecla
            ldrb r3,[r0]

               cmp r3,#'a'
            beq salirValidarAWSDQ

            cmp r3,#'d'
            beq salirValidarAWSDQ
            
            cmp r3,#'s'
            beq salirValidarAWSDQ

            cmp r3,#'w'
            beq salirValidarAWSDQ

            cmp r3,#'A'
            beq salirValidarAWSDQ

            cmp r3,#'D'
            beq salirValidarAWSDQ
            
            cmp r3,#'S'
            beq salirValidarAWSDQ
            
            cmp r3,#'W'
            beq salirValidarAWSDQ

            cmp r3,#'q'
            beq salirValidarAWSDQ

            cmp r3,#'Q'
            beq salirValidarAWSDQ

            ldr r0,=tecla
            mov r4,#' '
            strb r4,[r0]

    salirValidarAWSDQ:
        pop {lr}
        bx lr
    .fnend    

limpiarSnake:
        .fnstart
            push {lr}

            ldr r0,=lenSnake
            ldrb r1,[r0]    

            mov r3,#0 @ indice posiciones snake

            mov r4,#0 @Indice ciclo

            mov r5,#' ' @Para limpiar

        reemplazarConEspacio:
            ldr r0,=posicionesSnake
            ldr r2,[r0,r3]

            cmp r4,r1
            beq salirLimpiarSnake

            ldr r0,=mapa
            strb r5,[r0,r2]

            add r3,#4
            add r4,#1
            bal reemplazarConEspacio

        salirLimpiarSnake:
            pop {lr}    
            bx lr
        .fnend      


 procesarDireccion:
            /*
                Actuliza el valor de la cabeza de la snake, y guarda el ultimo en cabeza.
                    let cabeza = lista[0] // 420
                    let cola = 0
                    lista[0] = lista[0] + desplazamiento // 368
            */  
            .fnstart
                push {lr}  

                ldr r0,=tecla
                ldrb r1,[r0]

                cmp r1,#'d'
                beq derecha

                cmp r1,#'D'
                beq derecha

                cmp r1,#'a'
                beq izquierda

                cmp r1,#'A'
                beq izquierda
                
                cmp r1,#'w'
                beq arriba

                cmp r1,#'W'
                beq arriba

                cmp r1,#'s'
                beq abajo

                cmp r1,#'S'
                beq abajo

                cmp r1,#'q'
                beq fin

                cmp r1,#'Q'
                beq fin

                bal salirProcesarDireccion

            derecha:
                ldr r0,=posicionesSnake
                ldr r2,[r0,#0] @Solo necesitamos la primera posicion
                ldr r0,=cabeza @ R0 = Cabeza
                str r2,[r0]  @ cabeza = lista[0]
                add r2,#1
                ldr r0,=posicionesSnake 
                str r2,[r0,#0] @ lista[0] = lista[0] + 1

                bal salirProcesarDireccion

            izquierda:
                ldr r0,=posicionesSnake
                ldr r2,[r0,#0] @Solo necesitamos la primera posicion
                ldr r0,=cabeza @ R0 = Cabeza
                str r2,[r0]  @ cabeza = lista[0]
                sub r2,#1
                ldr r0,=posicionesSnake
                str r2,[r0,#0] @ lista[0] = r2
                
                
                bal salirProcesarDireccion    

            arriba:
                ldr r0,=posicionesSnake
                ldr r2,[r0,#0] @Solo necesitamos la primera posicion
                ldr r0,=cabeza @ R0 = Cabeza
                str r2,[r0]  @ cabeza = lista[0]
                sub r2,#51
                ldr r0,=posicionesSnake
                str r2,[r0,#0] @ lista[0] = r2
                
                bal salirProcesarDireccion

            abajo:
                ldr r0,=posicionesSnake
                ldr r2,[r0,#0] @Solo necesitamos la primera posicion
                ldr r0,=cabeza @ R0 = Cabeza
                str r2,[r0]  @ cabeza = lista[0]
                add r2,#51
                ldr r0,=posicionesSnake
                str r2,[r0,#0] @ lista[0] = r2
                
                bal salirProcesarDireccion  

            salirProcesarDireccion:
                pop {lr}        
                bx lr
            .fnend            
/**Funcion que desplaza las posiciones y las actualiza */
actualizarPosicionesSnake:
            .fnstart
                push {lr}

                ldr r0,=posicionesSnake
                ldr r1,[r0,#4] @lista[1]
                mov r5,#4 @Indice lista (incrementa de 4 en 4)

                ldr r0,=lenSnake
                ldrb r2,[r0] @len lista
            
                ldr r0,=cola
                ldr r4,[r0] @cola

                
                mov r6,#1 @Indice de ciclo

            actualizarCuerpo:
                cmp r6,r2
                beq salirActualizarPosicionesSnake

                ldr r0,=cola
                str r1,[r0] @ cola = lista[r5] 421

                ldr r0,=cabeza
                ldr r3,[r0] @cabeza 420

                ldr r0,=posicionesSnake
                str r3,[r0,r5] @ lista[r5] = r3 (cabeza) 419,420,422,423

                ldr r0,=cabeza
                ldr r10,=cola
                ldr r4,[r10] @cola
                str r4,[r0] @ cabeza = cola
                add r6,#1
                add r5,#4
                ldr r0,=posicionesSnake
                ldr r1,[r0,r5] @lista[1]
                str r1,[r10] @Cola = 422
                
                bal actualizarCuerpo

            salirActualizarPosicionesSnake:

                pop {lr}
                bx lr
            .fnend   

colisiones:
    .fnstart
        push {lr}

        bl verificarColisionManzana
        bl verificarColisionPared
        bl verificarColisionCuerpoVibora

        pop {lr}
        bx lr
    .fnend

 verificarColisionPared:
    .fnstart
        push {lr}

            ldr r0,=posicionesSnake
            ldr r1,[r0,#0]   @ R0 = Cabeza de snake

            ldr r0,=mapa
            ldrb r2,[r0,r1]

            cmp r2,#'-'
            beq colisionPared

            cmp r2,#'|'
            beq colisionPared

            bal salirVerificarColisionPared

    colisionPared:
        mov r12,#1

    salirVerificarColisionPared:
        pop {lr}
        bx lr
    .fnend         
    

verificarColisionCuerpoVibora:
    .fnstart
        push {lr}

            ldr r0,=posicionesSnake
            ldr r1,[r0,#0]   @ R0 = Cabeza de snake
            
            ldr r0,=lenSnake
            ldrb r3,[r0] @ Len snake

            mov r4,#4 @ Acumulador lista posiciones snake

            mov r5,#1 @Indice

            ldr r0,=posicionesSnake
            ldr r6,[r0,#4]   @ R6 = Cola
            

        compararCabezaConPosicionesCuerpo:
            cmp r5,r3  @ While r5 <= lenSnake
            bgt salirVerificarColisionCuerpoVibora
        
            cmp r1,r6
            beq colisionCuerpoVibora

            add r4,#4
            add r5,#1

            ldr r0,=posicionesSnake
            ldr r6,[r0,r4]

            bal compararCabezaConPosicionesCuerpo

    colisionCuerpoVibora:
        mov r12,#1

    salirVerificarColisionCuerpoVibora:
        pop {lr}
        bx lr
    .fnend   

verificarColisionManzana:
    .fnstart
        push {lr}

            ldr r0,=posicionesSnake
            ldr r1,[r0,#0]   @ R0 = Cabeza de snake

            ldr r0,=mapa
            ldrb r2,[r0,r1]

            cmp r2,#'M'
            beq colisionConManzana   

            bal salirVerificarManzana

    colisionConManzana:
        bl incrementarPuntos
        bl incrementarLenSnake @Incrementar cadena snake, len snake y posiciones snake

        manzanaAleatoria:
            bl myrand
            mov r1,r0 @R1 valor aleatorio
            mov r2,#60
            bl dividir

            ldr r1,=resultadoDivision
            ldr r3,[r1]

            ldr r0,=posicionMaxima
            ldr r1,[r0]

            cmp r3,r1 @Si numero aleatorio es mas grande que el maximo permitido se pide otra vez
            bgt manzanaAleatoria

            ldr r0,=posicionMinima
            ldr r1,[r0]

            cmp r3,r1 @Si numero aleatorio es mas pequeño que el minimo permitido se pide otra vez
            blt manzanaAleatoria

            mov r2,#0 @ Indice para leer cadena
            mov r5,#14 @ len de cadena
            mov r4,#0 @ indice iteracion
           
        compararConPosicionesNoDisponibles:
            ldr r0,=posicionesNoDisponibles
            ldr r1,[r0,r2]

            cmp r4,r5 @mientras indice es menor a len: recorrer lista posiciones no disponibles
            bgt verificarEspacioDisponibleManzana

            cmp r3,r1 @Comparamos numero aleatorio con posiciones no disponibles
            beq manzanaAleatoria

            add r2,#4
            add r4,#1
            bal compararConPosicionesNoDisponibles

        verificarEspacioDisponibleManzana:
            ldr r0,=mapa
            ldrb r1,[r0,r3] @ R3 = numero aleatorio valido
        
            cmp r1,#'|'
            beq manzanaAleatoria

            cmp r1,#'-'
            beq manzanaAleatoria

        
            mov r6,#0 @Indice para iterar
            ldr r0,=lenSnake
            ldrb r7,[r0] @ r7 = Len snake

            mov r8,#0 @ Indice posiciones snake, avanza de 4 en 4

        verificarColisionManzanaSnake:  
            cmp r6,r7
            bgt salirVerificarManzana

            ldr r0,=posicionesSnake
            ldr r1,[r0,r8]
             
            cmp r1,r3 @Comparamos si numero random es igual a posicion de snake
            beq manzanaAleatoria

            add r8,#4
            add r6,#1
            bal verificarColisionManzanaSnake


    salirVerificarManzana:
        mov r2,#'M'
        ldr r0,=mapa
        strb r2,[r0,r3]

        pop {lr}
        bx lr
    .fnend      

imprimirPuntos:
    .fnstart
        push {lr}

        bl convertirPuntosATexto

        ldr r0,=posicionPuntaje
        ldr r1,[r0]

        mov r2,#0 @Indice desplazamiento puntosTexto
        ldr r0,=puntosTexto
        ldrb r3,[r0]

    recorrerPuntosTexto:
        cmp r2,#4
        beq salirImprimirPuntos

        ldr r0,=mapa
        strb r3,[r0,r1]
        add r1,#1 @ Posicion + 1
        add r2,#1 @ indice desplazamiento cadena + 1
        ldr r0,=puntosTexto
        ldrb r3,[r0,r2]
        bal recorrerPuntosTexto

    salirImprimirPuntos:
        pop {lr}
        bx lr
    .fnend    

incrementarPuntos:
    .fnstart
        push {lr}

        ldr r0,=puntos
        ldr r1,[r0] @ R1 = Puntos
        add r1,#1
        str r1,[r0]

        pop {lr}
        bx lr
    .fnend    


dividir:
    .fnstart
        push {lr}
        mov r11,#0 @ cociente
    restar: 
        cmp r2,r1
        bgt salirDividir

        sub r1,r2
        add r11,#1
        bal restar

    salirDividir:
        ldr r0,=resultadoDivision
        str r11,[r0]
        ldr r0,=restoDivision
        str r1,[r0]
        pop {lr}
        bx lr
    .fnend   

separarNumeroEnUnidades:
        .fnstart
            push {lr}

            ldr r0,=puntos
            ldr r9,[r0] @ r9 numero a convertir

            ldr r0,=mil
            ldr r2,[r0] @ 9999

            ldr r0,=cien
            ldr r3,[r0] @ 999

            ldr r0,=docena
            ldr r4,[r0] @ 99

            ldr r0,=unidad
            ldr r5,[r0] @ 9

            cmp r9,r2
            bgt salir

            cmp r9,r3
            bgt millar

            cmp r9,r4
            bgt centenar

            cmp r9,r5
            bgt decenar

            cmp r9,#0
            bgt unidar

            cmp r9,#0
            blt salir

            millar:
                ldr r0,=divMil
                ldr r2,[r0] @R2 = 1000 para dividir
                mov r1,r9
                bl dividir
                ldr r0,=resultadoDivision
                ldr r11,[r0]
                ldr r0,=millarRespuesta
                str r11,[r0]

            centenar:
                mov r2,#100
                ldr r0,=millarRespuesta 
                ldr r3,[r0] @ R3 = numero millar

                ldr r0,=divMil
                ldr r4,[r0] @R4 = 1000

                mov r10,#0 @ En R10 guardamos una variable para usar en la cuenta

                mul r10,r3,r4 @ r10 = r3 * r4 o num Millar * 1000

                
                sub r1,r9,r10
                bl dividir
                ldr r0,=resultadoDivision
                ldr r11,[r0]
                ldr r0,=centenaRespuesta
                str r11,[r0]
               
            decenar:
                mov r2,#10

                ldr r0,=millarRespuesta 
                ldr r3,[r0] @ R3 = numero millar

                ldr r0,=centenaRespuesta
                ldr r4,[r0] @ R4 = numero centenar

                ldr r0,=divMil
                ldr r5,[r0] @R5 = 1000

                mov r10,#100 @solucion error mul r4,#100
                mul r3,r5
                mul r4,r10
                add r3,r4
                
                sub r1,r9,r3
                bl dividir
                ldr r0,=resultadoDivision
                ldr r11,[r0]
                ldr r0,=decenaRespuesta
                str r11,[r0]
                
            
            unidar:
                ldr r0,=millarRespuesta
                ldr r2,[r0]

                ldr r0,=centenaRespuesta
                ldr r3,[r0]

                ldr r0,=decenaRespuesta
                ldr r4,[r0]

                ldr r0,=divMil
                ldr r5,[r0] @R5 = 1000
                
                mov r10,#100 @solucion error mul r4,#100
                mov r11,#10 @solucion error mul r4,#100
                mul r2,r5
                mul r3,r10
                mul r4,r11
                add r2,r3
                add r2,r4
                mov r11,#0 @ Seteado en 0 para guarda dato
                sub r11,r9,r2

                ldr r0,=unidadRespuesta
                str r11,[r0]
            salir:
                pop {lr}
                bx lr
        .fnend  

       
convertirPuntosATexto:
    .fnstart
        push {lr}

        bl separarNumeroEnUnidades
        
        ldr r0,=millarRespuesta
        ldr r1,[r0]

        ldr r0,=centenaRespuesta
        ldr r2,[r0]

        ldr r0,=decenaRespuesta
        ldr r3,[r0]

        ldr r0,=unidadRespuesta
        ldr r4,[r0]

        ldr r0,=puntosTexto
        add r1,#0x30
        add r2,#0x30
        add r3,#0x30
        add r4,#0x30
        strb r1,[r0,#0]
        strb r2,[r0,#1]
        strb r3,[r0,#2]
        strb r4,[r0,#3]


        pop {lr}
        bx lr
    .fnend  

incrementarLenSnake:
    .fnstart
        push {lr}

        ldr r0,=lenSnake
        ldrb r1,[r0]

        mov r4,#4

        mul r1,r4 @Obtengo el indice de la ultima posicion de snake
        ldr r0,=posicionesSnake
        ldr r3,[r0,r1]
        add r3,#1 @ Sumo uno a la cola, para agregar nueva pieza de cuerpo.

        add r1,#4 @ Me dara el indice de la cola
        ldr r0,=posicionesSnake
        str r3,[r0,r1]

        ldr r0,=lenSnake
        ldrb r1,[r0]
        add r1,#1
        strb r1,[r0]

        pop {lr}
        bx lr
    .fnend      


imprimirGameOver:
    .fnstart
        push {lr}

        ldr r0,=mensajeGameOver
        ldrb r1,[r0] @Caracteres cadena R1
        mov r2,#0 @Indice Cadena

        ldr r0,=posicionMensajeGameOver
        ldr r3,[r0] @ R3 = Posicion donde escribimos mensaje


    iteracionMensajeGameOver:
        cmp r1,#00 @ Hasta que termine la cadena
        beq salirImprimirGameOver

        ldr r0,=mapa
        strb r1,[r0,r3]
        add r3,#1 @Aumentamos posicion para el mapa
        add r2,#1 @Aumentamos indice para cadena mensajaGameOver
        ldr r0,=mensajeGameOver
        ldrb r1,[r0,r2] @Caracteres cadena R1
        bal iteracionMensajeGameOver
        
    salirImprimirGameOver:
        pop {lr}
        bx lr
    .fnend    


myrand:
	.fnstart
		push {lr}
		ldr r1, =seed @ leo puntero a semilla
		ldr r0, [ r1 ] @ leo valor de semilla
        ldr r2, =const1
		ldr r2, [ r2 ] @ leo const1 en r2
		mul r3, r0, r2 @ r3= seed * 1103515245
		ldr r0, =const2
		ldr r0, [ r0 ] @ leo const2 en r0
		add r0, r0, r3 @ r0= r3+ 12345
		str r0, [ r1 ] @ guardo en variable seed
/* Estas dos lí neas devuelven "seed > >16 & 0x7fff ".
Con un peque ño truco evitamos el uso del AND */
		LSL r0, #1
		LSR r0, #17
		pop {lr}
		bx lr
	.fnend

mysrand:
	.fnstart
		push {lr}
		ldr r1, =seed
		str r0, [ r1 ]
		pop {lr}
		bx lr
	.fnend
main:    

               
/*
Game Over  -> 1 verdadero - 0 falso -> 1 termina el juego, gameover - 0 continua
r12 = gameover 

*/
.global main

main:

    ldr r0,=gameover @ Cargamos la direccion de gameover en r0
    ldrb r12,[r0]    @ Cargamos el valor de gameover en r12

    mov r0, # 42   @  se puede cambiar el valor
	bl mysrand   @ se usa una sola vez al principio del programa

juego:

    bl imprimirPantalla
    bl moverSnake
    bl colisiones
    bl gameOver 
    bl limpiarPantalla
    bal juego

fin:
    mov r7,#1
    swi 0
