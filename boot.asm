KERNEL_LOAD_SEG equ 0x1000
KERNEL_SECTORS  equ 4        ; small kernel for now

; Tell assembler this is a 16 bit real mode code
BITS 16
ORG 0x7C00

start:
    cli                     ; disable interrupts as they use stack

    xor ax, ax
    mov ss, ax              ; SS (stack segment register is at 0x0000)
    mov sp, 0x7C00           ; stack starts at 0x0000:0x7C00
    mov ds, ax              ; IMPORTANT: data segment must be set

    mov [boot_drive], dl    ; SAVE boot drive passed by BIOS

    sti                     ; enable interrupts

    ; do some simple print
    mov si, message
    call print_string

    ; enable A20 line
    call enable_a20

    ; load kernel into memory
    call load_kernel

.halt:
    cli
    hlt
    jmp .halt

; ============================
; Print string using BIOS
; ============================

print_string:
.print:
    lodsb                   ; AL = [DS:SI], SI++
    or al, al               ; check for null terminator
    jz .done
    mov ah, 0x0E            ; BIOS teletype output
    int 0x10
    jmp .print
.done:
    ret

; ============================
; Enable A20 Line (Fast Method)
; ============================

enable_a20:
    in al, 0x92
    or al, 00000010b
    out 0x92, al
    ret

; ============================
; Load kernel from disk using BIOS
; ============================

load_kernel:
    push es                 ; preserve ES

    ; RESET DISK SYSTEM (MANDATORY)
    mov ah, 0x00
    mov dl, [boot_drive]
    int 0x13

    mov ax, KERNEL_LOAD_SEG
    mov es, ax
    xor bx, bx              ; ES:BX = 0x10000 (64 KB)

    mov ah, 0x02            ; BIOS read sectors (CHS)
    mov al, KERNEL_SECTORS  ; number of sectors
    mov ch, 0x00            ; cylinder 0
    mov cl, 0x02            ; sector 2 (boot sector is sector 1)
    mov dh, 0x00            ; head 0
    mov dl, [boot_drive]    ; correct boot drive

    int 0x13
    jc disk_error           ; if CF set → error

    pop es
    ret

disk_error:
    mov si, disk_err_msg
    call print_string
.hang:
    cli
    hlt
    jmp .hang

; ============================
; Data
; ============================

boot_drive:
    db 0

disk_err_msg:
    db "Disk read error!", 0

message:
    db "Bootloader running!", 0

; ============================
; Boot signature
; ============================

times 510 - ($ - $$) db 0
dw 0xAA55
