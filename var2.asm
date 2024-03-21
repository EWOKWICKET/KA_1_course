.model small
.stack 100

.data
numbers dw 10000 dup(?)
; numbersAmount dw 0        
digitsRead dw 0
numsRead dw 0
numsConvertedToDecimal dw 0
numsConvertedToBinary dw 0
decimalHolder dw 0
binaryHolder dw 0B
stackOffset dw 0
char db  0
returnIndex dw 0
; error_string db "Only digits allowed", '$'

.code
main PROC
    mov ax, @data
    mov ds, ax

    mov ax, 0
    mov bx, 0
    mov cx, 0
    mov dx, 0

    call read_loop
    call convert_to_decimal
    call convert_to_binary
    ; call print_array
    
    jmp end_program

main ENDP


;reads and prints file, preparing for converting(digits of num and amount of digits are in stack)
read_loop PROC
    pop returnIndex
    read_file:
        mov ah, 3Fh
        mov bx, 0h                         ; stdin handle
        mov cx, 1                          ; 1 byte to read
        lea dx, char                       ; read to ds:dx
        int 21h                        
        cmp ax, 0                          ; EOF?
        jz end_of_file

        mov dx, 0

        mov ah, 02h
        mov dl, char
        int 21h

        cmp dl, 13                                      ; LF?
        je read_not_digit
        cmp dl, 10                                      ; CR?
        je read_not_digit
        cmp dl, ' '
        je read_not_digit
        cmp dl, 0
        je end_of_file
        inc digitsRead
        sub dl, '0'
        push dx
        jmp read_file

    read_not_digit:
        cmp digitsRead, 0
        jne end_of_num
        jmp read_file
        
    end_of_file:
        cmp digitsRead, 0
        jne last_num
        push returnIndex
        ret

    end_of_num:
        push digitsRead
        mov digitsRead, 0
        inc numsRead
        jmp read_file


    last_num:
        push digitsRead
        mov digitsRead, 0
        inc numsRead
        push returnIndex
        ret
read_loop ENDP

;converts each num in stack into decimal and pushes them to stack
convert_to_decimal PROC
    pop returnIndex
    mov stackOffset, 0
    get_decimal_loop:
        cmp numsRead, 0
        je end_get_decimal_loop

        add sp, stackOffset
        pop cx
        mov bx, 1
        convert_char_loop:
            cmp cx, 0
            je end_convert_char_loop
            pop dx
            convert_char:
                mov ax, dx
                mul bx
                add decimalHolder, ax
                mov ax, bx
                mov bx, 10
                mul bx
                mov bx, ax
                dec cx
                jmp convert_char_loop


        end_convert_char_loop:
            push decimalHolder
            mov decimalHolder, 0
            sub sp, stackOffset
            add stackOffset, 2
            inc numsConvertedToDecimal
            dec numsRead 
            jmp get_decimal_loop

    end_get_decimal_loop:
        push returnIndex
        ret    
convert_to_decimal ENDP

;converts each decimal in stack into binary and pushes them to stack
convert_to_binary PROC
    pop returnIndex
    mov stackOffset, 0
    mov digitsRead, 0
    mov bx, 2
    get_binary_loop:
        cmp numsConvertedToDecimal, 0
        je end_get_decimal_loop
        add sp, stackOffset
        pop dx
        convert_digit_loop:
            mov ax, dx
            mov dx, 0
            mov ah, 0

            div bl
            mov dl, ah
            mov ah, 0
            push dx
            inc digitsRead

            cmp ax, 0
            je convert_digit
            jmp convert_digit_loop

            convert_digit:
                cmp digitsRead, 0
                je end_convert_digit_loop
                pop dx
                mov ah, 02h
                add dl, '0'
                int 21h
                sub dl, '0'
                dec digitsRead
                jmp convert_digit

        end_convert_digit_loop:
            sub sp, stackOffset
            add stackOffset, 2
            inc numsConvertedToBinary
            dec numsConvertedToDecimal 
            jmp get_decimal_loop

    end_get_binary_loop:
        mov stackOffset, 0
        push returnIndex
        ret    
convert_to_binary ENDP
; addToNumbers PROC      
;     mov cx, 0
;     mov dx, 0
;     mov bx, 0

;     get_digit_loop:
;         push cx
;         mov ah, 3Fh
;         mov bx, 0h                         ; stdin handle
;         mov cx, 1                          ; 1 byte to read
;         lea dx, char                       ; read to ds:dx
;         int 21h  

;         cmp ax, 0                                        ; EOF?
;         je found_EOF  
;         mov cx, 0
;         pop cx
;         mov dl, char
;         cmp dl, 0Ah                                      ; LF?
;         je digits_ended  
;         cmp dl, 0Dh                                      ; CR?
;         je digits_ended                      
;         cmp dl, ' '                                      ; пробіл?
;         je digits_ended               
;         ; cmp dl, '-'
;         ; jz mark_as_negative   

;         ; cmp dl, '0'                                      ; не цифра?
;         ; jb digits_ended       
;         ; cmp dl, '9'                                      ; не цифра?
;         ; ja digits_ended
;         jmp add_to_digits

;     ; mark_as_negative:
;     ;     push 1111111111111111B

;     add_to_digits:
;         ; push dx                ; Якщо це цифра, додати її до стеку
;         inc cx
;         mov ah, 02h
;         mov dl, '4'
;         int 21h
;         jmp get_digit_loop     

