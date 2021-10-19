            section         .text

            global          _start
QWORD_BUCKET    equ             129

_start:

		    sub             rsp, 2 * QWORD_BUCKET * 8
            lea             rdi, [rsp + QWORD_BUCKET * 8]
            mov             rcx, QWORD_BUCKET
            call            read_long
            mov             rdi, rsp
            call            read_long
            lea             rsi, [rsp + QWORD_BUCKET * 8]
            call            mul_long_long

            mov             rcx, 2 * QWORD_BUCKET
            call            write_long

            mov             al, 0x0a
            call            write_char

            jmp             exit

; muls two long number
;    rsi -- address of multiplier #1 (long number)
;    rdi -- address of multiplier #2 (long number)
;    rcx -- length of long numbers in qwords
; result:
;    multiplication is written to rdi
mul_long_long:
            push            rdi
            push            rsi
            push            rcx
            push            rax
            push            rbx

            sub             rsp, 4 * QWORD_BUCKET * 8           ; memory allocation
            
            lea             rdi, [rsp + 2 * QWORD_BUCKET * 8]   ; zero result byte array
            mov             rcx, 2 * QWORD_BUCKET               ;
            call            set_zero                            ;
            
            lea             rsi, [rsi + QWORD_BUCKET * 8]       ; rsi to end of multiplier #1
            
            mov             rax, QWORD_BUCKET
.loop:      
            mov             rdi, rsp                            ; zero buffer byte array
            mov             rcx, 2 * QWORD_BUCKET               ;
            call            set_zero                            ;
            
            mov             rcx, QWORD_BUCKET                   ; copy multiplier #2 to buffer
            lea             r14, [rsp + (4 * QWORD_BUCKET + 6) * 8] ;
            call            copy_long_long  
            
            sub             rsi, 8
            mov             rbx, [rsi]                          ; mul buffer to rbx
            call            mul_long_short                      ;
            
            mov             rcx, 2 * QWORD_BUCKET               ; shift result to 1 QWORD
            lea             rdi, [rsp + 2 * QWORD_BUCKET * 8]   ;
            call            shift_long                          

            push            rsi
            lea             rsi, [rsp + 8]                          ; sum buffer to result
            call            add_long_long                       ;
            pop             rsi
            
            dec             rax
            mov             rcx, rax
            jnz             .loop   

            mov             rcx, 2 * QWORD_BUCKET               ; copy result to first rdi address
            lea             r14, [rsp + 2 * QWORD_BUCKET * 8]   ;
            lea             rdi, [rsp + (4 * QWORD_BUCKET + 6) * 8] ;
            call            copy_long_long                      ;

            add             rsp, 4 * QWORD_BUCKET * 8           ; clear memory

            pop             rbx
            pop             rax
            pop             rcx
            pop             rsi
            pop             rdi
            ret

; copy long number
;    r14 -- address of source
;    rdi -- address of target 
;    rcx -- length of long numbers in qwords
; result:
;    copied number is written to rdi
copy_long_long:
            push            r14
            push            rdi
            push            rcx
            push            rax

.loop:
            mov QWORD       rax, [r14]
            mov             [rdi], rax
            add             r14, 8
            add             rdi, 8
            dec             rcx
            jnz             .loop
            
            pop             rax
            pop             rcx
            pop             rdi
            pop             r14
            ret
            
; left shift long number to 1 QWORD
;    rdi -- address of number
;    rcx -- length of long numbers in qwords
; result:
;    shifted number is written to rdi
shift_long:
            push            rdi
            push            rcx
            push            rax
            
            lea             rdi, [rdi + rcx * 8]

            sub             rdi, 8
            dec             rcx
            
.loop:
            mov QWORD       rax, [rdi - 8]
            mov             [rdi], rax
            sub             rdi, 8
            dec             rcx
            jnz             .loop
            
            mov QWORD       [rdi], 0

            pop             rax
            pop             rcx
            pop             rdi
            ret

; adds two long number
;    rdi -- address of summand #1 (long number)
;    rsi -- address of summand #2 (long number)
;    rcx -- length of long numbers in qwords
; result:
;    sum is written to rdi
add_long_long:
            push            rdi
            push            rsi
            push            rcx
            push            rax

            clc
.loop:
            mov             rax, [rsi]
            lea             rsi, [rsi + 8]
            adc             [rdi], rax
            lea             rdi, [rdi + 8]
            dec             rcx
            jnz             .loop

            pop             rax
            pop             rcx
            pop             rsi
            pop             rdi
            ret

; adds 64-bit number to long number
;    rdi -- address of summand #1 (long number)
;    rax -- summand #2 (64-bit unsigned)
;    rcx -- length of long number in qwords
; result:
;    sum is written to rdi
add_long_short:
            push            rdi
            push            rcx
            push            rdx

            xor             rdx,rdx
