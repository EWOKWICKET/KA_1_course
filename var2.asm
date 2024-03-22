.model small
.stack 1000h

.data
numbers dw 1000 dup(?)          ;масив із числами
numbersAmount dw ?        
digitsRead dw 0                 ;кількість цифр у числі
numsRead dw 0                   ;кількість зчитаних з файлу чисел
numsConvertedToDecimal dw 0     ;кількість жесяткових чисел
numsConvertedToBinary dw 0      ;кількість двійкових чисел
decimalHolder dw 0D              ;змінна, що матиме повне конвертоване десяткове число
char db  0                      ;містить зчитаний символ
returnIndex dw 0                ;змінна для утримування індексу для повернення до місця виклику функції


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
    call bubbleSort
    call medianAndAverage
    
    jmp end_program

main ENDP


;reads and prints file, preparing for converting(digits of num and amount of digits are in stack)
read_loop PROC
    pop returnIndex                        ;зберіг ip повернення, бо буду працювати із стеком
    read_file:
        mov ah, 3Fh
        mov bx, 0h                         ; stdin handle
        mov cx, 1                          ; 1 byte to read
        lea dx, char                       ; read to ds:dx
        int 21h                        
        cmp ax, 0                          ; EOF?
        jz end_of_file

        mov dx, 0
        ; mov ah, 02h
        mov dl, char
        ; int 21h

        cmp dl, 13                                      ; LF?
        je read_not_digit
        cmp dl, 10                                      ; CR?
        je read_not_digit
        cmp dl, ' '                                     ;space?
        je read_not_digit
        cmp dl, 0                                       ;EOF?
        je end_of_file
        cmp dl, '-' 
        je negative
        cmp digitsRead, 6
        je read_file
        inc digitsRead
        sub dl, '0'
        push dx
        jmp read_file
    ;якщо прочитана не цифра. Якщо до цього були прочитані цифри, то зупиняє підрахунок цифр у числі
    read_not_digit:
        cmp digitsRead, 0
        jne end_of_num
        jmp read_file

    negative:
        push dx
        inc digitsRead
        jmp read_file
    ;EOF found
    end_of_file:
        cmp digitsRead, 0
        jne last_num
        push returnIndex
        ret
    ;кладе в стек кількість цифр у числі
    end_of_num:
        push digitsRead
        mov digitsRead, 0
        inc numsRead
        jmp read_file

    ;if EOF was met after reading digits
    last_num:
        push digitsRead
        mov digitsRead, 0
        inc numsRead
        push returnIndex
        ret
read_loop ENDP

;converts each num in stack into decimal and pushes them to stack
convert_to_decimal PROC
    pop returnIndex                                     ;зберіг ip повернення, бо буду працювати із стеком
    mov ax, numsRead
    mov numbersAmount, ax
    ;переходжу вперед по масиву, щоб зберегти порядок елементів
    lea si, numbers
    mov ax, numsRead
    dec ax
    mov bx, 2
    mul bx
    add si, ax              
    mov ax, 0
    mov bx, 0
    ;перетворення усіх зчитаних символів чисел у десяткові і заповнення масиву
    get_decimal_loop:
        cmp numsRead, 0
        je end_get_decimal_loop

        pop cx                          ;кількість цифр у числі
        mov bx, 1
        ;конвертує одне число
        convert_char_loop:

            cmp cx, 1
            jbe check_if_negative

            pop ax
            ;конвертує цифру числа
            convert_char:
                mul bx
                add decimalHolder, ax           ;додаю число домножене на певну степінь 10 до змінної, в якій лежатиме повне число
                jo limit_reached                ; sets number 7FFFh if too big for 16-bit
                mov ax, bx
                mov bx, 10
                mul bx
                mov bx, ax
                dec cx
                jmp convert_char_loop

            limit_reached:
                mov decimalHolder, 7FFFh
                skip:
                    cmp cx, 0
                    je end_convert_char_loop
                    pop ax
                    cmp ax, '-'
                    je negate
                    dec cx
                    jmp skip

            ; перевіряє, чи буде мінус. Якщо так, то множить на -1
            check_if_negative:
                cmp cx, 0
                je end_convert_char_loop
                pop ax
                cmp ax, '-'
                je negate
                jmp convert_char
            ; множить на -1
            negate:
                dec cx
                mov ax, decimalHolder 
                xor ax, 0FFFFh
                add ax, 01B
                mov decimalHolder, ax
                jmp end_convert_char_loop


        ;кінець конвертації числа і його занесення в масив
        end_convert_char_loop:
            mov ax, decimalHolder
            mov [si], ax
            sub si, 2
            mov decimalHolder, 0D
            ; inc numbersAmount
            inc numsConvertedToDecimal
            dec numsRead 
            jmp get_decimal_loop
    
    end_get_decimal_loop:
        push returnIndex
        ret    
convert_to_decimal ENDP

;converts each decimal in stack into binary and pushes them to stack
convert_to_binary PROC
    pop returnIndex                         ;зберіг ip повернення, бо буду працювати із стеком
    lea si, numbers
    get_binary_loop:
        cmp numsConvertedToDecimal, 0
        je end_get_binary_loop
        mov ax, [si]
        add si, 2                   ;збільшення індексу для робоит з масивом
        mov digitsRead, 0D          
        mov bx, 2                   ;дільник
        convert_digit_loop:
            mov dx, 0
            div bx
            push dx                 ;остача
            inc digitsRead

            cmp ax, 0               ;перевіряю частку
            je full_convert
            jmp convert_digit_loop
            ;число в доповняльному коді(поки що тільки додатні)
            full_convert:
                mov bx, digitsRead
                mov cx, 16
                sub cx, bx
                ;доповнляьний код
                additional_code:
                    cmp cx, 0
                    je remainders_gathering
                    ; mov ah, 02h
                    ; mov dx, '0'
                    ; int 21h
                    dec cx
                    jmp additional_code
                ;основне число
                remainders_gathering:
                    cmp digitsRead, 0
                    je end_convert_digit_loop
                    ; pop dx
                    ; mov ah, 02h
                    ; add dx, '0'
                    ; int 21h
                    dec digitsRead
                    jmp remainders_gathering

        ;розділення між числами
        end_convert_digit_loop:
            ; mov ah, 02h
            ; mov dx, ' '
            ; int 21h
            inc numsConvertedToBinary
            dec numsConvertedToDecimal 
            jmp get_binary_loop

    end_get_binary_loop:
        push returnIndex
        ret    
convert_to_binary ENDP

;sorts the array
bubbleSort PROC
    pop returnIndex                        ;зберіг ip повернення, бо буду працювати із стеком
    mov cx, numbersAmount
    dec cx  ; count-1
    outerLoop:
        push cx
        lea si, numbers
    innerLoop:
        mov ax, [si]
        cmp ax, [si+2]
        jl nextStep
        xchg [si+2], ax
        mov [si], ax
    nextStep:
        add si, 2
        loop innerLoop
        pop cx
        loop outerLoop
    push returnIndex
    ret
bubbleSort ENDP

;prints median and average
medianAndAverage PROC
    pop returnIndex                        ;зберіг ip повернення, бо буду працювати із стеком


    push returnIndex
    ret
medianAndAverage ENDP

;завершення програми
end_program PROC
    mov ax, 0
    mov bx, 0
    mov cx, 0
    mov dx, 0
    mov ah, 4Ch            ; завершення програми
    int 21h 
end_program ENDP

end main