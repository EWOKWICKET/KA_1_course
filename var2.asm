.model small
.stack 40000

.data
numbers dw 10000 dup(?)          ;масив із числами
numbersAmount dw ?              ;кількість чисел у масиві
negated db 0
digitsRead dw 0                 ;кількість цифр у числі
numsRead dw 0                   ;кількість зчитаних з файлу чисел
numsConvertedToDecimal dw 0     ;кількість десяткових чисел(для циклу)
numsConvertedToBinary dw 0      ;кількість двійкових чисел(для циклу)
decimalHolder dw 0D             ;змінна, що матиме повне конвертоване десяткове число
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

    call read_loop                      ;зчитує символи
    call convert_to_decimal             ;конвертує зчитані символи в десяткові числа. Слідкує, щоб не виходили за межі 16 бітів зі знаковим бітом
    ; call print_binary                 ;виводить зчитані числа у двійковому доповняльному 16-бітному коді
    call bubbleSort                     ;сортує масив чисел
    call medianAndAverage               ;виводить медіану і сережнє арифметичне
    
    jmp end_program

main ENDP


;зчитує числа(за потреби виводить), і закидує в стек для подальшого конвертування(цифри числа і кількість цифр у числі)
read_loop PROC
    pop returnIndex                        ;зберіг ip повернення, бо буду працювати із стеком
    read_file:
        mov ah, 3Fh
        mov bx, 0h                         ; stdin handle
        mov cx, 1                          ; 1 байт для читання
        lea dx, char                       ; зчитати to ds:dx
        int 21h                        
        cmp ax, 0                          ; EOF?
        jz end_of_file

        mov dx, 0
        ; mov ah, 02h                      ;виводить цифру
        mov dl, char                       ;забирає зчитаний символ
        ; int 21h

        cmp dl, 13                                      ; LF?
        je read_not_digit
        cmp dl, 10                                      ; CR?
        je read_not_digit
        cmp dl, ' '                                     ;space?
        je read_not_digit
        cmp dl, 0                                       ;EOF?
        je end_of_file
        cmp dl, '-'                                     ; -?
        je negative
        cmp digitsRead, 6
        je read_file
        inc digitsRead
        sub dl, '0'
        push dx
        jmp read_file
    ;Прочитана не цифра. Якщо до цього були прочитані цифри, то зупиняє підрахунок цифр у числі
    read_not_digit:
        cmp digitsRead, 0
        jne end_of_num
        jmp read_file
    ;зустрівся мінус
    negative:
        push dx
        inc digitsRead
        jmp read_file
    ;зустрівся EOF
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

    ;якщо зустрівся EOF після зчитування числа
    last_num:
        push digitsRead
        mov digitsRead, 0
        inc numsRead
        push returnIndex
        ret
read_loop ENDP

