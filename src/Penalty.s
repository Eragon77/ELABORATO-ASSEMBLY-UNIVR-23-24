   .section .data
    A_2:
        .ascii "0"
  
    Penalita_testo:
        .ascii "\n\n\n\nPenalty: "
    Penalita_testo_len:
        .long . -Penalita_testo
    contatore_cifre:
    .long 0

    .macro stampa_pen
        movl $4, %eax # CARICO IN EAX IL CODICE DELLA SYSCALL WRITE
        movl  $1, %ebx # STDOUT
        leal A_2, %ecx # INDIRIZZO DELLA RICHIESTA IN ECX
        movl $1, %edx # LUNGHEZZA DELLA STRINGA DA STAMPARE IN EDX
        int $0x80 # INTERRUPT
    .endm
    
    .section .text
    
    .global Penalty # rende visibile il simbolo risultati al linker

    .type Penalty, @function # dichiarazione della funzione

    Penalty:
    movl %esp, %ebp # %ebp = cima della pila


    preparo_conclusione:

        movl 4(%ebp), %eax # Valore Conclusione (e' un long)
        movl $10, %ebx # METTO LONG 10 IN EBX
        xorl %edx,%edx # LO AZZERO IN QUANTO PRENDE PARTE ALLA DIVISIONE TRA LONG.
        leal A_2, %esi # ASSEGNO A EDI INDIRIZZO DI MEMORIA STRINGA A (SERVE PER LA STAMPA DI OGNI CIFRA)



    inizioCiclo_C:
        incl (contatore_cifre) # INCREMENTO IL CONTATORE DELLE CIFRE
        divl %ebx	# divido per 10 in long, il risultato sara' in EAX (quoziente) e EDX (resto)
        pushl %edx # SALVO IL RESTO DELLA DIVISIONE NELLO STACK
        xorl %edx,%edx # AZZERO EDX
        cmpl $0, %eax # SE IL QUOZIENTE E' 0, VADO ALLA STAMPA.
        je preparo_stampa_C
        jmp inizioCiclo_C # Altrimenti, continuo a dividere

    preparo_stampa_C:
        movl (contatore_cifre), %ecx

    stampo_C:
    popl %edx
    addl $48, %edx
    movl %edx, (%esi) # SPOSTO LA CIFRA NELLA STRINGA
    pushl %ecx
    stampa_pen
    popl %ecx
    loop stampo_C

     testo_Penalty:

    
        movl $4, %eax # CARICO IN EAX IL CODICE DELLA SYSCALL WRITE
        movl $1, %ebx # STDOUT
        leal Penalita_testo, %ecx # INDIRIZZO DELLA RICHIESTA IN ECX
        movl Penalita_testo_len, %edx # LUNGHEZZA DELLA STRINGA DA STAMPARE IN EDX
        int $0x80 # INTERRUPT

        xorl %edx,%edx # LO AZZERO IN QUANTO PRENDE PARTE ALLA DIVISIONE TRA LONG.
        movl 8(%ebp), %eax # Valore Penalita (e' un long)
        movl $10, %ebx # METTO LONG 10 IN EBX
        leal A_2, %esi # ASSEGNO A EDI INDIRIZZO DI MEMORIA STRINGA A (SERVE PER LA STAMPA DI OGNI CIFRA)
        movl $0, (contatore_cifre)


    inizioCiclo_P:
        incl (contatore_cifre) # INCREMENTO IL CONTATORE DELLE CIFRE
        divl %ebx	# divido per 10 in long, il risultato sara' in EAX (quoziente) e EDX (resto)
        pushl %edx # SALVO IL RESTO DELLA DIVISIONE NELLO STACK
        xorl %edx,%edx # AZZERO EDX
        cmpl $0, %eax # SE IL QUOZIENTE E' 0, VADO ALLA STAMPA.
        je preparo_stampa_P
        jmp inizioCiclo_P # Altrimenti, continuo a dividere

    preparo_stampa_P:
        movl (contatore_cifre), %ecx

    stampo_P:
    popl %edx
    addl $48, %edx
    movl %edx, (%esi) # SPOSTO LA CIFRA NELLA STRINGA
    pushl %ecx
    stampa_pen
    popl %ecx
    loop stampo_P


fine:
movl $0,(contatore_cifre)
    ret
    


        



