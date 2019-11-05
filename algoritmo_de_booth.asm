#########################== CABEÇALHO ==#########################
#                                                               #
# REGISTRADORES:                                                #
#   $s0      ->  Multiplicando                                  #
#   $v1      ->  Multiplicador                                  #
#   $t0/$Hi  ->  Parte mais significativa do Produto            #
#   $t1/$Lo  ->  Parte menos significativa do Produto           #
#   $t2      ->  Bit extra do produto                           #
#   $t3      ->  Armazenamento do LSB de Lo                     #
#   $t4      ->  Armazenamento do LSB de Hi                     #
#   $t5      ->  Iterador                                       #
#   $t6      ->  Limite do iterador                             #
#   $t7      ->  Resultador do XOR entre $t3 e $t2              #
#   $t8      ->  Condição                                       #
#                                                               #
#################################################################

.data
    MULTIPLICANDO: .asciiz "Insira o multiplicando: "
    MULTIPLICADOR: .asciiz "Insira o multiplicador: "
    VALORHI:       .asciiz "O valor de Hi é: "
    VALORLO:       .asciiz "O valor de Lo é: "
    LINHA:         .asciiz "\n"

.text
    main:
        # Impressão e leitura do multiplicando
        li $v0, 4
        la $a0, MULTIPLICANDO
        syscall

        li $v0, 5
        syscall
        move $s0, $v0


        # Impressão e leitura do multiplicador
        li $v0, 4
        la $a0, MULTIPLICADOR
        syscall

        li $v0, 5
        syscall
        move $s1, $v0

        # Chamada da função de multiplicação
        move $v0, $s0
        move $v1, $s1
        jal multfac
        
        mfhi $s3
        mflo $s4

        # Printando as saídas
        # HI
        li $v0, 4
        la $a0, VALORHI
        syscall     

        li $v0, 1
        move $a0, $s3
        syscall

        li $v0, 4
        la $a0, LINHA
        syscall

        # Lo 
        li $v0, 4
        la $a0, VALORLO
        syscall

        li $v0, 1
        move $a0, $s4
        syscall

        li $v0, 4
        la $a0, LINHA
        syscall

        # Encerramento do programa
        j exit


    multfac:
        # Iterador = 0
        addi $t5, $zero, 0

       # Limite da iteração
       addi $t6, $zero, 32

        # Zerar o bit extra
        addi $t2, $zero, 0

        # Zerar o Hi
        addi $t0, $zero, 0

        # Copiar o Multiplicador no Lo
        addi $t1, $v1, 0

        loop:
	   #LSB de Hi
           andi $t4, $t0, 1

           #LSB de Lo
            andi $t3, $t1, 1
            
            # Verificar condição de soma ou subtração
            xor $t7, $t3, $t2
            beq $t7, $zero, passo3
            
            passo2:
                beq $t2, $zero, subtracao
                add $t0, $t0, $v0
                j passo3

                subtracao:
                    sub $t0, $t0, $v0
                    j passo3
                    
            
            passo3:
            	#LSB de Hi
            	andi $t4, $t0, 1

           	 #LSB de Lo
            	andi $t3, $t1, 1
            
                # Shift aritmético à direita no Hi
                sra $t0, $t0, 1

                # Shift lógico à direita no Lo
                srl $t1, $t1, 1

                # Armazenar os LSB
                #Lo (Copiar o LSB de Lo no bit extra)
                add $t2, $t3, $zero

                #Hi (Copiar o LSB de Hi em Lo)
                sll $t4, $t4, 31
                add $t1, $t1, $t4

            
            passo4:
                # Verificação da condição
                addi $t5, $t5, 1
                slt $t8, $t5, $t6
                bne $t8, $zero, loop

        ultimo:
            mthi $t0
            mtlo $t1
            jr $ra

    exit: