     .section .data # IN QUESTA SEZIONE EFFETTUO LA DICHIARAZIONE DELLE VARIABILI.

        
    filename:
        .ascii ""    # NOME DEL FILE DI TESTO DA LEGGERE
    fd:
        .int 0             # FILE DESCRIPTOR


        ID: .byte 0,0,0,0,0,0,0,0,0,0
        Durata: .byte 0,0,0,0,0,0,0,0,0,0
        Deadline: .byte 0,0,0,0,0,0,0,0,0,0
        Priority: .byte 0,0,0,0,0,0,0,0,0,0
        Fine: .byte 0,0,0,0,0,0,0,0,0,0
        Inizio: .byte 0,0,0,0,0,0,0,0,0,0

        buffer:		# variabile STRINGA per ogni numero
        .string ""

        num_str:
        .ascii "000"
        num_str_len:
        .long -num_str

    Conclusione_testo:
        .ascii "Conclusione: "
    Conclusione_testo_len:
        .long . -Conclusione_testo

    ERRORE_TESTO:
       .ascii "\nERRORE DI INPUT O DI APERTURA DEL FILE.\n"
    ERRORE_TESTO_LEN:
    .long . -ERRORE_TESTO
        
        conclusione: .long 0
        penalty: .long 0
        lines: .long 0
        salva_num: .byte 0 
    
        newline: .byte 10       # Valore del simbolo di nuova linea (ascii) 
        virgola: .byte 44       # VALORE ASCII DELLA VIRGOLA   
        i: .long 0
        j:  .long 0

        richiesta:  # TESTO CHE CHIEDE ALL'UTENTE CHE ALGORITMO DI PIANIFICAZIONE VUOLE USARE
            .ascii "\nCHE ALGORITMO VUOI UTILIZZARE? 1-EDF 2-HPF 3-END "

        richiesta_len: # LUNGHEZZA DELLA STRINGA DELLA RICHIESTA
            .long . -richiesta



      

        .section .text 

        .globl _start

        #----------------------------------
        # APRO IL FILE
        #----------------------------------

