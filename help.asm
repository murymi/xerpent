section .data

struc Food
    .x:          resd  1
    .y:          resd  1
endstruc

struc Snake
    .x:         resd 1
    .y:         resd 1
    .nxt:       resq 1
endstruc


%macro __syscall 1
    push r11
    push rcx
    mov rax,  %1
    syscall
    pop rcx
    pop r11
%endmacro

%define syscall(num) __syscall num

%macro __exit 1
    mov rdi,    %1
    call exit
%endmacro sys_exit

%define sys_exit(status) __exit status

%macro __div_i32 2
    mov eax, %1
    cdq
    sub rsp, 4
    mov dword [rsp], %2
    idiv dword [rsp]
    add rsp, 4
%endmacro

%define div_i32(a, b) __div_i32 a, b

%macro begin 0
    push rbp
    mov rbp, rsp
%endmacro

%macro __stack_pop 0
    mov rsp, rbp
    pop rbp
    ret
%endmacro

%macro end 1
    mov rax, %1
    __stack_pop
%endmacro

%macro __mul_i32 2
    mov eax, %1
    imul rax, %2
%endmacro

%define mul_i32(a, b) __mul_i32 a, b

%macro __init_window 3
    mov rdi, %1
    mov rsi, %2
    mov rdx, %3
    call InitWindow
%endmacro

%macro __close_window 0
    call CloseWindow
%endmacro

%macro __window_should_close 0
    call WindowShouldClose
%endmacro

%macro __set_target_fps 1
    mov rdi, %1
    call SetTargetFPS
%endmacro

%macro __begin_drawing 0
    call BeginDrawing
%endmacro

%macro __end_drawing 0
    call EndDrawing
%endmacro

%macro __draw_circle 4
    mov edi, %1
    mov esi, %2
    mov eax, %3
    cvtsi2ss xmm0, eax
    mov edx, %4
    call DrawCircle
%endmacro

%macro __draw_rect 5
    mov edi, %1
    mov esi, %2
    mov edx, %3
    mov ecx, %4
    mov r8d, %5
    call DrawRectangle
%endmacro

%macro __clear_bg 1
    mov edi, %1
    call ClearBackground
%endmacro

%macro __draw_line 5
    mov rdi, %1
    mov rsi, %2
    mov rdx, %3
    mov rcx, %4
    mov r8,  %5
    call DrawLine
%endmacro

%macro __is_key_down 1
    mov rdi, %1
    call IsKeyDown
%endmacro

%macro __check_colCR 7
    sub    rsp,32

    ;; rectangle
    cvtsi2ss  xmm0, %4
    movss  dword [rsp+16], xmm0
    cvtsi2ss  xmm0, %5
    movss  dword [rsp+20],xmm0
    cvtsi2ss  xmm0, %6
    movss  dword [rsp+24],xmm0
    cvtsi2ss  xmm0, %7
    movss  dword [rsp+28],xmm0

    pxor xmm0, xmm0

    ;; vector
    cvtsi2ss xmm0, %1
    movss dword[rsp+8], xmm0
    cvtsi2ss xmm0, %2
    movss dword[rsp+12], xmm0

    ;; radius
    cvtsi2ss xmm1, %3

    ;; arrange
    movq xmm0, qword[rsp+8]
    movq xmm2, qword[rsp+16]
    movq xmm3, qword[rsp+24]

    add rsp, 32

    call CheckCollisionCircleRec
%endmacro

%macro __draw_text 5
    mov rdi, %1
    mov rsi, %2
    mov rdx, %3
    mov rcx, %4
    mov r8,  %5
    call DrawText
%endmacro

txt_fmt: db "%i", 0
%macro __text_fmt 1
    mov rdi, txt_fmt
    mov esi, %1
    call TextFormat
%endmacro

%macro __load_image 2
    mov rdi, %2
    mov rsi, %1
    call LoadImage
%endmacro

%macro __load_texture_from_image 2
    mov rdi, %2
    sub rsp, 8
    push qword[%1+16]
    push qword[%1+8]
    push qword[%1]
    ;sub rsp, 
    ;mov rsi, %1
    call LoadTextureFromImage

    add rsp, 32