;     ; not_digit:
;     ;     ; Виводимо повідомлення про помилку
;     ;     mov ax, 0
;     ;     lea dx, error_string   
;     ;     mov ah, 09h            ; вивід рядка   
;     ;     int 21h                
;     ;     ; Завершуємо програму       
;     ;     mov ah, 4Ch           
;     ;     int 21h                

;     digits_ended: 
;         ; cmp cx, 0
;         ; je get_digit_loop
;         ; ; call convert
;         mov cx, 0
;         mov ah, 02h
;         mov dl, '9'
;         int 21h
;         jmp get_digit_loop

;     found_EOF:
;         ; pop cx
;         ; cmp cx, 0
;         ; jnz EOF_convert
;         ret

;     EOF_convert:
;         ; call convert
;         ret

; addToNumbers ENDP

; convert PROC
;         mov dl, 0             ; Очищення регістру DX (для зберігання результату)
;         mov bl, 1D

;     convert_loop:
;         cmp cx, 0               ; Перевірка, чи є ще цифри у стеці
;         jz end_convert          

;         pop ax
;         sub ax, '0'             ; Конвертація у числове значення
;         mul bx
;         add dx, ax
;         mov ax, bx
;         mov bx, 10D
;         mul bx
;         mov bx, ax

;         dec cx                  ; Зменшення лічильника цифр у стеці
;         jmp convert_loop        

;     end_convert:
;         ; call convert_to_binary        ;FFFFFIIIIIIIIXXXXXXX
;         ; mov [numbers + si], ax
;         ; add si, 2
;         ; inc numbersAmount
;         ret
; convert ENDP

; convert_to_binary PROC                          ;ПРОБЛЕМИ ІЗ ЗАЛИШКОМ МОЩНІ ДУЖЕ ЖЕСТЬ ЖОПА;ПРОБЛЕМИ ІЗ ЗАЛИШКОМ МОЩНІ ДУЖЕ ЖЕСТЬ ЖОПА;ПРОБЛЕМИ ІЗ ЗАЛИШКОМ МОЩНІ ДУЖЕ ЖЕСТЬ ЖОПА;ПРОБЛЕМИ ІЗ ЗАЛИШКОМ МОЩНІ ДУЖЕ ЖЕСТЬ ЖОПА
;     mov ax, dx
;     mov bl, 2D       ; число для поділу(двійкова система)
;     mov cx, 0      
;     jmp convert_loop_to_binary      
    
;     convert_loop_to_binary:
;         cbw
;         mov dx, 0
;         div bl               ; Ділимо AX на BX, результат зберігається у AL, а залишок у AH
;         mov dl, ah
    

;         ; add dl, '0'
;         ; mov ah, 02h
;         ; int 21h
;         ; mov ah, 0
;         ; sub dl, '0'

;         push dx              ; Зберегти залишок (0 або 1) у стек
;         inc cx

;         cmp al, 0                       ; Перевірка, чи AX = 0 (все число поділене)
;         jz prepare_for_gathering              
;         jmp convert_loop_to_binary      

;     end_convert_loop:
;         push ax
;         mov dl, ' '
;         mov ah, 02h
;         int 21h
;         pop ax
;         ret

;     prepare_for_gathering:
;         ; mov bx, 1            ; Початкова степінь двійки (1, 2, 4, 8, ...)

;         ; mov ax, cx
;         ; mul 2
;         ; sub bp, ax
;         ; pop bx
;         ; add bp, ax
;         ; mov ax, bx
;         mov al, 0B                                      ;SET AX 0 FOR TIME BEING. THEN ADD CHECK ON NEGATIVES
;         cwd
;         jmp check_if_out_of_limit

;     check_if_out_of_limit:
;         cmp cl, 15
;         jbe gather_remainders

;         cmp ax, 0
;         jns set_max_positive
;         jmp set_min_negative

;         set_max_positive:
;             mov ax, 0111111111111111B
;             jmp end_convert_loop

;         set_min_negative:
;             mov ax, 1000000000000001B
;             jmp end_convert_loop
        
;     gather_remainders:
;         cmp cl, 0             ; Перевірка, чи всі залишки зібрано
;         jz end_convert_loop         

;         pop dx                ; Вибірка залишку зі стека у регістр DX
;         ; push ax
;         ; mov ax, dx
;         ; mul bx               ;множу на поточну степінь двійки
;         ; mov dx, ax
;         ; pop ax
;         shl dx, cl
;         add ax, dx            ; Додавання поточного результату до нового залишку

;         ; shl bx, 1             ; Подвоєння степеня двійки
;         dec cl                ; Зменшення лічильника залишків
;         jmp gather_remainders       
        
; convert_to_binary ENDP


; print_array PROC
;     lea si, numbers
;     mov ah, 09h            ;    вивід рядка

;     display_loop: 
;         mov dx, [numbers + si]         
;         cmp dx, ''
;         jz finish_display

;         call print_number     
;         add si, 2     
;         jmp display_loop
        
;     finish_display:
;         mov ax, 0
;         ret
; print_array ENDP

; print_number PROC
;     mov dl, '2'
;     mov ax, 0
;     mov ah, 09h
;     int 21h
;     ret
; print_number ENDP

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