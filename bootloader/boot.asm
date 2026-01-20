KERNEL_LOAD_SEG equ 0x1000
KERNEL_LOAD_OFF equ 0x0000
KERNEL_SECTORS  equ 4        ; small kernel for now

; Segment selectors (after GDT is loaded)
CODE_SEG equ 0x08    ; Index 1 in GDT (Kernel Code)
DATA_SEG equ 0x10    ; Index 2 in GDT (Kernel Data)

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

    ; setup GDT and switch to protected mode
    call setup_gdt
    call switch_to_protected_mode

    ; This should never be reached (we jump to protected mode)
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
    push ax                 ; preserve AX

    ; RESET DISK SYSTEM (MANDATORY)
    mov ah, 0x00
    mov dl, [boot_drive]
    int 0x13
    jc disk_error           ; if reset fails, error

    ; Set up destination segment:offset
    mov ax, KERNEL_LOAD_SEG
    mov es, ax
    xor bx, bx              ; ES:BX = 0x10000 (64 KB)

    ; Read sectors using CHS addressing
    mov ah, 0x02            ; BIOS read sectors function
    mov al, KERNEL_SECTORS  ; number of sectors to read
    mov ch, 0x00            ; cylinder 0
    mov cl, 0x02            ; sector 2 (boot sector is sector 1)
    mov dh, 0x00            ; head 0
    mov dl, [boot_drive]    ; drive number

    int 0x13
    jc disk_error           ; if CF set → error

    ; Verify that we read the expected number of sectors
    cmp al, KERNEL_SECTORS
    jne disk_error          ; if AL != expected sectors → error

    pop ax                  ; restore AX
    pop es                  ; restore ES
    ret

disk_error:
    mov si, disk_err_msg
    call print_string
.hang:
    cli
    hlt
    jmp .hang

; ============================
; Setup GDT (Global Descriptor Table)
; ============================

setup_gdt:
    cli                     ; Disable interrupts during setup
    lgdt [gdt_descriptor]   ; Load GDT pointer into GDTR register
    ret

; ============================
; Switch to Protected Mode
; ============================

switch_to_protected_mode:
    ; Enable protected mode by setting bit 0 of CR0
    mov eax, cr0
    or eax, 1               ; Set PE (Protection Enable) bit
    mov cr0, eax

    ; Far jump to 32-bit code segment to flush pipeline
    ; This is CRITICAL - CPU needs to know we're in 32-bit mode
    jmp CODE_SEG:protected_mode_start

; ============================
; Protected Mode Entry (32-bit code)
; ============================

BITS 32

protected_mode_start:
    ; Reload all segment registers with data segment selector
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; Setup stack pointer (grows downward from high memory)
    mov esp, 0x90000        ; Stack at 576 KB (safe area)

    ; Jump to kernel entry point
    ; Kernel is loaded at 0x10000 (flat address in protected mode)
    ; In flat memory model, we can jump directly to the address
    mov eax, 0x10000
    jmp eax                 ; Jump to kernel

    ; If kernel returns (shouldn't happen), halt
.halt:
    cli
    hlt
    jmp .halt

; ============================
; GDT (Global Descriptor Table)
; ============================

BITS 16

gdt_start:
    ; NULL Descriptor (required - must be first)
    ; All zeros
    dd 0x00000000
    dd 0x00000000

    ; Kernel Code Segment (Index 1)
    ; Base: 0x00000000, Limit: 0xFFFFFFFF
    ; Access: Present, Ring 0, Code, Readable
    ; Flags: 4KB granularity, 32-bit mode
    dw 0xFFFF       ; Limit (bits 0-15)
    dw 0x0000       ; Base (bits 0-15)
    db 0x00         ; Base (bits 16-23)
    db 0x9A         ; Access byte: Present(1) + DPL(00) + Code(1) + Readable(1)
    db 0xCF         ; Flags: Granularity(1) + 32-bit(1) + Limit (bits 16-19 = 0xF)
    db 0x00         ; Base (bits 24-31)

    ; Kernel Data Segment (Index 2)
    ; Base: 0x00000000, Limit: 0xFFFFFFFF
    ; Access: Present, Ring 0, Data, Writable
    ; Flags: 4KB granularity, 32-bit mode
    dw 0xFFFF       ; Limit (bits 0-15)
    dw 0x0000       ; Base (bits 0-15)
    db 0x00         ; Base (bits 16-23)
    db 0x92         ; Access byte: Present(1) + DPL(00) + Data(0) + Writable(1)
    db 0xCF         ; Flags: Granularity(1) + 32-bit(1) + Limit (bits 16-19 = 0xF)
    db 0x00         ; Base (bits 24-31)

gdt_end:

; GDT Descriptor (pointer structure for LGDT instruction)
gdt_descriptor:
    dw gdt_end - gdt_start - 1  ; Size of GDT - 1 (CPU quirk)
    dd gdt_start                 ; Physical address of GDT

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