%endmacro

%macro __unload_image 1
    push 0;qword[%1+16]
    push 0;qword[%1+8]
    push 0;qword[%1]
    call UnloadImage
    add rsp, 24
%endmacro

%macro __draw_texture 4
    sub rsp, 32

    mov edi, %2
    mov esi, %3
    mov edx, %4

    mov rax, qword[%1]
    mov qword[rsp], rax


    mov rax, qword[%1+8]
    mov qword[rsp+8], rax


    mov eax, dword[%1+16]
    mov dword[rsp+16], eax

    call DrawTexture
    add rsp, 32
%endmacro

%macro __get_random_value 2
    mov rdi, %1
    mov rsi, %2
    call GetRandomValue
%endmacro

%macro __mem_alloc 1
    mov rdi, %1
    call MemAlloc
%endmacro

%macro __mem_free 1
    mov rdi, %1
    call MemFree
%endmacro

%macro __draw_rec_round 7
    sub rsp, 32

    cvtsi2ss xmm0, %1 ;x
    movss dword[rsp], xmm0

    cvtsi2ss xmm0, %2 ;y
    movss dword[rsp+4], xmm0

    cvtsi2ss xmm0, %3 ;width
    movss dword[rsp+8], xmm0

    cvtsi2ss xmm0, %4 ; height
    movss dword[rsp+12], xmm0

    movq xmm0, qword[rsp]
    movq xmm1, qword[rsp+8]

    section .data
    %%fuck: dd %5
    section .text
    movss xmm2, dword[%%fuck]

    mov edi, %6
    mov esi, %7
    call DrawRectangleRounded
    add rsp, 32
%endmacro

%define void 0
%define KEY_DOWN 265
%define KEY_UP 264

%define init_window(a, b, c)        __init_window a, b, c
%define close_window(a)             __close_window
%define window_should_close(a)      __window_should_close
%define set_target_fps(a)           __set_target_fps a
%define begin_drawing(a)            __begin_drawing
%define end_drawing(a)              __end_drawing
%define draw_circle(a, b, c, d)     __draw_circle a, b, c, d
%define draw_rectangle(a,b,c,d,e)   __draw_rect a, b, c, d, e
%define clear_background(a)         __clear_bg a
%define draw_line(a,b,c,d,e)        __draw_line a, b, c, d, e
%define is_key_down(a)              __is_key_down a
%define check_collision_circle_rec(a,b,c,d,e,f,g) __check_colCR a,b,c,d,e,f,g
%define draw_text(a, b, c, d, e)       __draw_text a, b, c, d, e
%define text_fmt(a)                 __text_fmt a
%define load_image(a, b)            __load_image a, b
%define load_texture_from_image(a, b)     __load_texture_from_image a, b
%define unload_image(a)             __unload_image a
%define draw_texture(a, b, c ,d)    __draw_texture a, b, c, d
%define get_random_value(a, b)      __get_random_value a, b
%define mem_alloc(a)                __mem_alloc a
%define mem_free(a)                 __mem_free a
%define draw_rectangle_rounded(a,b,c,d,e,f,g) __draw_rec_round a,b,c,d,e,f,g

extern InitWindow
extern CloseWindow
extern WindowShouldClose
extern exit
extern SetTargetFPS
extern BeginDrawing
extern EndDrawing
extern DrawCircle
extern DrawRectangle
extern ClearBackground
extern DrawLine
extern IsKeyDown
extern CheckCollisionCircleRec
extern DrawText
extern TextFormat
extern LoadImage
extern LoadTextureFromImage
extern UnloadImage
extern DrawTexture
extern GetRandomValue
extern MemAlloc
extern MemFree
extern DrawRectangleRounded

;If the size of the structure, in bytes, is ≤ 8, 
;then the the entire structure 
;is packed into a single 64-bit register and passed through it. 

;01234567 89ABCDEF 01234567 89ABCDEF

;FEDCBA98 76543210 FEDCBA98 76543210

;00 01 11 10
;0   1  3  2

;3210FEDC FEDCBA98 76543210 01234567