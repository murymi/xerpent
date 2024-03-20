%include "help.asm"

section .data
title: db "snake", 0
screen_height: equ 750
screen_width:  equ 750

section .text
global _start
_start:
    init_window(screen_width, screen_height, title)
    set_target_fps(60)

.gloop:

    window_should_close()
    cmp rax, 0
    jne .endgloop
    begin_drawing()

    end_drawing()
    jmp .gloop

.endgloop:
    close_window()
    sys_exit(0)

section '.note.GNU-stack'

