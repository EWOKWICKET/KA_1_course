.model small
.stack 100h

.data
buffer dw 255 dup(?)
numbers dw 100 dup(?)
numbersAmount dw ?
oneChar db ?              

.code
;description
main PROC
    mov ax, @data
    mov ds, ax

    read_loop:
        lea si, buffer
        call read_next          

        lea di, buffer         
        call get_numbers    
        jmp read_loop          
    end_read_loop:

read_next:
        mov ah, 3Fh            
        mov bx, 0h             
        mov cx, 1             
        lea dx, oneChar       
        int 21h               

        
        or ax, ax             
        jnz get_numbers       
        jmp end_read_loop      
        ret

get_numbers:
    mov cx, 0             
    lea bx, buffer        

    get_loop:
        mov al, [di]            
        cmp al, 0              
        je end_get_loop    

        call parse_decimal     
        mov [numbers+si], ax    
        add si, 2              
        inc cx                 
        inc di                 
        jmp get_loop        

end_get_loop:
    mov numbersAmount, cx      
    ret

parse_decimal:
    mov ax, 0              
    mov cx, 10            

    parse_loop:
        mov dl, [di]           
        cmp dl, 0              
        je end_parse_loop       

        sub dl, '0'             
        mul cx                  
        add ax, dx              
        inc di                 
        jmp parse_loop         

end_parse_loop:
    ret

main ENDP
end main