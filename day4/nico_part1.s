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
    ; x19           ; int input_filehandle
    ; x20           ; char* entry
    mov x21, #0x0   ; valid_entry_count

    ; OPEN INPUT FILE
    adrp x0, filename@PAGE
    add x0, x0, filename@PAGEOFF
    adrp x1, filemode@PAGE
    add x1, x1, filemode@PAGEOFF
    bl _fopen
    mov x19, x0     ; FILE* input file handle

    ; MALLOC ENTRY BUFFER
    mov x0, #0x400
    bl _malloc
    mov x20, x0

main_loop:
    ; CONSTRUCT SINGLE ENTRY FROM FILE
    mov x0, x20     ; entry
    mov x1, x19     ; stream
    bl getSingleEntry
    ldrb w9, [x20]
    and w9, w9, #0xFF
    cmp w9, #0x0
    beq main_end

    mov x0, x20
    bl validateEntry
    add x21, x21, x0

    b main_loop

main_end:
    ; PRINT
    adrp x0, format@PAGE
    add x0, x0, format@PAGEOFF
    stp x21, xzr, [sp, #-0x10]!
    bl _printf
    add sp, sp, #0x10 

    ; FREE ENTRY BUFFER
    mov x0, x20
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
getSingleEntry:
; param0: char* result_entry
; param1: int file_handle
    ; FUNCTION HEADER
    stp x29, x30, [sp, #-0x10]!
    stp x19, x20, [sp, #-0x10]!
    mov x29, sp
    
    ; LOCAL VARIABLES
    sub sp, sp, #0x10
    ; [x29, #-0x8]: char* linep
    ; [x29, #-0x10]: size_t linecapp
    mov x19, x0     ; result_entry
    mov x20, x1     ; file_handle

    ; CLEAR RESULT ENTRY 
    strb wzr, [x19]

    ; MALLOC LINE BUFFER
    mov x0, #0x400
    str x0, [x29, #-0x10]
    bl _malloc
    str x0, [x29, #-0x8]

getSingleEntry_loop:
    ; READ LINE FROM FILE
    add x0, x29, #-0x8  ; linep
    add x1, x29, #-0x10     ; sinecapp
    mov x2, x20     ; file_handle
    bl _getline
    cmp x0, #-0x1
    beq getSingleEntry_end

    ; CLEAN LINE INPUT
    ldr x0, [x29, #-0x8]
    bl removeNewline
    ldr x9, [x29, #-0x8]

    ; CHECK FOR END OF ENTRY
    ldrb w10, [x9]
    and w10, w10, #0xFF
    cmp w10, #0x0
    beq getSingleEntry_end

    ; CONCATENATE LINE TO ENTRY RESULT
    mov x0, x19
    mov x1, x9
    bl _strcat
    mov x0, x19
    adrp x1, space@PAGE
    add x1, x1, space@PAGEOFF
    bl _strcat

    b getSingleEntry_loop

getSingleEntry_end:
    ; FREE LINE BUFFER
    ldr x0, [x29, #-0x8]
    bl _free

    ;FUNCTION FOOTER
    mov sp, x29
    ldp x19, x20, [sp], #0x10
    ldp x29, x30, [sp], #0x10
    ret
;;;;;;;;;; FUNCTION END ;;;;;;;;;;

;;;;;;;;;; FUNCTION START ;;;;;;;;;;
validateEntry:
; param0: char* entry
    ; FUNCTION HEADER
    stp x29, x30, [sp, #-0x10]!
    stp x19, x20, [sp, #-0x10]!
    stp x21, x22, [sp, #-0x10]!
    mov x29, sp
    
    ; LOCAL VARIABLES
    mov x19, x0     ; entry
    mov x20, #0x0   ; valid
    ; x21           ; field
    mov x22, #0x0   ; field_index

    adrp x21, fields@PAGE
    add x21, x21, fields@PAGEOFF

validateEntry_loop:
    lsl x9, x22, #0x2
    add x1, x21, x9
    mov x0, x19
    bl _strstr
    cmp x0, #0x0
    beq validateEntry_end

    add x22, x22, #0x1
    cmp x22, #0x7
    blo validateEntry_loop

    mov x20, #0x1

validateEntry_end:
    mov x0, x20

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

space:
    .string " "

fields:
byr: 
    .string "byr"
iyr: 
    .string "iyr"
eyr: 
    .string "eyr"
hgt: 
    .string "hgt"
hcl: 
    .string "hcl"
ecl: 
    .string "ecl"
pid: 
    .string "pid"

format:
    .string "Valid Entry Count: %d\n"
format_ve:
    .string "Entry: |%s| Field: |%s|\n"


