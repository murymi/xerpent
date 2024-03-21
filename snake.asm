%include "help.asm"

section .data
title: db "snake", 0
food_image_path: db "./screen.png", 0
screen_height: equ 750
screen_width:  equ 750

green:      db 173, 204, 96, 255
dark_green: db 43, 51, 24, 255
pfmt: db "x = %d, y = %d",10, 0 

last_update_time: dq 0.0
interval: dq 0.2

cell_size:  equ 25
cell_count: equ 25

food: istruc Food 
    at Food.x, dd 5
    at Food.y, dd 6
iend 

direction_x: dd 1
direction_y: dd 0


section .bss
food_image:   resd 6
food_texture: resd 5 
head: resq 1

section .text
global _start
_start:

    create_snake(qword[head], 1, 1)

    push_back_snake(qword[head], 1, 2)
    push_back_snake(qword[head], 1, 3)
    push_back_snake(qword[head], 1, 4)

    pop_back_snake(qword[head])
    ;pop_back_snake(qword[head])
    ;pop_back_snake(qword[head])
    ;pop_back_snake(qword[head])


    ;push_front_snake(qword[head], 9, 3)


    ;sys_exit(0)

    init_window(cell_size*cell_count, cell_size*cell_count, title)
    set_target_fps(60)

    ;load_image(food_image_path, food_image)
    ;load_texture_from_image(food_image, food_texture)

    ;unload_image(food_image)
    get_random_value(0, cell_count - 1)
    mov dword[food+Food.x], eax
    get_random_value(0, cell_count - 1)
    mov dword[food+Food.y], eax


.gloop:

    window_should_close()
    cmp rax, 0
    jne .endgloop
    begin_drawing()

    call EventTriggered
    cmp rax, 1
    jne .L1
    mov rdi, qword[head]
    call UpdateSnake
.L1:
    clear_background(dword[green])

    call DrawFood

    mov rdi, qword[head]
    call DrawSnake


    print_snake(qword[head])


    ;sys_exit(1)

    end_drawing()
    jmp .gloop

.endgloop:
    close_window()
    sys_exit(0)

DrawFood:
    begin
    mov eax, dword[food+Food.x]
    mul_i32(eax, cell_size)
    mov rcx, rax
    mov eax, dword[food+Food.y]
    mul_i32(eax, cell_size)
    draw_rectangle(ecx, eax, cell_size, cell_size, dword[dark_green])
    ;draw_texture(food_texture, ecx, eax, 0xffffffff)
    end 0


InitBody:
    begin
    push rdi
    push rsi
    mem_alloc(Snake_size)
    pop rsi
    pop rdi
    mov dword[rax+Snake.x], edi
    mov dword[rax+Snake.y], esi
    mov qword[rax+Snake.nxt], 0
    end rax

;; rdi
DrawSnake:
    begin
    mov rcx, rdi
    cmp rcx, 0
    je .L3
    push r15
    push r14
.L1:
    mov eax, dword[rcx+Snake.x]
    mul_i32(eax, cell_size)
    mov r15, rax
    mov eax, dword[rcx+Snake.y]
    mul_i32(eax, cell_size)
    mov r14, rax

    mov eax, cell_size
    push rcx
    draw_rectangle_rounded(r15d, r14d, eax, eax, 0.5, 6, 0xffffffff)
    pop rcx
    cmp qword[rcx+Snake.nxt], 0
    je .L2

    mov rcx, qword[rcx+Snake.nxt]
    jmp .L1
.L2:
    pop r14
    pop r15
.L3
    end 0

PopBackSnake:
    begin
    cmp rdi, 0 ;ptr
    je .Ext
    cmp qword[rdi+Snake.nxt], 0
    je .Ext
    mov rcx, rdi
.L1
    mov rax, qword[rcx+Snake.nxt]
    cmp qword[rax+Snake.nxt], 0
    je .Del
    mov rcx, qword[rcx+Snake.nxt]
    jmp .L1
.Del:
    push rcx
    mem_free(qword[rcx+Snake.nxt])
    pop rcx
    mov qword[rcx+Snake.nxt], 0
.Ext:
    end 0

;; rdi
PushBackSnake:
    begin
    cmp rdi, 0
    je .L3
.L1:
    cmp qword[rdi+Snake.nxt], 0
    je .L2
    mov rdi, qword[rdi+Snake.nxt]
    jmp .L1
.L2:
    push rdi
    mov rdi, rsi
    mov rsi, rdx
    call InitBody
    pop rdi
    mov qword[rdi+Snake.nxt], rax
    end rax
.L3
    end 0

PrintSnake:
    begin
    push 0
.L1
    cmp rdi, 0
    je .Ext
    mov esi, dword[rdi+Snake.x]
    mov edx, dword[rdi+Snake.y]
    push rdi
    mov rdi, pfmt
    extern printf
    call printf
    pop rdi
    mov rdi, [rdi+Snake.nxt]
    jmp .L1
.Ext:
    end 0

PushFrontSnake:
    begin
    push rdi
    mov rdi, rsi
    mov rsi, rdx
    call InitBody 

    pop rdi

    mov qword[rax+Snake.nxt], rdi
    mov qword[head], rax
    end 0

UpdateSnake:
    begin
    push rdi
    pop_back_snake(rdi)
    pop rdi
    mov ecx, dword[rdi+Snake.x]
    add ecx, dword[direction_x]
    mov eax, dword[rdi+Snake.y]
    add eax, dword[direction_y]
    push_front_snake(rdi, rcx, rax)
    end 0

EventTriggered:
    begin
    get_time()
    subsd xmm0, qword[interval]
    ucomisd xmm0, qword[last_update_time]
    jb .L1
    addsd xmm0, qword[interval] 
    movsd qword[last_update_time], xmm0
    end 1
.L1:
    end 0

UpdateDirection:
    begin
    
    end 0

section '.note.GNU-stack'

