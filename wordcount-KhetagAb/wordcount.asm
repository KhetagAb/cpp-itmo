sys_exit:       equ             60

                section         .text
                global          _start

read_call:      equ             0
write_call:     equ             1

stdin_desc:     equ             0
stdout_desc:    equ             1
stderr_desc:    equ             2

buf_size:       equ             8192

_start:

                sub             rsp, buf_size
                mov             rsi, rsp

                xor             ebx, ebx    ; words count (rbx = 0)
                xor             r9b, r9b    ; "on char" flag

read_again:
                mov             eax, read_call
                mov             edi, stdin_desc
                mov             rdx, buf_size
                syscall

                test            rax, rax
                jz              quit
                js              read_error

                xor             ecx, ecx
check_char:
                cmp rcx, rax
                je read_again

                mov r8b, byte [rsi + rcx]
                cmp r8b, 32
                je is_whitespace
                sub r8b, 9
                cmp r8b, 4
            ; 9 <= [rsi + rcx] && [rsi + rcx] <= 13
            ; 9 - [rsi + rcx] <= 13 - 9 = 4
                jle is_whitespace ; in unsigned 9 - [rsi + rcx] with overflow is above 4

                test r9b, r9b
                jnz skip
                inc rbx ; "on char" flag 0 -> 1 === new word!
is_char:
                inc r9b
                jmp skip
is_whitespace:
                xor r9b, r9b
skip:
                inc rcx
                jmp check_char

quit:
                mov             rax, rbx
                call            print_int

                mov             rax, sys_exit
                xor             rdi, rdi
                syscall

; rax -- number to print
print_int:
                mov             rsi, rsp
                mov             rbx, 10

                dec             rsi
                mov             byte [rsi], 0x0a

next_char:
                xor             edx, edx
                div             rbx
                add             dl, '0'
                dec             rsi
                mov             [rsi], dl
                test            rax, rax
                jnz             next_char

                mov             eax, write_call
                mov             edi, stdout_desc
                mov             rdx, rsp
                sub             rdx, rsi
                syscall

                ret

read_error:
                mov             eax, write_call
                mov             edi, stderr_desc
                mov             rsi, read_error_msg
                mov             rdx, read_error_len
                syscall

                mov             rax, sys_exit
                mov             edi, 1
                syscall

                section         .rodata

read_error_msg: db              "read failure", 0x0a
read_error_len: equ             $ - read_error_msg
