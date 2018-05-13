
org 100h 
jmp main
DEC_KEYB PROC NEAR:  ;ROYTINA POU DIABAZEI APO TO PLHKTROLOGIO
PUSH DX              ;KAI PAIRNAEI STON AL THN TIMH TOU AN EINAI DEKADIKOS
IGNORE:              ;ARITHMOS, ALLIOS TON AGNOEI KAI SUNEXISEI NA DIABAZEI
READ
cmp al,'Q'
je end_program
cmp al,0Dh           ;ELEGXOS ME ENTER
je next
cmp al,30h
jl ignore
cmp al,39h
jg ignore
inc bl
push ax
print al
pop ax
sub al,30h           ;METATROPH SE DIADIKO
addr2:
pop dx
ret
DEC_KEYB ENDP

read macro
    mov ah,08h
    int 21h
endm

print macro char
    mov dl,char
    mov ah,2
    int 21h
endm    

exit macro                
    mov ax,4C00h
    int 21h
endm  


print_str macro string     
    push ax
    push dx
    mov dx,offset string
    mov ah,9
    int 21h
    pop dx
    pop ax
endm

PRINT_OCT:         ;ROUTINA POU METATREPEI TON DEKADIKO SE OKTADIKO
    push ax
    push bx
    push cx
    push dx
    
    sub bh,bh
    mov ah,02h
    
    mov cl,2
    shl bx,cl
    
    mov dl,bh
    add dl,30h
    int 21h
    
    sub bh,bh
    mov cl,3
    shl bx,cl
    
    mov dl,bh
    add dl,30h
    int 21h
    
    sub bh,bh
    mov cl,3
    shl bx,cl
    
    mov dl,bh
    add dl,30h
    int 21h
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret    
END_PRINT_OCT:

main:
sub bl,bl            ;METRHTHS POU DEIXNEI POSOI ARITHMOI EXOUN DOTHEI
print_str MESS1
start:

call DEC_KEYB
mov dh,al
sub al,al
call DEC_KEYB
mov dl,al
jmp start
next:
cmp bl,02h             ;DOTHIKAN DUO ARITHMOI ?
jl start
mov cl,2h              ;EINAI PERITTO TO PLHTHOS TON DOTHEDON ARITHMON ?
sub ah,ah
mov al,bl
div cl
cmp ah,00h             ;AN NAI TOTE ALLAKSE TO PERIEXOMENO TON DL,DH
je move
mov ah,dl
mov dl,dh
mov dh,ah

move:                 ;SXHMATISMOS TOU DIPSIFIOY ARITHMOY
mov cl,0Ah
mov al,dh
mul cl
mov dh,al
add dh,dl
sub dl,dl 
mov bl,dh

print_str newline
print_str MESS2
call PRINT_OCT
print_str newline
jmp main
 

  

end:
exit


end_program:
    pop dx
    pop ax
    mov ax,4C00h
    int 21h


     ; DATA SPACE


MESS1 DB 'GIVE 2 DECIMAL DIGITS:$'
MESS2 DB 'OCTAL=$'
newline: db 0AH,0Dh,'$'