# PUNTO ALL'INDIRIZZO DEL NOME DEL FILE E LO METTO IN EBX 

    
        _open:

            mov $5, %eax # SYSCALL OPEN 
            movl 8(%esp), %ebx # METTO L'INDIRIZZO DEL NOME DEL FILE LETTO DA RIGA DI COMANDO IN EBX.
            mov $0, %ecx # APRO IN READ ONLY
            int $0x80 # ESEGUO L'INTERRUPT.

        # COME IN C, SE C'E' UN ERRORE, ESCO DAL PROGRAMMA

        cmp $0,%eax # CONFRONTO EAX CON 0
        jl Errore  # SE SI VERIFICA UN ERRORE, EAX SARA' MINORE DI 0, E QUINDI VADO ALL' ERRORE.

        movl %eax, fd # ALTRIMENTI, SALVO EAX NEL FD

        #--------------------------------------------------
        # LEGGO OGNI NUMERO DA FILE
        #--------------------------------------------------

    leggi_numero:
        mov $3, %eax        # syscall read
        mov fd, %ebx        # File descriptor
        leal buffer, %ecx
        movl $1, %edx
        int $0x80           # Interruzione del kernel

        cmp $0, %eax        # Controllo se ci sono errori o EOF
        je richiesta_algoritmo    # Se EOF, vado a richiesta algoritmo
        jl Errore
        
    compara_numero: 
        
        movb buffer, %al   
        cmpb (newline), %al  
        je fine_atoi
        cmpb (virgola), %al 
        jne atoi_num 
        je fine_atoi
        
        

    #--------------------------------------------------
    # CONVERTO IL NUMERO A INTERO
    #--------------------------------------------------

    atoi_num:

        leal buffer,%esi # METTO INDIRIZZO STRINGA IN ESI (REG CHE LAVORA CON STRINGHE E ARRAY)
        xorl %eax,%eax			# Azzero registri General Purpose
        xorl %ebx,%ebx           
        xorl %ecx,%ecx           
        xorl %edx,%edx
        jmp converti_a_intero

    converti_a_intero:
        movb (salva_num), %al
        movb (%ecx,%esi,1), %bl             
        subb $48, %bl            # converte il codice ASCII della cifra nel numero corrisp.
        movb $10, %dl
        mulb %dl                # EAX = EAX * 10
        addb %bl, %al        
        movb %al, (salva_num)
        jmp leggi_numero


    #--------------------------------------------------
    # SALVO IL NUMERO NELL'ARRAY
    #--------------------------------------------------

    fine_atoi:
        movb (salva_num), %al
        cmpl $0, (i)
        je array_ID
        cmpl $1, (i)
        je array_durata
        cmpl $2, (i)
        je array_deadline
        cmpl $3, (i)
        je array_priority


    array_ID:
	pushl %eax
	movl (lines),%eax
	cmpl $10,%eax
	jg Errore
	popl %eax
    incl (lines)
    leal ID, %esi
    addl (j), %esi
    cmpb $1, %al
    jl Errore
    cmpb $127, %al
    jg Errore
    movb %al, (%esi) # METTO IL NUMERO NELL'INDIRIZZO DEL VETTORE INDICATO DA ESI 
    movb $0, (salva_num) # RIPRISTINO LA VARIABILE CHE SALVA IL NUMERO 
    incl (i) # INCREMENTO L'INDICE CHE MI DICE DOVE SALVARE IL NUMERO
    jmp leggi_numero

    array_durata:
    leal Durata, %esi
    addl (j), %esi
    cmpb $1, %al
    jl Errore
    cmpb $10, %al
    jg Errore
    movb %al, (%esi) # METTO IL NUMERO NELL'INDIRIZZO DEL VETTORE INDICATO DA ESI 
    movb $0, (salva_num) # RIPRISTINO LA VARIABILE CHE SALVA IL NUMERO 
    incl (i) # INCREMENTO L'INDICE CHE MI DICE DOVE SALVARE IL NUMERO
    jmp leggi_numero

    array_deadline:
    leal Deadline, %esi
    addl (j), %esi
    cmpb $1, %al
    jl Errore
    cmpb $100, %al
    jg Errore
    movb %al, (%esi) # METTO IL NUMERO NELL'INDIRIZZO DEL VETTORE INDICATO DA ESI 
    movb $0, (salva_num) # RIPRISTINO LA VARIABILE CHE SALVA IL NUMERO 
    incl (i) # INCREMENTO L'INDICE CHE MI DICE DOVE SALVARE IL NUMERO
    jmp leggi_numero

    array_priority:
    leal Priority, %esi
    addl (j), %esi
    cmpb $1, %al
    jl Errore
    cmpb $5, %al
    jg Errore
    movb %al, (%esi) # METTO IL NUMERO NELL'INDIRIZZO DEL VETTORE INDICATO DA ESI 
    movb $0, (salva_num) # RIPRISTINO LA VARIABILE CHE SALVA IL NUMERO 
    movl $0, (i) # METTO A 0 L'INDICE CHE MI DICE DOVE SALVARE IL NUMERO (IL PROSSIMO NUMERO ANDRA' SALVATO IN ID)
    incl (j) # ELEMENTO CHE SI COMPORTA COME "INDICE" DEGLI ARRAY
    jmp leggi_numero



    #--------------------------------------------------
    # CHIEDO ALL'UTENTE CHE ALGORITMO VUOLE UTILIZZARE
    #--------------------------------------------------
    richiesta_algoritmo:
    
        movl $4, %eax # CARICO IN EAX IL CODICE DELLA SYSCALL WRITE
        movl  $1, %ebx # STDOUT
        leal richiesta, %ecx # INDIRIZZO DELLA RICHIESTA IN ECX
        movl richiesta_len, %edx # LUNGHEZZA DELLA STRINGA DA STAMPARE IN EDX
        int $0x80 # INTERRUPT 

    inserimento_scelta:

        movl $3, %eax # SYSCALL READ
        movl $1, %ebx # STDIN
        leal buffer, %ecx # INDIRIZZO DELLA STRINGA IN ECX
        movl $1, %edx
        incl %edx
        int $0x80

    scelta:
        movb buffer, %al
        cmpl $49, %eax # SE 1, EDF
        je preparo_EDF
        cmpl $50, %eax # SE 2, HPF
        je preparo_HPF
        cmpl $51, %eax # SE 3, PRIMA CHIUDO CORRETTAMENTE IL FILE, E POI ESCO.
        je close_file
        jmp richiesta_algoritmo # SE NESSUNO DEI 3, RICHIEDO


    #-------------------------------
    # EDF 
    #-------------------------------

