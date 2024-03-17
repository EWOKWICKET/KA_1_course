.model small
.stack 100h

.data
buffer dw 255 dup(?)
numbers dw 15 dup('a')
numbersAmount dw 0        
error_string db "Only digits allowed", 0
filename db "test.in", 0
string db "TESTING", 0

.code
;main procedure
main PROC
    mov ax, @data
    mov ds, ax

    call read_loop
    call print_array

    jmp end_program

main ENDP

read_loop PROC
    mov ax, 0
    mov dx, 0
    lea si, numbers     
    mov ah, 3Fh       
    lea dx, filename             
    int 21h              
    lea di, buffer    
    jmp read_next

    read_next:
        mov ax, 0
        mov al, [di]            
        cmp al, 0
        jz end_read_loop  

        call get_numbers       
        jmp read_next

    end_read_loop:
        mov ax, 0
        mov ah, 3Eh
        int 21h
        ret
read_loop ENDP

get_numbers PROC       
    mov dx, 0
    get_loop:
        mov dl, [di]            
        inc di

        cmp dl, 0Dh                 ; CR?
        jz end_get_loop                      
        cmp dl, 0Ah                 ; LF?
        je end_get_loop           
        cmp dl, 0                   ; EOF?
        jz end_all_loops    
        cmp dl, ' '
        jz get_loop
        call addToNumbers                       
        jmp get_loop      

    end_get_loop:
        ret

    end_all_loops:
        dec di
        ret
get_numbers ENDP

addToNumbers PROC
    mov ax, 0              
    mov cx, 0   

    get_digit_loop:
        mov dl, [di]    
        inc di   

        cmp dl, 0Dh                                      ; CR?
        jz next_digit_loop_check_for_end_of_lines                      
        cmp dl, 0Ah                                      ; LF?
        je next_digit_loop_check_for_end_of_lines           
        cmp dl, 0                                        ; EOF?
        jz next_digit_loop_check_for_end_of_lines    
        cmp dl, ' '                                      ; Перевіряємо, чи символ - пробіл
        je next_digit_loop_check_for_space               ; Якщо так, пропустити пробіл і перейти до наступного символу
        cmp dl, '0'                                      ; Перевіряємо, чи символ є цифрою
        jb not_digit                                     
        cmp dl, '9'                                      ; Перевіряємо, чи символ є цифрою
        ja not_digit
        jmp add_to_digits

    add_to_digits:
        mov al, dl
        cbw
        mov dx, ax
        mov ax, 0

        push dx                ; Якщо це цифра, додати її до стеку
        inc cx
        jmp get_digit_loop     

    not_digit:
        ; Виводимо повідомлення про помилку
        mov ax, 0
        mov ah, 09h            ; вивід рядка   
        lea dx, error_string   
        int 21h                
        ; Завершуємо програму       
        mov ah, 3Eh
        int 21h
        mov ah, 4Ch            ; завершення програми
        int 21h                

    next_digit_loop_check_for_end_of_lines: 
        cmp cx, 0
        je end_addition_loop
        call convert
        jmp end_addition_loop

    next_digit_loop_check_for_space: 
        cmp cx, 0
        je get_digit_loop
        call convert
        jmp get_digit_loop

    end_addition_loop:
        dec di
        ret
addToNumbers ENDP

convert PROC
        mov ax, 0             ; Очищення регістру AX (для зберігання результату)

    convert_loop:
        cmp cx, 0               ; Перевірка, чи є ще цифри у стеці
        je end_convert          

        pop dx                  ; Витягнення цифри зі стека у регістр DX
        sub dx, '0'             ; Конвертація у числове значення
        push ax
        push cx

        call convert_to_binary
        pop cx
        pop ax
        
        add ax, dx

        dec cx                  ; Збільшення лічильника цифр у стеці
        jmp convert_loop        

    end_convert:
        mov [numbers + si], ax
        add si, 2
        inc numbersAmount
        ret
convert ENDP

convert_to_binary PROC
    mov ax, dx
    mov bx, 2       ; Початкове число для поділу (двійкова система)
    mov cx, 0      
    jmp convert_loop_to_binary      
    
    convert_loop_to_binary:
        mov dx, 0            
        div bx               ; Ділимо AX на CX, результат зберігається у AX, а залишок у DX
        push dx              ; Зберегти залишок (0 або 1) у стек
        inc cx

        cmp ax, 0                       ; Перевірка, чи AX = 0 (все число поділене)
        jz go_to_gathering              
        jmp convert_loop_to_binary      

    end_convert_loop:
        mov dx, ax
        ret

    go_to_gathering:
        mov bx, 1            ; Початкова степінь двійки (1, 2, 4, 8, ...)
        jmp gather_remainders
        
    gather_remainders:
        cmp cx, 0             ; Перевірка, чи всі залишки зібрано
        jz end_convert_loop         

        pop dx                ; Вибірка залишку зі стека у регістр DX
        push ax
        mov ax, dx
        mul bx               ;множу на поточну степінь двійки
        mov dx, ax
        pop ax
        add ax, dx            ; Додавання поточного результату до нового залишку

        shl bx, 1             ; Подвоєння степеня двійки
        dec cx                ; Зменшення лічильника залишків
        jmp gather_remainders       
        
convert_to_binary ENDP

print_array PROC
    lea si, numbers
    mov ah, 09h            ;    вивід рядка

    display_loop: 
        mov dx, [numbers + si]         
        cmp dx, 'a'
        je finish_display

        call print_number     
        add si, 2     
        jmp display_loop
        
    finish_display:
        mov ax, 0
        ret
print_array ENDP

print_number PROC
    mov dl, '2'
    mov ax, 0
    mov ah, 02h
    int 21h
    ret
print_number ENDP

;description
end_program PROC
    mov ax, 0
    mov bx, 0
    mov cx, 0
    mov dx, 0
    mov ah, 4Ch            ; завершення програми
    int 21h 
end_program ENDP

end main