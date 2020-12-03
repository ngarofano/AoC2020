.section __TEXT,__text
.globl _main
.align 4

;;;;;;;;;; FUNCTION START ;;;;;;;;;;
_main:
    ; FUNCTION HEADER
    stp x29, x30, [sp, #-0x10]!
    stp x19, x20, [sp, #-0x10]!
    mov x29, sp
    
    ; LOCAL VARIABLES
    mov x19, #0x0   ; tree_count

    mov x0, #0x1
    mov x1, #0x1
    bl checkSlope
    add x19, x19, x0

    mov x0, #0x3
    mov x1, #0x1
    bl checkSlope
    mul x19, x19, x0

    mov x0, #0x5
    mov x1, #0x1
    bl checkSlope
    mul x19, x19, x0

    mov x0, #0x7
    mov x1, #0x1
    bl checkSlope
    mul x19, x19, x0

    mov x0, #0x1
    mov x1, #0x2
    bl checkSlope
    mul x19, x19, x0


main_end:
    ; PRINT
    adrp x0, format@PAGE
    add x0, x0, format@PAGEOFF
    stp x19, xzr, [sp, #-0x10]!
    bl _printf
    add sp, sp, #0x10 

    ; EXIT
    mov x0, #0x0
    bl _exit

    ;FUNCTION FOOTER
    mov sp, x29
    ldp x19, x20, [sp], #0x10
    ldp x29, x30, [sp], #0x10
    ret
;;;;;;;;;; FUNCTION END ;;;;;;;;;;

;;;;;;;;;; FUNCTION START ;;;;;;;;;;
checkSlope:
; param0: uint64_t right
; param1: uint64_t down

    ; FUNCTION HEADER
    stp x29, x30, [sp, #-0x10]!
    stp x19, x20, [sp, #-0x10]!
    stp x21, x22, [sp, #-0x10]!
    stp x23, x24, [sp, #-0x10]!
    stp x25, x26, [sp, #-0x10]!
    mov x29, sp
    
    ; LOCAL VARIABLES
    sub sp, sp, #0x10
    ; [x29, #-0x8]: char* linep
    ; [x29, #-0x10]: size_t linecapp
    ; x19           ; input_filehandle
    ; x20           ; char* cleaned_line
    mov x21, #0x0   ; tree_count
    mov x22, #0x0   ; column_index
    mov x23, x0     ; right
    mov x24, x1     ; down
    mov x25, 0x0    ; row_skip_counter

    ; OPEN INPUT FILE
    adrp x0, filename@PAGE
    add x0, x0, filename@PAGEOFF
    adrp x1, filemode@PAGE
    add x1, x1, filemode@PAGEOFF
    bl _fopen
    mov x19, x0     ; FILE* input file handle

    ; MALLOC LINE BUFFER
    mov x0, #0x400
    str x0, [x29, #-0x10]
    bl _malloc
    str x0, [x29, #-0x8]

checkSlope_loop:
    ; READ LINE FROM FILE
    add x0, x29, #-0x8  ; char** linep
    add x1, x29, #-0x10     ; size_t* linecapp
    mov x2, x19     ; FILE* stream
    bl _getline
    cmp x0, #-0x1
    beq checkSlope_end

    ; CLEAN LINE INPUT
    ldr x0, [x29, #-0x8]
    bl removeNewline
    ldr x20, [x29, #-0x8]

    ; GET LINE LENGTH
    mov x0, x20
    bl _strlen
    mov x9, x0

    cmp x22, x9
    blo checkSlope_check_tree
    sub x22, x22, x9

checkSlope_check_tree:
    mov x0, x20
    mov x1, x22
    bl treeAtIndex
    add x21, x21, x0
    add x22, x22, x23

    ; SKIP LINES FROM FILE
    mov x25, x24
checkSlope_skip_line_loop:
    sub x25, x25, #0x1
    cmp x25, #0x0
    beq checkSlope_loop

    add x0, x29, #-0x8  ; char** linep
    add x1, x29, #-0x10     ; size_t* linecapp
    mov x2, x19     ; FILE* stream
    bl _getline
    cmp x0, #-0x1
    beq checkSlope_end
    b checkSlope_skip_line_loop

checkSlope_end:
    ; FREE LINE BUFFER
    ldr x0, [x29, #-0x8]
    bl _free

    ; CLOSE FILE
    mov x0, x19
    bl _fclose

    mov x0, x21

    ;FUNCTION FOOTER
    mov sp, x29
    ldp x25, x26, [sp], #0x10
    ldp x23, x24, [sp], #0x10
    ldp x21, x22, [sp], #0x10
    ldp x19, x20, [sp], #0x10
    ldp x29, x30, [sp], #0x10
    ret
;;;;;;;;;; FUNCTION END ;;;;;;;;;;

;;;;;;;;;; FUNCTION START ;;;;;;;;;;
functionTemplate:
; param0: void
    ; FUNCTION HEADER
    stp x29, x30, [sp, #-0x10]!
    mov x29, sp
    
    ; LOCAL VARIABLES
    sub sp, sp, #0x10
    ; [x29, #-0x8]: var0
    ; [x29, #-0x10]: var1

    ;FUNCTION FOOTER
    mov sp, x29
    ldp x29, x30, [sp], #0x10
    ret
;;;;;;;;;; FUNCTION END ;;;;;;;;;;

;;;;;;;;;; FUNCTION START ;;;;;;;;;;
treeAtIndex:
; param0: char* line
; param1: uint64_t index
    ; FUNCTION HEADER
    stp x29, x30, [sp, #-0x10]!
    stp x19, x20, [sp, #-0x10]!
    stp x21, x22, [sp, #-0x10]!
    mov x29, sp
    
    ; LOCAL VARIABLES
    mov x19, x0    ; line
    mov x20, x1    ; index
    mov x21, #0x0    ; treeExists

    ldrb w9, [x19, x20]
    and w9, w9, #0xFF
    cmp w9, #0x23
    bne treeAtIndex_end
    mov x21, #0x1

treeAtIndex_end:
    mov x0, x21
    ;FUNCTION FOOTER
    mov sp, x29
    ldp x21, x22, [sp], #0x10
    ldp x19, x20, [sp], #0x10
    ldp x29, x30, [sp], #0x10
    ret
;;;;;;;;;; FUNCTION END ;;;;;;;;;;

;;;;;;;;;; FUNCTION START ;;;;;;;;;;
removeNewline:
; param0: char*
    ; FUNCTION HEADER
    stp x29, x30, [sp, #-0x10]!
    mov x29, sp
    
    mov x1, #0x0A
    bl _strchr
    cmp x0, #0
    beq removeNewline_end
    strb wzr, [x0]

removeNewline_end:
    ;FUNCTION FOOTER
    mov sp, x29
    ldp x29, x30, [sp], #0x10
    ret
;;;;;;;;;; FUNCTION END ;;;;;;;;;;


.section    __DATA,__data
filename:
    .string "input"
filemode:
    .string "r"

dash:
    .string "-"
space:
    .string " "
colon:
    .string ":"

format:
    .string "Tree Count: %lld\n"