preparo_EDF:
    leal Deadline, %esi # IMPOSTO INDIRIZZO DEL PRIMO EL DEL VETTORE DEADLINE IN ESI
    decl (lines)
    xorl %eax,%eax			# Azzero registri General Purpose
    xorl %ebx,%ebx           
    xorl %ecx,%ecx        
    xorl %edx,%edx 
    movl $0, (j)

                                
for1_EDF:
        movl $0, (j)
        movl (lines), %ecx
        cmpl (i),%ecx
        je fine_EDF
      
for2_EDF:

    movl (lines), %ecx

    movl (j), %edx

    subl (i),%ecx

    cmpl %edx, %ecx

    je fine_for2_EDF
    
    movb 1(%esi),%bl
    cmpb %bl, (%esi)
    jg salvo_eax_esi_EDF
    je equal_deadline
    incl %esi
    incl (j)
    jmp for2_EDF


fine_for2_EDF:
    incl (i)
    leal Deadline, %esi # IMPOSTO INDIRIZZO DEL PRIMO EL DEL VETTORE DEADLINE IN ESI
    jmp for1_EDF
     

salvo_eax_esi_EDF:
pushl %ecx # SALVO IL TOTALE DEI NUMERI NELLO STACK
pushl %esi # SALVO ESI NELLO STACK.

scambio_ID_EDF:
leal ID, %esi
addl (j), %esi
movb 1(%esi),%bl
movb (%esi), %dl
movb %dl, 1(%esi)
movb %bl, (%esi)

scambio_Durata_EDF:
leal Durata, %esi
addl (j), %esi
movb 1(%esi),%bl
movb (%esi), %dl
movb %dl, 1(%esi)
movb %bl, (%esi)

scambio_Deadline_EDF:
leal Deadline, %esi
addl (j), %esi
movb 1(%esi),%bl
movb (%esi), %dl
movb %dl, 1(%esi)
movb %bl, (%esi)

scambio_Priority_EDF:
leal Priority, %esi
addl (j), %esi
movb 1(%esi),%bl
movb (%esi), %dl
movb %dl, 1(%esi)
movb %bl, (%esi)

fine_scambio_EDF:
popl %esi
popl %ecx
incl (j) # AUMENTO INDICE 
incl %esi # VADO ALLA DEADLINE SUCCESSIVA
jmp for2_EDF

equal_deadline:
pushl %ecx
pushl %esi
leal Priority, %esi
addl (j), %esi # VADO ALL'ELEMENTO DA COMPARARE
movb 1(%esi),%bl
cmpb %bl, (%esi)
jl scambio_ID_EDF
popl %esi
popl %ecx
incl (j) 
incl %esi
jmp for2_EDF

fine_EDF:
movl $0,(i) # AZZERO INDICE I
movl $1,(j) # AZZERO INDICE J
incl (lines) # RIPRISTINO IL TOTALE DELLE RIGHE 
xorl %eax, %eax
jmp preparo_calcolo_fine




        #--------------------------------
        # HPF
        #--------------------------------

preparo_HPF:
leal Priority, %esi # IMPOSTO INDIRIZZO DEL PRIMO EL DEL VETTORE DEADLINE IN ESI
decl (lines)

