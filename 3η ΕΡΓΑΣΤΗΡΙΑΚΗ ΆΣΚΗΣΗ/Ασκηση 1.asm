

org 100h

jmp main

PRINT_DEC:    ;RPUTINA POU METATREPEI ENAN DEKAE9ADIKO ARITHMO SE DEKADIKO
    push ax
    push bx
    push cx
    push dx
    
    sub bh,bh
    mov ax,bx
    mov dl,10
    div dl
    mov dh,ah
    sub ah,ah
    
    div dl          ; al->hundreds
                    ; ah->tens
                    ; dh->units
    push ax
    mov ah,02h
    
    mov dl,al
    add dl,30h
    mov ah,02h
    int 21h
    
    pop ax
    mov dl,ah
    mov ah,02h
    
    add dl,30h
    int 21h
    xchg dh,dl
    add dl,30h
    int 21h
        
    pop dx
    pop cx
    pop bx
    pop ax
    ret
END_PRINT_DEC: 

read macro            ;ROUTINA GIA DIABASMA XARAKTHRON
    mov ah,08h
    int 21h
endm
                      ;ROYTINA GIA EMFANISH XARAKTHRON
print macro char
    mov dl,char
    mov ah,2
    int 21h
endm    
                      ;ROUTINA GIA EKSODO
exit macro                
    mov ax,4C00h
    int 21h
endm  


print_str macro string  ;RPUTINA GIA EKTYPOSH SYMBOLOSEIRAS    
    push ax
    push dx
    mov dx,offset string
    mov ah,9
    int 21h
    pop dx
    pop ax
endm

HEX_KEYB PROC NEAR       ;ROYTINA POU DIABAZEI APO TO PLHKTROLOGIO
    push dx              ;KAI PAIRNAEI STON AL THN TIMH TOU AN EINAI DEKAEKSADIKOS
ignore:                  ;ARITHMOS, ALLIOS TON AGNOEI KAI SUNEXISEI NA DIABAZEI
    read    
    cmp al,30h
    jl addr1
    cmp al,39h
    jg addr1
    push ax
    print al
    pop ax

    sub al,30h        ;METATROPH SE DIADIKO
    jmp addr2
addr1: 
    cmp al,'A'
    jl ignore
    sunexise:
    cmp al,'F'
    jg ignore
    push ax
    print al
    pop ax
    sub al,37h        ;METATROPH SE DIADIKO
addr2:
    pop dx
    ret
HEX_KEYB ENDP


main:
print_str MESS1
mov bh,01h        ; O BL EINAI 01H. AN STO TELOS EXEI THN TIMH 01H TOTE DOTHIKE TO ONOMA THS OMADAS(A16) KAI TELEIVNEI THN EKTELESH
call HEX_KEYB
mov dh,al
add dh,37h
cmp dh,41h
je x1
mov bh,00h
x1:
sub dh,37h
sub al,al
call HEX_KEYB
mov dl,al
add dl,30h
cmp dl,31h
je x2
mov bh,00h
x2:
sub dl,30h

mov cl,4        ;SXHMATISMOS TOY 2-PSIFIOU ARITHMOY
shl dl,cl
shr dx,cl

mov bl,dl
print_str telia
call HEX_KEYB
mov dl,al
add dl,30h
cmp dl,36h
je x3:
mov bh,00h
x3:       
sub dl,30h
cmp bh,01h    ;AN EMEINE 01H TOTE DOTHIKE TO ONOMA THS OMADAS MAS
je end
push dx
print_str newline
print_str MESS2
call PRINT_DEC
print_str telia
pop dx          ;GIA TO DEKADIKO MEROS
mov al,dl     ;ston al o x  (__.x)
sub ah,ah     
mov cl,0ah    ; thelo *10d
mul cl
mov ch,16d
div ch 
push ax
    mov dl,al
    add dl,30h
    mov ah,02h
    int 21h
pop ax
mov al,ah
sub ah,ah
mul cl

sub ah,ah
div ch 
push ax
    mov dl,al
    add dl,30h
    mov ah,02h
    int 21h
pop ax
mov al,ah
sub ah,ah
mul cl
div ch
push ax
    mov dl,al
    add dl,30h
    mov ah,02h
    int 21h
pop ax
mov al,ah
sub ah,ah
mul cl
div ch
push ax
    mov dl,al
    add dl,30h
    mov ah,02h
    int 21h
pop ax
jmp main




end:
exit


end_program:
    pop dx
    pop ax
    mov ax,4C00h
    int 21h


     ; DATA SPACE


MESS1 DB 0AH,0DH,'GIVE 3 HEX DIGITS:$'
MESS2 DB 0AH,0DH,'DECIMAL:$'
telia: db '.$'
newline: db 0AH,0Dh,'$'
