.section __TEXT,__text
.globl _main
.align 4

;;;;;;;;;; FUNCTION START ;;;;;;;;;;
_main:
    ; FUNCTION HEADER
    stp x29, x30, [sp, #-0x10]!
    stp x19, x20, [sp, #-0x10]!
    stp x21, x22, [sp, #-0x10]!
    mov x29, sp
    
    ; LOCAL VARIABLES
    sub sp, sp, #0x10
    ; [x29, #-0x8]: char* linep
    ; [x29, #-0x10]: size_t linecapp
    ; x19           ; input_filehandle
    ; x20           ; char* cleaned_line
    mov x21, #0x0   ; valid_password_count

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

main_loop:
    ; READ LINE FROM FILE
    add x0, x29, #-0x8  ; char** linep
    add x1, x29, #-0x10     ; size_t* linecapp
    mov x2, x19     ; FILE* stream
    bl _getline
    cmp x0, #-0x1
    beq main_end

    ; CLEAN LINE INPUT
    ldr x0, [x29, #-0x8]
    bl removeNewline
    ldr x20, [x29, #-0x8]

    ; VALIDATE PASSWORD
    mov x0, x20
    bl validatePassword
    add x21, x21, x0

    b main_loop

main_end:
    ; PRINT
    adrp x0, format@PAGE
    add x0, x0, format@PAGEOFF
    stp x21, xzr, [sp, #-0x10]!
    bl _printf
    add sp, sp, #0x10 

    ; FREE LINE BUFFER
    ldr x0, [x29, #-0x8]
    bl _free

    ; CLOSE FILE
    mov x0, x19
    bl _fclose

    ; EXIT
    mov x0, #0x0
    bl _exit

    ;FUNCTION FOOTER
    mov sp, x29
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
charCount:
; param0: char* string
; param0: char char
    ; FUNCTION HEADER
    stp x29, x30, [sp, #-0x10]!
    stp x19, x20, [sp, #-0x10]!
    stp x21, x22, [sp, #-0x10]!
    mov x29, sp
    
    ; LOCAL VARIABLES
    mov x19, x0     ; string
    and w20, w1, #0xFF  ; char_to_count
    mov x21, #0x0   ; count 
    mov x22, #0x0   ; index

charCount_loop:
    ldrb w9, [x19, x22]
    and w9, w9, #0xFF
    cmp w9, #0x0
    beq charCount_end
    cmp w9, w20
    bne charCount_continue
    add x21, x21, #0x1

charCount_continue:
    add x22, x22, #0x1
    b charCount_loop

charCount_end:
    mov x0, x21

    ;FUNCTION FOOTER
    mov sp, x29
    ldp x21, x22, [sp], #0x10
    ldp x19, x20, [sp], #0x10
    ldp x29, x30, [sp], #0x10
    ret
;;;;;;;;;; FUNCTION END ;;;;;;;;;;

;;;;;;;;;; FUNCTION START ;;;;;;;;;;
validatePassword:
; param0: char* pw_line
    ; FUNCTION HEADER
    stp x29, x30, [sp, #-0x10]!
    stp x19, x20, [sp, #-0x10]!
    stp x21, x22, [sp, #-0x10]!
    stp x23, x24, [sp, #-0x10]!
    mov x29, sp
    
    ; LOCAL VARIABLES
    mov x19, x0    ; char* pw_line
    ; x20          ; index0
    ; x21          ; index1
    ; x22          ; char_requirement 
    ; x23          ; password

    ; GET INDEX0 REQUIREMENT
    mov x0, x19
    adrp x1, dash@PAGE
    add x1, x1, dash@PAGEOFF
    bl _strtok
    bl _atoi
    mov x20, x0

    ; GET INDEX1 REQUIREMENT
    mov x0, #0x0
    adrp x1, space@PAGE
    add x1, x1, space@PAGEOFF
    bl _strtok
    bl _atoi
    mov x21, x0

    ; GET CHAR REQUIREMENT
    mov x0, #0x0
    adrp x1, colon@PAGE
    add x1, x1, colon@PAGEOFF
    bl _strtok
    ldrb w22, [x0]
    and w22, w22, #0xFF

    ; GET PASSWORD
    mov x0, #0x0
    adrp x1, space@PAGE
    add x1, x1, space@PAGEOFF
    bl _strtok
    mov x23, x0

    sub x9, x20, #0x1
    ldrb w10, [x23, x9]
    and w10, w10, #0xFF

    sub x9, x21, #0x1
    ldrb w11, [x23, x9]
    and w11, w11, #0xFF  

    eor w12, w10, w11
    eor w12, w12, w22

    cmp w12, w22
    beq validatePassword_fail
    cmp w12, w10
    beq validatePassword_pass
    cmp w12, w11
    beq validatePassword_pass
    b validatePassword_fail

validatePassword_fail:
    mov x0, #0x0
    b validatePassword_end

validatePassword_pass:
    mov x0, #0x1
    b validatePassword_end

validatePassword_end:
    ;FUNCTION FOOTER
    mov sp, x29
    ldp x23, x24, [sp], #0x10
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
    .string "Valid Password Count: %d\n"