xorl %eax,%eax			# Azzero registri General Purpose
xorl %ebx,%ebx           
xorl %ecx,%ecx        
xorl %edx,%edx 
movl $0, (j)

                                
for1_HPF:
        movl $0, (j)
        movl (lines), %ecx
        cmpl (i),%ecx
        je fine_HPF
      
for2_HPF:

    movl (lines), %ecx

    movl (j), %edx

    subl (i),%ecx

    cmpl %edx, %ecx

    je fine_for2_HPF
    
    movb 1(%esi),%bl
    cmpb %bl, (%esi)
    jl salvo_eax_ebx_HPF
    je equal_priority
    incl %esi
    incl (j)
    jmp for2_HPF


fine_for2_HPF:
    incl (i)
    leal Priority, %esi # IMPOSTO INDIRIZZO DEL PRIMO EL DEL VETTORE DEADLINE IN ESI
    jmp for1_HPF
     

salvo_eax_ebx_HPF:
pushl %ecx # SALVO IL TOTALE DEI NUMERI NELLO STACK
pushl %esi # SALVO ESI NELLO STACK.

scambio_ID_HPF:
leal ID, %esi
addl (j), %esi
movb 1(%esi),%bl
movb (%esi), %dl
movb %dl, 1(%esi)
movb %bl, (%esi)

scambio_Durata_HPF:
leal Durata, %esi
addl (j), %esi
movb 1(%esi),%bl
movb (%esi), %dl
movb %dl, 1(%esi)
movb %bl, (%esi)

scambio_Deadline_HPF:
leal Deadline, %esi
addl (j), %esi
movb 1(%esi),%bl
movb (%esi), %dl
movb %dl, 1(%esi)
movb %bl, (%esi)

scambio_Priority_HPF:
leal Priority, %esi
addl (j), %esi
movb 1(%esi),%bl
movb (%esi), %dl
movb %dl, 1(%esi)
movb %bl, (%esi)

fine_scambio_HPF:
popl %esi
popl %ecx
incl (j) # AUMENTO INDICE 
incl %esi # VADO ALLA DEADLINE SUCCESSIVA
jmp for2_HPF

equal_priority:
pushl %ecx
pushl %esi
leal Deadline, %esi
addl (j), %esi # VADO ALL'ELEMENTO DA COMPARARE
movb 1(%esi),%bl
cmpb %bl, (%esi)
jg scambio_ID_HPF
popl %esi
popl %ecx
incl (j) 
incl %esi
jmp for2_HPF

fine_HPF:
movl $0,(i) # AZZERO INDICE I
movl $1,(j) # AZZERO INDICE J
incl (lines) # RIPRISTINO IL TOTALE DELLE RIGHE 
xorl %eax, %eax # AZZERO EAX
jmp preparo_calcolo_fine

#-------------------------------------------
# CALCOLO FINE
#-------------------------------------------


preparo_calcolo_fine:
xorl %eax,%eax
movl (i), %edi
movl (i), %esi # INDICE DA CUI DOVRO' PARTIRE AD EFFETTUARE LA SOMMA
movl (j), %ecx # IMPOSTO NUMERO DI LOOP  IN ECX 

somma_fine:   
                    
  addb Durata(%esi), %al
  decl %esi
  loop somma_fine   # ecx viene decrementato e salta a fattoriale

fine_calcolo_fine:
movb %al, Fine(%edi)
incl (j)
incl (i)
movl (i),%eax
cmpl (lines), %eax
je preparo_calcolo_inizio
jmp preparo_calcolo_fine


#-------------------------------------------
# CALCOLO INIZIO
#-------------------------------------------


preparo_calcolo_inizio:

movl $0, (i) # PRIMO INDICE DELL'ARRAY DI FINE
movl $1, (j) # SECONDO INDICE DELL'ARRAY DI INIZIO
decl (lines) # EFFETTUO IL CICLO LINES-1 VOLTE (SE DUE RIGHE, SOLO INDICE 1, PERCHE' IL PRIMO ELEMENTO INIZIA A T=0 ) !!!!!!!