.loop:
            add             [rdi], rax
            adc             rdx, 0
            mov             rax, rdx
            xor             rdx, rdx
            add             rdi, 8
            dec             rcx
            jnz             .loop

            pop             rdx
            pop             rcx
            pop             rdi
            ret

; multiplies long number by a short
;    rdi -- address of multiplier #1 (long number)
;    rbx -- multiplier #2 (64-bit unsigned)
;    rcx -- length of long number in qwords
; result:
;    product is written to rdi
mul_long_short:
            push            rax
            push            rdi
            push            rcx
            push            rsi

            xor             rsi, rsi
.loop:
            mov             rax, [rdi]
            mul             rbx
            add             rax, rsi
            adc             rdx, 0
            mov             [rdi], rax
            add             rdi, 8
            mov             rsi, rdx
            dec             rcx
            jnz             .loop

            pop             rsi
            pop             rcx
            pop             rdi
            pop             rax
            ret

; divides long number by a short
;    rdi -- address of dividend (long number)
;    rbx -- divisor (64-bit unsigned)
;    rcx -- length of long number in qwords
; result:
;    quotient is written to rdi
;    rdx -- remainder
div_long_short:
            push            rdi
            push            rax
            push            rcx

            lea             rdi, [rdi + 8 * rcx - 8]
            xor             rdx, rdx

.loop:
            mov             rax, [rdi]
            div             rbx
            mov             [rdi], rax
            sub             rdi, 8
            dec             rcx
            jnz             .loop

            pop             rcx
            pop             rax
            pop             rdi
            ret

; assigns a zero to long number
;    rdi -- argument (long number)
;    rcx -- length of long number in qwords
set_zero:
            push            rax
            push            rdi
            push            rcx

            xor             rax, rax
            rep stosq

            pop             rcx
            pop             rdi
            pop             rax
            ret

; checks if a long number is a zero
;    rdi -- argument (long number)
;    rcx -- length of long number in qwords
; result:
;    ZF=1 if zero
is_zero:
            push            rax
            push            rdi
            push            rcx

            xor             rax, rax
            rep scasq

            pop             rcx
            pop             rdi
            pop             rax
            ret

; read long number from stdin
;    rdi -- location for output (long number)
;    rcx -- length of long number in qwords
read_long:
            push            rcx
            push            rdi

            call            set_zero
.loop:
            call            read_char
            or              rax, rax
            js              exit
            cmp             rax, 0x0a
            je              .done
            cmp             rax, '0'
            jb              .invalid_char
            cmp             rax, '9'
            ja              .invalid_char

            sub             rax, '0'
            mov             rbx, 10
            call            mul_long_short
            call            add_long_short
            jmp             .loop

.done:
            pop             rdi
            pop             rcx
            ret

.invalid_char:
            mov             rsi, invalid_char_msg
            mov             rdx, invalid_char_msg_size
            call            print_string
            call            write_char
            mov             al, 0x0a
            call            write_char

.skip_loop:
            call            read_char
            or              rax, rax
            js              exit
            cmp             rax, 0x0a
            je              exit
            jmp             .skip_loop

; write long number to stdout
;    rdi -- argument (long number)
;    rcx -- length of long number in qwords
write_long:
            push            rax
            push            rcx

            mov             rax, 20
            mul             rcx
            mov             rbp, rsp
            sub             rsp, rax

            mov             rsi, rbp

.loop:
            mov             rbx, 10
            call            div_long_short
            add             rdx, '0'
            dec             rsi
            mov             [rsi], dl
            call            is_zero
            jnz             .loop

            mov             rdx, rbp
            sub             rdx, rsi
            call            print_string

            mov             rsp, rbp
            pop             rcx
            pop             rax
            ret

; read one char from stdin
; result:
;    rax == -1 if error occurs
;    rax \in [0; 255] if OK
read_char:
            push            rcx
            push            rdi

            sub             rsp, 1
            xor             rax, rax
            xor             rdi, rdi
            mov             rsi, rsp
            mov             rdx, 1
            syscall

            cmp             rax, 1
            jne             .error
            xor             rax, rax
            mov             al, [rsp]
            add             rsp, 1

            pop             rdi
            pop             rcx
            ret
.error:
            mov             rax, -1
            add             rsp, 1
            pop             rdi
            pop             rcx
            ret

; write one char to stdout, errors are ignored
;    al -- char
write_char:
            sub             rsp, 1
            mov             [rsp], al

            mov             rax, 1
            mov             rdi, 1
            mov             rsi, rsp
            mov             rdx, 1
            syscall
            add             rsp, 1
            ret

exit:
            mov             rax, 60
            xor             rdi, rdi
            syscall

; print string to stdout
;    rsi -- string
;    rdx -- size
print_string:
            push            rax

            mov             rax, 1
            mov             rdi, 1
            syscall

            pop             rax
            ret


            section         .rodata
invalid_char_msg:
            db              "Invalid character: "
invalid_char_msg_size: equ             $ - invalid_char_msg
