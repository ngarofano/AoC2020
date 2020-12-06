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
    mov x21, #0x0   ; highest_seat_id
    mov x22, #0xFFF ; lowest_seat_id
    mov x23, #0x0   ; my_seat_id

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
    beq main_next_stage

    ; CLEAN LINE INPUT
    ldr x0, [x29, #-0x8]
    bl removeNewline
    ldr x20, [x29, #-0x8]

    ; GET SEAT ID
    mov x0, x20
    bl seatPatternToId
    eor x23, x23, x0

    cmp x0, x21
    bls main_lowest_check
    mov x21, x0
main_lowest_check:
    cmp x0, x22
    bhs main_loop
    mov x22, x0

    b main_loop

main_next_stage:
    cmp x22, x21
    bhi main_end
    eor x23, x23, x22
    add x22, x22, #0x1
    b main_next_stage

main_end:
    ; PRINT
    adrp x0, format@PAGE
    add x0, x0, format@PAGEOFF
    stp x23, xzr, [sp, #-0x10]!
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
seatPatternToId:
; param0: char* seat_pattern
    ; FUNCTION HEADER
    stp x29, x30, [sp, #-0x10]!
    stp x19, x20, [sp, #-0x10]!
    stp x21, x22, [sp, #-0x10]!
    mov x29, sp
    
    ; LOCAL VARIABLES
    mov x19, x0     ; seat_pattern
    mov x20, #0x0   ; seat_id
    mov x21, #0x0   ; index

seatPatternToId_loop:
    ldrb w9, [x19, x21]
    and w9, w9, #0xFF
    lsl x20, x20, #0x1
    cmp w9, #0x46
    beq seatPatternToId_continue
    cmp w9, #0x4C
    beq seatPatternToId_continue
    add x20, x20, #0x1

seatPatternToId_continue:
    add x21, x21, #0x1
    cmp x21, #0xA 
    blo seatPatternToId_loop

seatPatternToId_end:
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

format:
    .string "My Seat Id: %d\n"

