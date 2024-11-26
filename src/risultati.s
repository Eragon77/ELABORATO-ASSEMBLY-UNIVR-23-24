    ####################
    # filename: risultati.s
    ####################
    .section .data
    nuovalinea:
        .ascii "\n"
    nuovalinea_len:
        .long . -nuovalinea
    A:
        .ascii "0"
    salvo_resto:
        .byte -1 
    salvo_seconda_cifra:
        .byte -1

    ID_Inizio_testo:
        .ascii ":"
    ID_Inizio_testo_len:
        .long . -ID_Inizio_testo
    EDF_testo:
        .ascii "Pianificazione EDF:\n"
    EDF_testo_len:
        .long . -EDF_testo

    HPF_testo:
        .ascii "Pianificazione HPF:\n"
    HPF_testo_len:
        .long . -HPF_testo

    .macro duepunti
        movl $4, %eax # CARICO IN EAX IL CODICE DELLA SYSCALL WRITE
        movl  $1, %ebx # STDOUT
        leal ID_Inizio_testo, %ecx # INDIRIZZO DELLA RICHIESTA IN ECX
        movl ID_Inizio_testo_len, %edx # LUNGHEZZA DELLA STRINGA DA STAMPARE IN EDX
        int $0x80 # INTERRUPT
    .endm

    .macro vai_a_capo
    movl $4, %eax # CARICO IN EAX IL CODICE DELLA SYSCALL WRITE
        movl  $1, %ebx # STDOUT
        leal nuovalinea, %ecx # INDIRIZZO DELLA RICHIESTA IN ECX
        movl nuovalinea_len, %edx # LUNGHEZZA DELLA STRINGA DA STAMPARE IN EDX
        int $0x80 # INTERRUPT
    .endm



    .macro stampa_elem
        movl $4, %eax # CARICO IN EAX IL CODICE DELLA SYSCALL WRITE
        movl  $1, %ebx # STDOUT
        leal A, %ecx # INDIRIZZO DELLA RICHIESTA IN ECX
        movl $1, %edx # LUNGHEZZA DELLA STRINGA DA STAMPARE IN EDX
        int $0x80 # INTERRUPT
    .endm


    .section .text

    .global risultati # rende visibile il simbolo risultati al linker

    .type risultati, @function # dichiarazione della funzione

    risultati:
    movl %esp, %ebp # %ebp = cima della pila
    movl 4(%ebp), %esi # salto i primi 4 byte dove e' ind. di rientro e leggo indirizzo primo ID
    movl 8(%ebp), %ecx # numero di righe 
    movl 12(%ebp), %edx # indirizzo primo elemento di INIZIO
    movb 16(%ebp), %bl # HDF O EDF?

    leal A, %edi # INDIRIZZO STRINGA
    cmpb $49, %bl # SCELTA DI ALGORITMO 
    je stampo_EDF # EDF
    jmp stampo_HPF # HPF



    stampo_EDF:
        pushl %ecx  # SALVO IN STACK CONTATORE DEL LOOP
        pushl %edx # SALVO INDIRIZZO PRIMO ELEMENTO INIZIO


        movl $4, %eax # CARICO IN EAX IL CODICE DELLA SYSCALL WRITE
        movl $1, %ebx # STDOUT
        leal EDF_testo, %ecx # INDIRIZZO DELLA RICHIESTA IN ECX
        movl EDF_testo_len, %edx # LUNGHEZZA DELLA STRINGA DA STAMPARE IN EDX
        int $0x80 # INTERRUPT

        leal A, %edi # ASSEGNO A EDI INDIRIZZO DI MEMORIA STRINGA A (SERVE PER LA STAMPA DI OGNI CIFRA)

        popl %edx  # SALVO IN STACK IND PRIMo ELEMENTO
        popl %ecx # SALVO CONTATORE LOOP
        jmp stampo_ID
        

    stampo_ID:
        pushl %ecx  # SALVO IN STACK CONTATORE DEL LOOP
        pushl %edx # SALVO INDIRIZZO PRIMO ELEMENTO INIZIO
        xorl %eax, %eax
        movb (%esi),%al # CARICO ID IN EAX
        movl $10, %ebx

    inizioCiclo_ID:
        div %bl					# divido per 10 in byte, il risultato sara' in AL (quoziente) e AH (resto)
        cmpb $9, %al 
        jle non_salvo_il_resto_ID # SE HA DUE CIFRE, DEVO RIDIVIDERE.

    salva_il_resto_ID: 
        movb %ah, (salvo_resto) # SE IL NUMERO AD ES ERA 127, QUI VIENE SALVATO 7.
        xorb %ah, %ah
        jmp inizioCiclo_ID
    # A QUESTO PUNTO, PRIMA STAMPO AL, POI AH, POI, SE >0 IL RESTO.

    non_salvo_il_resto_ID:
    
        movb %ah, (salvo_seconda_cifra)

        cmpb $0,%al
        jg stampa_prima_cifra_ID
        jmp check_seconda_cifra_ID
    stampa_prima_cifra_ID:
        addb $48, %al
        movb %al, (%edi)
        stampa_elem

    check_seconda_cifra_ID:
        movb (salvo_seconda_cifra), %al
        cmpb $0,%al
        jge stampo_seconda_cifra_ID
        jmp check_resto

    stampo_seconda_cifra_ID:
        addb $48, %al
        movb %al, (%edi)
        stampa_elem

    check_resto:
        movb (salvo_resto), %al
        cmpb $0,%al
        jge stampo_resto_ID
        jmp fine_stampa_ID
    stampo_resto_ID:
        addb $48, %al
        movb %al, (%edi)
        stampa_elem 

    fine_stampa_ID:
    movb $-1, (salvo_resto)
    movb $-1, (salvo_seconda_cifra)
    incl %esi 


    stampo_duepunti:
    duepunti # CHIAMO LA MACRO CHE STAMPA I DUE PUNTI.

