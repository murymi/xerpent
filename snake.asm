%include "help.asm"

section .data
title: db "Murimi's Snake", 0
food_image_path: db "./screen.png", 0
screen_height: equ 750
screen_width:  equ 750

green:      db 173, 204, 96, 255
dark_green: db 43, 51, 24, 255
box_green: db 150, 190, 80, 255
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

add_segment: dd 0
score: dd 0

running: dd 1

one: dd 1
negone: dd -1

offset: equ 75


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
    init_window(2*offset + cell_size*cell_count, 2*offset + cell_size*cell_count, title)
    set_target_fps(120)
    call RandoMizeFood
.gloop:
    window_should_close()
    cmp rax, 0
    jne .endgloop
    begin_drawing()

    is_key_pressed(32)
    cmp rax, 0
    je .endpause
    cmp dword[running], 1
    je .pause
    jmp .resume
.pause
    mov dword[running], 0
    jmp .endpause
.resume
    mov dword[running], 1
.endpause:

    cmp dword[running], 1
    jne .L4
    call EventTriggered
    cmp rax, 1
    jne .L1
    mov rdi, qword[head]
    call UpdateSnake
.L1:
    call CheckCollisionWithFood
    cmp rax, 1
    jne .L2
    inc dword[score]
    call RandoMizeFood
    mov dword[add_segment], 1
.L2:
    call CheckCollisionWithEdges
    cmp rax, 1
    jne .L3
    call GameOver
.L3:
    call CheckCollisionWithTail
    cmp rax, 1
    jne .L4
    call GameOver
.L4:
    call UpdateDirection
    clear_background(dword[green])
    draw_rectangle(offset - 5, offset -5, cell_size *cell_count +10, cell_size*cell_count+10, dword[box_green])
    call DrawFood
    mov rdi, qword[head]
    call DrawSnake
    draw_text(title, offset-5, 20, 40, dword[dark_green])
    text_fmt(dword[score])
    draw_text(rax, offset-5, offset+cell_size*cell_count+10, 40, dword[dark_green])
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
    add eax, offset
    add ecx, offset
    draw_rectangle(ecx, eax, cell_size, cell_size, 0xff0000ff)
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
    add r15d, offset
    add r14d, offset
    draw_rectangle_rounded(r15d, r14d, eax, eax, 0.5, 6, dword[dark_green])
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
    cmp rdi, 0
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
    cmp dword[add_segment], 1
    jne .L1
    mov dword[add_segment], 0
    jmp .L2
.L1:
    pop_back_snake(rdi)
.L2:
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
    is_key_pressed(KEY_UP)
    cmp rax, 1
    jne .L1
    mov dword[running], 1
    cmp dword[direction_y], -1
    je .L1
    mov dword[direction_y],1
    mov dword[direction_x],0
.L1:
    is_key_pressed(KEY_DOWN)
    cmp rax, 1
    jne .L2
    mov dword[running], 1
    cmp dword[direction_y], 1
    je .L2
    mov dword[direction_y], -1
    mov dword[direction_x], 0
.L2:
    is_key_pressed(KEY_LEFT)
    cmp rax, 1
    jne .L3
    mov dword[running], 1
    cmp dword[direction_x], 1
    je .L3
    mov dword[direction_x], -1
    mov dword[direction_y], 0

.L3:
    is_key_pressed(KEY_RIGHT)
    cmp rax, 1
    jne .L4
    mov dword[running], 1
    cmp dword[direction_x], -1
    je .L4
    mov dword[direction_x], 1
    mov dword[direction_y],0
.L4:
    end 0

CheckCollisionWithFood:
    begin
    mov rax, qword[head]
    mov eax, dword[rax+Snake.x]
    cmp eax, dword[food+Food.x]
    jne .L1
    mov rax, qword[head]
    mov eax, dword[rax+Snake.y]
    cmp eax, dword[food+Food.y]
    jne .L1
    end 1
.L1:
    end 0

RandoMizeFood:
    begin
    push r15
    push r14
.L1
    get_random_value(0, cell_count - 1)
    mov r15d, eax
    get_random_value(0, cell_count - 1)
    mov r14d, eax
    mov rdi, r15
    mov rsi, r14
    call FoodInBody
    cmp rax, 1
    je .L1
    mov dword[food+Food.x], r15d
    mov dword[food+Food.y], r14d
    pop r14
    pop r15
    end 0

FoodInBody:
    begin
    mov rax, qword[head]
.L1
    cmp dword[rax+Snake.x], edi
    jne .L3
    cmp dword[rax+Snake.y], esi
    jne .L3
    end 1
.L3:
    cmp qword[rax+Snake.nxt], 0
    je .L4
    mov rax, qword[rax+Snake.nxt]
    jmp .L1
.L4:
    end 0

CheckCollisionWithTail:
    begin
    mov rax, qword[head]
    mov edi, dword[rax+Snake.x]
    mov esi, dword[rax+Snake.y]
    mov rax, qword[rax+Snake.nxt]
.L1
    cmp dword[rax+Snake.x], edi
    jne .L3
    cmp dword[rax+Snake.y], esi
    jne .L3
    end 1
.L3:
    cmp qword[rax+Snake.nxt], 0
    je .L4
    mov rax, qword[rax+Snake.nxt]
    jmp .L1
.L4:
    end 0

CheckCollisionWithEdges:
    begin
    mov rax, qword[head]
    cmp dword[rax+Snake.x], cell_count
    je .L1
    cmp dword[rax+Snake.x], -1
    je .L1
    cmp dword[rax+Snake.y], cell_count
    je .L1
    cmp dword[rax+Snake.y], -1
    je .L1
    end 0
.L1
    end 1

ResetSnake:
    begin
    mov ecx, dword[score]
    add ecx, 3
.L1:
    push rcx
    pop_back_snake(qword[head])
    pop rcx
    loop .L1
    mov rax, qword[head]
    mov dword[rax+Snake.x], 1
    mov dword[rax+Snake.y], 1
    push_back_snake(qword[head], 1, 2)
    push_back_snake(qword[head], 1, 3)
    mov dword[direction_x], 1
    mov dword[direction_y], 0
    end 0

GameOver:
    begin
    call ResetSnake
    call RandoMizeFood
    mov dword[running], 0
    mov dword[score], 0
    end 0

section '.note.GNU-stack'

