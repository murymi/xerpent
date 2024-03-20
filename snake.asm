%include "help.asm"

section .data
title: db "snake", 0
food_image_path: db "./screen.png", 0
screen_height: equ 750
screen_width:  equ 750

green:      db 173, 204, 96, 255
dark_green: db 43, 51, 24, 255

cell_size:  equ 25
cell_count: equ 25

food: istruc Food 
    at Food.x, dd 5
    at Food.y, dd 6
iend 


section .bss
food_image:   resd 6
food_texture: resd 5 
head: resq 1

section .text
global _start
_start:
    init_window(cell_size*cell_count, cell_size*cell_count, title)
    set_target_fps(60)

    ;load_image(food_image_path, food_image)
    ;load_texture_from_image(food_image, food_texture)

    ;unload_image(food_image)
    get_random_value(0, cell_count - 1)
    mov dword[food+Food.x], eax
    get_random_value(0, cell_count - 1)
    mov dword[food+Food.y], eax

    call InitSnake

.gloop:

    window_should_close()
    cmp rax, 0
    jne .endgloop
    begin_drawing()

    clear_background(dword[green])

    call DrawFood

    call DrawSnake

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

InitSnake:
    begin
    mov rcx, 3
    sub rsp, 8
    mov qword[rsp], head
.L1:
    push rcx
    mem_alloc(Snake_size)
    pop rcx

    mov rdx, qword[rsp]
    mov qword[rdx], rax

    mov dword[rax+Snake.x], ecx
    mov dword[rax+Snake.y], 9
    mov qword[rax+Snake.nxt], 0

    lea rdx, qword[rax+Snake.nxt]

    ;mov r15d, dword[rax+Snake.x]
    ;mov r15d, dword[rax+Snake.y]
    ;mov r15, qword[rax+Snake.nxt]

    mov qword[rsp], rdx

    loop .L1
    end 0

DrawSnake:
    begin
    mov rcx, qword[head]
    push r15
    push r14

    ;mov r15d, dword[rcx+Snake.x]
    ;mov r15d, dword[rcx+Snake.y]
    ;mov r15, qword[rcx+Snake.nxt]
.L1:

    mov r15d, dword[rcx+Snake.x]
    mov r15d, dword[rcx+Snake.y]
    mov r15, qword[rcx+Snake.nxt]
    

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
    end 0

section '.note.GNU-stack'

