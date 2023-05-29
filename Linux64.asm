; 64-Bit
; Linux (Windows uses different calling convention)
; github.com/x444556

[BITS 64]

EXTERN malloc
EXTERN free

GLOBAL bucket_sort
GLOBAL bucket_sort_kvp
GLOBAL selection_sort
GLOBAL selection_sort_kvp

GLOBAL compare
GLOBAL copy

section .text

    compare:    ; uint64_t compare(void* arr1, void* arr2, uint64_t length)
        push rbp
        mov rbp, rsp

        xor rax, rax ; return Count of different bytes

        .loop:
            mov CL, BYTE [rdi]
            cmp CL, BYTE [rsi]
            je .equal
                inc rax
            .equal:

            inc rdi
            inc rsi
            dec rdx

            and rdx, rdx
            jnz .loop

        mov rsp, rbp
        pop rbp
        ret

    copy:    ; void* copy(void* source, uint64_t length)
        push rbp
        mov rbp, rsp

        push rdi
        push rsi
        mov rdi, rsi
        call malloc WRT ..plt ; dest* in rax
        mov R8, rax
        pop rcx ; counter
        pop rdi ; source*

        .loop:
            mov DL, BYTE [rdi]
            mov BYTE [rax], DL

            inc rdi
            inc rax
            dec rcx

            and rcx, rcx
            jnz .loop

        mov rax, R8
        mov rsp, rbp
        pop rbp
        ret

    bucket_sort:       ; void bucket_sort(uint64_t a[], uint64_t length, uint64_t min_key, uint64_t max_key)
        push rbp
        mov rbp, rsp

        sub rsp, 8 ; QWORD [rbp -  8]  MIN_KEY
        sub rsp, 8 ; QWORD [rbp - 16]  ---                      Not used anymore
        sub rsp, 8 ; QWORD [rbp - 24]  INPUT_ARRAY_PTR
        sub rsp, 8 ; QWORD [rbp - 32]  STORAGE_ARRAY_PTR
        sub rsp, 8 ; QWORD [rbp - 40]  INPUT_ARRAY_LENGTH
        sub rsp, 8 ; QWORD [rbp - 48]  STORAGE_ARRAY_LENGTH

        mov QWORD [rbp -  8], rdx
        mov QWORD [rbp - 24], rdi
        mov QWORD [rbp - 40], rsi

        sub rcx, rdx
        mov QWORD [rbp - 48], rcx
        imul rcx, QWORD 8
        mov rdi, rcx
        call malloc WRT ..plt
        mov QWORD [rbp - 32], rax

        xor rcx, rcx ; index
        mov rdi, QWORD [rbp - 24] ; INPUT_ARRAY_PTR
        .fill:
            cmp rcx, QWORD [rbp - 40]
            jae .fill_end

            mov rax, QWORD [rdi]
            sub rax, QWORD [rbp - 8]
            imul rax, QWORD 8
            add rax, QWORD [rbp - 32]

            inc QWORD [rax]

            add rdi, 8
            inc rcx
            jmp .fill
        .fill_end:

        xor rcx, rcx ; index in STORAGE_ARRAY
        mov rdi, QWORD [rbp - 32] ; STORAGE_ARRAY_PTR
        mov rsi, QWORD [rbp - 24] ; OUTPUT_ARRAY_PTR
        .read:
            cmp rcx, QWORD [rbp - 48] ; while(rcx < STORAGE_ARRAY_LENGTH)
            je .read_end

            mov rdx, QWORD [rdi]
            .write:
                and rdx, rdx
                jz .write_end
                mov rax, rcx
                add rax, QWORD [rbp - 8]
                mov QWORD [rsi], rax
                add rsi, 8
                dec rdx
                jmp .write
            .write_end:

            add rdi, 8
            inc rcx
            jmp .read
        .read_end:

        mov rdi, QWORD [rbp - 32]
        call free WRT ..plt

        mov rsp, rbp ; restore stack pointer + free local variables
        pop rbp
        ret
    selection_sort:    ; void selection_sort(uint64_t a[], uint64_t length)
        push rbp
        mov rbp, rsp

        ; rcx : inner Loop counter
        ; rdx : outer Loop counter
        ; rdi : Array*
        ; rsi : Length
        ; R8  : Smallest Value
        ; R9  : Index of R8

        xor rdx, rdx
        .loop:
            mov rcx, rdx
            xor R8, R8
            not R8
            mov R9, rdx
            mov rax, rdx
            imul rax, 8
            add rax, rdi
            .loop_2:
                cmp QWORD [rax], R8
                jae .larger
                mov R8, QWORD [rax]
                mov R9, rcx
                .larger:
                add rax, 8
                inc rcx
                cmp rcx, rsi
                jb .loop_2

            mov rax, rdx
            imul rax, 8
            add rax, rdi
            mov R10, QWORD [rax]
            mov QWORD [rax], R8
            imul R9, 8
            add R9, rdi
            mov QWORD [R9], R10

            inc rdx
            cmp rdx, rsi
            jb .loop

        mov rsp, rbp
        pop rbp
        ret
    selection_sort_kvp:    ; void selection_sort_kvp(struct Element a[], uint64_t length)
        push rbp
        mov rbp, rsp

        ; rcx : inner Loop counter
        ; rdx : outer Loop counter
        ; rdi : Array*
        ; rsi : Length
        ; R8  : Smallest Key
        ; R9  : Index of R8
        ; R10 : temp
        ; R11 : Value at R9

        xor rdx, rdx
        .loop:
            mov rcx, rdx
            xor R8, R8
            not R8
            mov R9, rdx
            mov rax, rdx
            imul rax, 16
            add rax, rdi
            .loop_2:
                cmp QWORD [rax], R8
                jae .larger
                mov R8, QWORD [rax]
                mov R11, QWORD [rax + 8]
                mov R9, rcx
                .larger:
                add rax, 16
                inc rcx
                cmp rcx, rsi
                jb .loop_2

            ; swap keys
            mov rax, rdx
            imul rax, 16
            add rax, rdi
            mov R10, QWORD [rax]
            mov QWORD [rax], R8
            mov rax, R9
            imul R9, 16
            add R9, rdi
            mov QWORD [R9], R10
            mov R9, rax

            ; swap values
            mov rax, rdx
            imul rax, 16
            add rax, rdi
            mov R10, QWORD [rax + 8]
            mov QWORD [rax + 8], R11
            imul R9, 16
            add R9, rdi
            mov QWORD [R9 + 8], R10

            inc rdx
            cmp rdx, rsi
            jb .loop

        mov rsp, rbp
        pop rbp
        ret
    bucket_sort_kvp:       ; uint64_t bucket_sort_kvp(uint64_t a[], uint64_t length, uint64_t min_key, uint64_t max_key, uint64_t allocListLength)
        push rbp
        mov rbp, rsp

        sub rsp, 8 ; QWORD [rbp -  8]  MIN_KEY
        sub rsp, 8 ; QWORD [rbp - 16]  MAX_LIST_LENGTH
        sub rsp, 8 ; QWORD [rbp - 24]  INPUT_ARRAY_PTR
        sub rsp, 8 ; QWORD [rbp - 32]  STORAGE_ARRAY_PTR
        sub rsp, 8 ; QWORD [rbp - 40]  INPUT_ARRAY_LENGTH
        sub rsp, 8 ; QWORD [rbp - 48]  STORAGE_ARRAY_LENGTH

        mov QWORD [rbp -  8], rdx
        mov QWORD [rbp - 24], rdi
        mov QWORD [rbp - 40], rsi
        mov QWORD [rbp - 16], R8

        sub rcx, rdx
        mov QWORD [rbp - 48], rcx

        mov rdi, QWORD [rbp - 48]
        mov rax, QWORD [rbp - 16]
        shl rax, 3 ; rax *= 8
        add rax, 8
        imul rdi, rax
        call malloc WRT ..plt
        mov QWORD [rbp - 32], rax
        
        xor rcx, rcx ; rcx = index
        ;xor rdi, rdi ; rdi = address in input
        mov rdi, QWORD [rbp - 24]

        mov rax, QWORD [rbp - 16]
        shl rax, 3 ; rax *= 8
        add rax, 8
        mov R8, rax ; R8 = bytes per entry in STORAGE_ARRAY
        mov R9, QWORD [rbp - 16]
        .fill:
            cmp rcx, QWORD [rbp - 40]
            je .fill_end

            ; address of List in STORAGE_ARRAY -> rsi
            mov rsi, QWORD [rdi]
            sub rsi, QWORD [rbp - 8]
            imul rsi, R8
            add rsi, QWORD [rbp - 32]

            ; increase List Counter
            inc QWORD [rsi]

            ; read List Counter
            mov rax, QWORD [rsi]
            ; check for List-Overflow
            cmp rax, R9
            je .list_overflow

            mov rdx, rsi
            ;imul rax, 8
            shl rax, 3
            add rdx, rax ; address of current List Entry -> rdx
            mov rax, QWORD [rdi + 8] ; read value from INPUT_ARRAY
            mov QWORD [rdx], rax ; write value to List

            add rdi, 16
            inc rcx
            jmp .fill
        .fill_end:

        xor rcx, rcx ; index in STORAGE_ARRAY
        mov rdi, QWORD [rbp - 32] ; STORAGE_ARRAY_PTR
        mov rsi, QWORD [rbp - 24] ; OUTPUT_ARRAY_PTR
        .read:
            cmp rcx, QWORD [rbp - 48] ; while(rcx < STORAGE_ARRAY_LENGTH)
            je .read_end

            xor rdx, rdx
            .write:
                cmp rdx, QWORD [rdi]
                je .write_end

                ; rax = value at [STORAGE_ARRAY_PTR(current element) + (current_list_index+1)*8] (this is the value)
                mov rax, QWORD [rdi + (rdx + 1) * 8]
                mov QWORD [rsi + 8], rax

                ; rax = index_STORAGE_ARRAY + MIN_KEY (this is the key)
                mov rax, rcx
                add rax, QWORD [rbp - 8]
                mov QWORD [rsi], rax

                add rsi, 16
                inc rdx
                jmp .write
            .write_end:

            add rdi, R8
            inc rcx
            jmp .read
        .read_end:

        mov rdi, QWORD [rbp - 32]
        call free WRT ..plt ; free temporary array
        xor rax, rax ; return 0 -> success
        mov rsp, rbp ; restore stack pointer + free local variables
        pop rbp
        ret

        .list_overflow:
            mov rdi, QWORD [rbp - 32]
            call free WRT ..plt
            mov rax, 1 ; return 1 -> error
            mov rsp, rbp
            pop rbp
            ret