;конвертує зчитані символи в числа, слідкує за переповненням регістрів. Потім кладе в масив
convert_to_decimal PROC
    pop returnIndex                                     ;зберіг ip повернення, бо буду працювати із стеком
    ;записую в змінну кількість зчитаних чисел
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

            pop ax                      ;цифра числа
            dec cx
            ;конвертує цифру числа
            convert_char:
                mul bx
                add decimalHolder, ax           ;додаю число домножене на певну степінь 10 до змінної, в якій лежатиме повне число
                js limit_reached                ;перевіряє, чи число велике для 16-біного знакового уявлення
                mov ax, bx
                mov bx, 10
                mul bx
                mov bx, ax
                jmp convert_char_loop
            ; встановлює значення 7FFFh якщо було переповнення(8000h якщо від'ємне)
            limit_reached:
                mov decimalHolder, 7FFFh
                skip:
                    cmp cx, 0
                    je end_convert_char_loop
                    pop ax
                    dec cx
                    cmp ax, '-'
                    jne skip
                    mov ax, decimalHolder
                    xor ax, 0FFFFh
                    mov decimalHolder, ax
                    jmp skip

            ; перевіряє, чи буде мінус. Якщо так, то множить на -1
            check_if_negative:
                cmp cx, 0
                je end_convert_char_loop
                pop ax
                dec cx
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
            mov ax, 0
            ; mov cx, 0
            inc numsConvertedToDecimal
            dec numsRead 
            jmp get_decimal_loop
    
    end_get_decimal_loop:
        push returnIndex
        ret    
convert_to_decimal ENDP

;виводить двійкові значення усіхх зчитаних чисел
print_binary PROC
    pop returnIndex                         ;зберіг ip повернення, бо буду працювати із стеком
    lea si, numbers
    get_binary_loop:
        cmp numsConvertedToDecimal, 0
        je end_get_binary_loop
        mov ax, [si]
        add si, 2                   ;збільшення індексу для роботи з наступними елементами масиву
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
            ;число в доповняльному коді
            full_convert:
                mov bx, digitsRead
                mov cx, 16
                sub cx, bx
                ;доповнляьний код
                additional_code:
                    cmp cx, 0
                    je remainders_gathering
                    mov ah, 02h
                    mov dx, '0'                     ;виводить доповняльний код(16 біт)
                    int 21h
                    dec cx
                    jmp additional_code
                ;основне число
                remainders_gathering:
                    cmp digitsRead, 0
                    je end_convert_digit_loop
                    pop dx
                    mov ah, 02h                     ;виводить остачу від ділення
                    add dx, '0'
                    int 21h
                    dec digitsRead
                    jmp remainders_gathering

        ;розділення між числами
        end_convert_digit_loop:
            mov ah, 02h
            mov dx, ' '
            int 21h
            inc numsConvertedToBinary
            dec numsConvertedToDecimal 
            jmp get_binary_loop

    end_get_binary_loop:
        mov ax, 0
        mov dx, 0
        mov ah, 02h
        mov dl, 13
        int 21h
        mov dl, 10
        int 21h
        push returnIndex
        ret    
print_binary ENDP

;сортує масив
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
        jl nextStep                         ;якщо менше ніж наступний, то наступний крок
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

;виводить медіану і середнє арифметичне
medianAndAverage PROC
    pop returnIndex                        ;зберіг ip повернення, бо буду працювати із стеком
    mov ax, 0
    mov bx, 0
    mov dx, 0

    median:
        ;ділю довжину масиву навпіл і множу на 2, щоб дістатсь середини(якщо непарне - середина, якщо парне - правий елемент)
        lea si, numbers
        mov ax, numbersAmount
        mov bx, 2
        div bx
        mul bx
        add si, ax
        mov ax, [si]
        ;виводжу медіану
        print_median:
            mov bx, 10
            mov decimalHolder, 0

            median_loop:
                mov dx, 0
                div bx

                mov decimalHolder, ax
                mov ax, 0
                mov ah, 02h
                add dx, '0'
                int 21h
                mov ax, decimalHolder
                cmp ax, 0
                je end_median_loop

                mov dx, ax
                mov ax, bx
                mov bx, 10
                mul bx
                mov bx, ax
                mov ax, dx
                jmp median_loop

            end_median_loop:
                mov ax, 0
                mov ah, 02h
                mov dx, 13
                int 21h
                mov dl, 10
                int 21h
                mov ax, 0
                mov dx, 0
                jmp average   


    average:
        lea si, numbers
        mov ax, 0
        mov cx, numbersAmount
        ;обраховую суму усіх елемнтів масиву        UNDER WORK
        sumCollecting:
            cmp cx, 0
            je find_average
            mov dx, 0
            mov bx, [si]
            add si, 2
            add ax, bx
            adc dx, 0
            dec cx
            jmp sumCollecting

    ; множить на -1
        negate_aux:
            cmp ax, 0
            jns stop_negate_aux
            xor ax, 0FFFFh
            add ax, 01B
            mov negated, 1
            jmp stop_negate_aux

        stop_negate_aux:
            ret

        find_average:
            call negate_aux
            mov bx, numbersAmount
            div bx
            
            mov bx, 0
            mov bl, negated
            cmp bl, 1
            jne print_average
            mov negated, 0
            xor ax, 0FFFFh
            add ax, 01B

            ;виводжу середнє арифметичне
            print_average:
                mov bx, 10
                mov decimalHolder, 0
                cmp ax, 0
                jns average_loop
                xor ax, 0FFFFh
                add ax, 01B
                push ax
                mov ax, 0
                mov ah, 02h
                mov dl, '-'
                int 21h
                pop ax

                average_loop:
                    mov dx, 0
                    div bx

                    mov decimalHolder, ax
                    mov ax, 0
                    mov ah, 02h
                    add dx, '0'
                    int 21h
                    mov ax, decimalHolder
                    cmp ax, 0
                    je end_average_loop

                    mov dx, ax
                    mov ax, bx
                    mov bx, 10
                    mul bx
                    mov bx, ax
                    mov ax, dx
                    jmp average_loop

                end_average_loop:
                    mov ax, 0
                    mov dx, 0
                    mov ax, 0
                    mov ah, 02h
                    mov dx, 13
                    int 21h
                    mov dl, 10
                    int 21h
                    jmp end_median_and_average            

    end_median_and_average:
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