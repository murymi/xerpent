%include "help.asm"

section .data
title: db "snake", 0
food_image_path: db "./apple.png", 0
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

section .text
global _start
_start:
    init_window(cell_size*cell_count, cell_size*cell_count, title)
    set_target_fps(60)

    load_image(food_image_path, food_image)
    load_texture_from_image(food_image, food_texture)

    ;unload_image(food_image)

.gloop:

    window_should_close()
    cmp rax, 0
    jne .endgloop
    begin_drawing()

    clear_background(dword[green])

    call DrawFood

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
    ;draw_rectangle(ecx, eax, cell_size, cell_size, dword[dark_green])
    draw_texture(food_texture, ecx, eax, 0xffffffff)
    end 0

section '.note.GNU-stack'