fine_diventa_inizio:
movl (lines),%eax
movl (lines), %ecx # NUMERO CICLI (LINES-1)
cmpl $0, %ecx
je preparo_calcolo_penalty
fine_to_inizio:
movl (i),%esi # INDICE FINE
movl (j),%edi # INDICE INIZIO
movb Fine(%esi), %al
movb %al, Inizio(%edi)
incl i 
incl j 
loop fine_to_inizio

#-------------------------------------------
# CALCOLO PENALTY ---> (FINE-DEADLINE)*PRIORITA'
#-------------------------------------------

preparo_calcolo_penalty:
movl $0, %esi
incl (lines) # RIPRISTINO NUMERO DI RIGHE

fine_meno_deadline:
xorl %eax,%eax # AZZERO EAX
movb Fine(%esi), %al
subb Deadline(%esi),%al
cmpb $0,%al
jg calcolo_penalty
cmpl (lines), %esi
je stampo_risultati
incl %esi
jmp fine_meno_deadline

calcolo_penalty:
movl $0, (salva_num)
movb Priority(%esi), %dl
mulb %dl 
movb %al, (salva_num)
movl (salva_num), %eax
addl (penalty), %eax
movl %eax, (penalty)
cmpl (lines), %esi
je stampo_risultati
incl %esi
jmp fine_meno_deadline



Errore:
  movl $4, %eax # CARICO IN EAX IL CODICE DELLA SYSCALL WRITE
        movl  $2, %ebx # STDERROR
        leal ERRORE_TESTO, %ecx # INDIRIZZO DELLA RICHIESTA IN ECX
        movl ERRORE_TESTO_LEN, %edx # LUNGHEZZA DELLA STRINGA DA STAMPARE IN EDX
        int $0x80 # INTERRUPT
        jmp close_file






# Chiude il file
close_file:
    mov $6, %eax        # syscall close
    mov %ebx, %ecx      # File descriptor
    int $0x80           # Interruzione del kernel

    jmp _end



_start:
    jmp _open

#--------------------
# STAMPO I RISULTATI
#--------------------

stampo_risultati:

pushl (buffer)  # SCELTA TRA EDF E HPF
pushl $Inizio # INDIRIZZO PRIMO ELEMENTO INIZIO
pushl (lines) # NUMERO DI ELEMENTI IN CIASCUN VETTORE.
pushl $ID # INDIRIZZO PRIMO ELEMENTO ID

call risultati

popl %eax 
popl (lines)
popl %eax
popl %eax


xorl %eax, %eax
leal Fine, %esi
addl (lines), %esi
decl %esi 
movb (%esi), %al
movb %al, (conclusione)


# STAMPO CONCLUSIONE
        movl $4, %eax # CARICO IN EAX IL CODICE DELLA SYSCALL WRITE
        movl $1, %ebx # STDOUT
        leal Conclusione_testo, %ecx # INDIRIZZO DELLA RICHIESTA IN ECX
        movl Conclusione_testo_len, %edx # LUNGHEZZA DELLA STRINGA DA STAMPARE IN EDX
        int $0x80 # INTERRUPT


pushl (penalty)
pushl (conclusione)
call Penalty

popl %eax
popl %eax


xorl %eax, %eax
xorl %ebx, %ebx
xorl %ecx, %ecx
xorl %edx, %edx
xorl %esi, %esi
xorl %edi, %edi

movl $0, (i)
movl $0, (penalty)
jmp richiesta_algoritmo


    jmp _end

_end:
    movl $1, %eax # CARICO IN EAX IL CODICE DELLA SYSCALL EXIT.
    xorl %ebx, %ebx # AZZERO EBX. CONTIENE IL CODICE DI RITORNO DELLA SYSCALL.
    int $0x80 # ESEGUO LA SYSCALL TRAMITE L'INTERRUPT 0x80

