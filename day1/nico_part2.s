.section __TEXT,__text
.globl _main
.align 4

;;;;;;;;;; FUNCTION START ;;;;;;;;;;
_main:
    ; FUNCTION HEADER
    stp x29, x30, [sp, #-0x10]!
    stp x19, x20, [sp, #-0x10]!
    mov x29, sp
    
    ; GET LINE COUNT FROM FILE
    adrp x0, filename@PAGE
    add x0, x0, filename@PAGEOFF
    bl getFileLinesCount
    mov x19, x0     ; uint64_t line_count

    ; MALLOC ARRAY
    mov x0, x19
    lsl x0, x0, #0x3
    bl _malloc
    mov x20, x0     ; uint64_t* array

    ; CREATE ARRAY FROM FILE
    adrp x0, filename@PAGE
    add x0, x0, filename@PAGEOFF
    mov x1, x20
    mov x2, x19
    bl populateArrayWithFile

    ; FIND PAIR IN ARRAY
    mov x0, x20
    mov x1, x19
    mov x2, #2020
    bl findTripleInArray
    mov x9, x0

    adrp x0, format@PAGE
    add x0, x0, format@PAGEOFF
    stp x9, xzr, [sp, #-0x10]!
    bl _printf
    add sp, sp, #0x10

    ; FREE LINE BUFFER
    mov x0, x20
    bl _free

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
findTripleInArray:
; param0: uint64_t* array
; param1: uint64_t array_item_count
; param2: uint64_t sum_qualification
    ; FUNCTION HEADER
    stp x29, x30, [sp, #-0x10]!
    stp x19, x20, [sp, #-0x10]!
    stp x21, x22, [sp, #-0x10]!
    stp x23, x24, [sp, #-0x10]!
    stp x25, x26, [sp, #-0x10]!
    mov x29, sp
    
    ; LOCAL VARIABLES
    mov x19, x0     ; uint64_t* array
    mov x20, x1     ; uint64_t array_item_count
    mov x21, x2     ; uint64_t sum_qualification
    mov x22, #0x0   ; uint64_t array_index
    ; x23           ; uint64_t remaining_value
    ; x24           ; uint64_t current_value
    mov x25, #0x0   ; uint64_t return_product
    ; x26           ; uint64_t* array_copy

    ; COPY ARRAY
    lsl x0, x20, #0x3
    bl _malloc
    mov x26, x0
    mov x1, x19
    lsl x2, x20, #0x3
    bl _memcpy

findTripleInArray_loop:
    lsl x9, x22, #0x3 
    ldr x24, [x19, x9]
    sub x23, x21, x24

    ;CHECK FOR TRIPLE
    add x10, x21, #0x1
    str x10, [x26, x9]
    mov x0, x26
    mov x1, x20
    mov x2, x23
    bl findPairInArray
    cmp x0, #0x0
    bne findTripleInArray_found
    lsl x9, x22, #0x3 
    str x24, [x26, x9]
    add x22, x22, #0x1
    sub x11, x20, #0x1
    cmp x22, x11
    bge findTripleInArray_end
    b findTripleInArray_loop

findTripleInArray_found:
    mul x25, x24, x0

findTripleInArray_end:
    mov x0, x25
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
findPairInArray:
; param0: uint64_t* array
; param1: uint64_t array_item_count
; param2: uint64_t sum_qualification
    ; FUNCTION HEADER
    stp x29, x30, [sp, #-0x10]!
    stp x19, x20, [sp, #-0x10]!
    stp x21, x22, [sp, #-0x10]!
    stp x23, x24, [sp, #-0x10]!
    stp x25, x26, [sp, #-0x10]!
    mov x29, sp
    
    ; LOCAL VARIABLES
    mov x19, x0     ; uint64_t* array
    mov x20, x1     ; uint64_t array_item_count
    mov x21, #0x0   ; uint64_t array_index
    mov x22, x2  ; uint64_t sum_qualification
    ; x23           ; uint64_t paired_value
    ; x24           ; uint64_t paired_value
    mov x25, #0x0    ; uint64_t return_product

findPairInArray_loop:
    lsl x9, x21, #0x3 
    ldr x24, [x19, x9]
    sub x23, x22, x24

    ;CHECK FOR PAIR
    add x9, x21, #0x1
    lsl x10, x9, #0x3
    add x0, x19, x10
    sub x1, x20, x9
    mov x2, x23
    bl existsInArray
    cmp x0, #0x1
    beq findPairInArray_found
    add x21, x21, #0x1
    sub x11, x20, #0x1
    cmp x21, x11
    bge findPairInArray_end
    b findPairInArray_loop

findPairInArray_found:
    mul x25, x24, x23

findPairInArray_end:
    mov x0, x25
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
existsInArray:
; param0: uint64_t* array
; param1: uint64_t array_item_count
; param2: uint64_t value
    ; FUNCTION HEADER
    stp x29, x30, [sp, #-0x10]!
    stp x19, x20, [sp, #-0x10]!
    stp x21, x22, [sp, #-0x10]!
    stp x23, x24, [sp, #-0x10]!
    mov x29, sp
    
    ; LOCAL VARIABLES
    mov x19, x0     ; uint64_t* array
    mov x20, x1     ; uint64_t array_item_count
    mov x21, x2     ; uint64_t value
    mov x22, #0x0   ; uint64_t array_index
    mov x23, #0x0   ; bool exists

existsInArray_loop:
    lsl x9, x22, #0x3 
    ldr x10, [x19, x9]

    cmp x10, x21
    beq existsInArray_exists

    add x22, x22, #0x1
    cmp x22, x20
    bge existsInArray_end
    b existsInArray_loop

existsInArray_exists:
    mov x23, #0x1

existsInArray_end:
    mov x0, x23

    ;FUNCTION FOOTER
    mov sp, x29
    ldp x23, x24, [sp], #0x10
    ldp x21, x22, [sp], #0x10
    ldp x19, x20, [sp], #0x10
    ldp x29, x30, [sp], #0x10
    ret
;;;;;;;;;; FUNCTION END ;;;;;;;;;;

;;;;;;;;;; FUNCTION START ;;;;;;;;;;
populateArrayWithFile:
; param0: char* filename
; param0: uint64_t* array
; param0: uint64_t array_item_count
    ; FUNCTION HEADER
    stp x29, x30, [sp, #-0x10]!
    stp x19, x20, [sp, #-0x10]!
    stp x21, x22, [sp, #-0x10]!
    mov x29, sp
    
    ; LOCAL VARIABLES
    sub sp, sp, #0x10
    ; [x29, #-0x8]: char* linep
    ; [x29, #-0x10]: size_t linecapp
    mov x20, x1     ; uint64_t* array
    mov x21, x2     ; uint64_t array_item_count
    mov x22, #0x0   ; uint64_t array_index

    ; OPEN INPUT FILE
    adrp x1, filemode@PAGE
    add x1, x1, filemode@PAGEOFF
    bl _fopen
    mov x19, x0     ; FILE* input file handle

    ; MALLOC LINE BUFFER
    mov x0, #0x400
    str x0, [x29, #-0x10]
    bl _malloc
    str x0, [x29, #-0x8]

populateArrayWithFile_loop:
    ; READ LINE FROM FILE
    add x0, x29, #-0x8  ; char** linep
    add x1, x29, #-0x10     ; size_t* linecapp
    mov x2, x19     ; FILE* stream
    bl _getline
    cmp x0, #-0x1
    beq populateArrayWithFile_end
    cmp x22, x21
    bge populateArrayWithFile_end

    ; CLEAN INPUT
    ldr x0, [x29, #-0x8]
    bl remove_newline
    ldr x0, [x29, #-0x8]
    bl _atoi
    lsl x9, x22, #0x3
    str x0, [x20, x9]
    add x22, x22, #0x1
    b populateArrayWithFile_loop

populateArrayWithFile_end:    
    ; FREE LINE BUFFER
    ldr x0, [x29, #-0x8]
    bl _free

    ; CLOSE FILE
    mov x0, x19
    bl _fclose

    ;FUNCTION FOOTER
    mov sp, x29
    ldp x21, x22, [sp], #0x10
    ldp x19, x20, [sp], #0x10
    ldp x29, x30, [sp], #0x10
    ret
;;;;;;;;;; FUNCTION END ;;;;;;;;;;

;;;;;;;;;; FUNCTION START ;;;;;;;;;;
getFileLinesCount:
; param0: char* filename
    ; FUNCTION HEADER
    stp x29, x30, [sp, #-0x10]!
    stp x19, x20, [sp, #-0x10]!
    mov x29, sp
    
    ; LOCAL VARIABLES
    sub sp, sp, #0x10
    ; [x29, #-0x8]: char* linep
    ; [x29, #-0x10]: size_t linecapp
    mov x20, #0x0

    ; OPEN INPUT FILE
    adrp x1, filemode@PAGE
    add x1, x1, filemode@PAGEOFF
    bl _fopen
    mov x19, x0     ; FILE* input file handle

    ; MALLOC LINE BUFFER
    mov x0, #0x400
    str x0, [x29, #-0x10]
    bl _malloc
    str x0, [x29, #-0x8]

getFileLinesCount_loop:
    ; READ LINE FROM FILE
    add x0, x29, #-0x8  ; char** linep
    add x1, x29, #-0x10     ; size_t* linecapp
    mov x2, x19     ; FILE* stream
    bl _getline
    cmp x0, #-0x1
    beq getFileLinesCount_end

    add x20, x20, #0x1
    b getFileLinesCount_loop

getFileLinesCount_end:    
    ; FREE LINE BUFFER
    ldr x0, [x29, #-0x8]
    bl _free

    ; CLOSE FILE
    mov x0, x19
    bl _fclose

    mov x0, x20
    ;FUNCTION FOOTER
    mov sp, x29
    ldp x19, x20, [sp], #0x10
    ldp x29, x30, [sp], #0x10
    ret
;;;;;;;;;; FUNCTION END ;;;;;;;;;;

;;;;;;;;;; FUNCTION START ;;;;;;;;;;
remove_newline:
; param0: char*
    ; FUNCTION HEADER
    stp x29, x30, [sp, #-0x10]!
    mov x29, sp
    
    mov x1, #0x0A
    bl _strchr
    cmp x0, #0
    beq remove_newline_end
    strb wzr, [x0]

remove_newline_end:
    ;FUNCTION FOOTER
    mov sp, x29
    ldp x29, x30, [sp], #0x10
    ret
;;;;;;;;;; FUNCTION END ;;;;;;;;;;

;;;;;;;;;; FUNCTION START ;;;;;;;;;;
function_template:
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


.section    __DATA,__data
filename:
    .string "input"
filemode:
    .string "r"

format:
    .string "%d\n"


