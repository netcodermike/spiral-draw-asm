bits 16
cpu 8086
org 100h

SCREEN_WIDTH   equ 320
SCREEN_HEIGHT  equ 200
VIDEO_SEGMENT  equ 0A000h
CENTER_OFFSET  equ (SCREEN_HEIGHT / 2) * SCREEN_WIDTH + SCREEN_WIDTH / 2
LEG_INCREMENT  equ 4
LEG_COUNT      equ 96
DOTS_PER_FRAME equ 32
FIRST_COLOR    equ 32
COLOR_COUNT    equ 6

start:
    mov ax, 0013h
    int 10h
    push cs
    pop ds
    mov ax, VIDEO_SEGMENT
    mov es, ax
    cld
    call set_palette

.restart:
    xor ax, ax
    xor di, di
    mov cx, SCREEN_WIDTH * SCREEN_HEIGHT / 2
    rep stosw

    mov di, CENTER_OFFSET
    xor si, si
    mov word [leg_length], LEG_INCREMENT
    mov word [moves_left], LEG_INCREMENT
    mov byte [legs_left], LEG_COUNT
    mov byte [color], FIRST_COLOR
    mov byte [es:di], FIRST_COLOR

.frame:
    call wait_retrace
    call read_key
    cmp al, 27
    je .exit
    cmp al, ' '
    je .restart
    cmp byte [legs_left], 0
    je .frame
    mov cx, DOTS_PER_FRAME

.draw_dot:
    ; SI is a byte offset into the four word-sized movement offsets.
    add di, [directions + si]
    mov al, [color]
    mov [es:di], al
    dec word [moves_left]
    jnz .next_dot
    dec byte [legs_left]
    jz .frame

    ; The existing corner keeps its color. The next move starts the new leg.
    add si, 2
    and si, 6
    test si, 2
    jnz .same_length
    add word [leg_length], LEG_INCREMENT
.same_length:
    mov ax, [leg_length]
    mov [moves_left], ax
    inc byte [color]
    cmp byte [color], FIRST_COLOR + COLOR_COUNT
    jb .next_dot
    mov byte [color], FIRST_COLOR
.next_dot:
    loop .draw_dot
    jmp .frame

.exit:
    mov ax, 0003h
    int 10h
    mov ax, 4C00h
    int 21h

set_palette:
    mov dx, 03C8h
    mov al, FIRST_COLOR
    out dx, al
    inc dx
    mov si, palette
    mov cx, COLOR_COUNT * 3
.component:
    lodsb
    out dx, al
    loop .component
    ret

wait_retrace:
    ; Leave the current retrace before waiting for the next one.
    mov dx, 03DAh
.end:
    in al, dx
    test al, 8
    jnz .end
.start:
    in al, dx
    test al, 8
    jz .start
    ret

read_key:
    mov ah, 01h
    int 16h
    jz .none
    xor ah, ah
    int 16h
    ret
.none:
    xor al, al
    ret

directions dw 1, SCREEN_WIDTH, -1, -SCREEN_WIDTH
palette db 26, 59, 61, 27, 47, 63, 39, 34, 63
        db 60, 34, 55, 63, 44, 28, 63, 57, 29

leg_length dw 0
moves_left dw 0
legs_left db 0
color db 0