popl %edx


stampo_INIZIO:
        xorl %eax, %eax
        movb (%edx),%al # CARICO INIZIO IN EAX
        movl $10, %ebx
        div %bl					# divido per 10 in byte, il risultato sara' in AL (quoziente) e AH (resto)
        
    # A QUESTO PUNTO, PRIMA STAMPO AL, POI AH ( INIZIO HA PER FORZA 1 O 2 CIFRE)

print_INIZIO:
        pushl %edx
        movb %ah, (salvo_seconda_cifra)

        cmpb $0,%al
        jg stampo_prima_cifra_INIZIO
        jmp check_seconda_cifra_INIZIO
 stampo_prima_cifra_INIZIO:
        addb $48, %al
        movb %al, (%edi)
        stampa_elem
check_seconda_cifra_INIZIO:
        movb (salvo_seconda_cifra), %al
        cmpb $0,%al
        jge stampo_seconda_cifra_INIZIO
stampo_seconda_cifra_INIZIO:
        addb $48, %al
        movb %al, (%edi)
        stampa_elem

    fine_stampa_INIZIO:
    movb $-1, (salvo_resto)
    movb $-1, (salvo_seconda_cifra)
  

    vado_a_capo:
    vai_a_capo


recupero_registri:

    popl %edx
    popl %ecx # RECUPERO COUNTER LOOP

    incl %edx # VADO AL PROSSIMO INDIRIZZO DI INIZIO
    decl %ecx
    cmpl $0, %ecx 
    je fine_risultati
    jmp stampo_ID


stampo_HPF:
        pushl %ecx  # SALVO IN STACK CONTATORE DEL LOOP
        pushl %edx # SALVO INDIRIZZO PRIMO ELEMENTO INIZIO


        movl $4, %eax # CARICO IN EAX IL CODICE DELLA SYSCALL WRITE
        movl $1, %ebx # STDOUT
        leal HPF_testo, %ecx # INDIRIZZO DELLA RICHIESTA IN ECX
        movl HPF_testo_len, %edx # LUNGHEZZA DELLA STRINGA DA STAMPARE IN EDX
        int $0x80 # INTERRUPT

        leal A, %edi # ASSEGNO A EDI INDIRIZZO DI MEMORIA STRINGA A (SERVE PER LA STAMPA DI OGNI CIFRA)

        popl %edx  # SALVO IN STACK CONTATORE DEL LOOP
        popl %ecx # SALVO INDIRIZZO PRIMO ELEMENTO INIZIO
        jmp stampo_ID

    fine_risultati:
    ret


