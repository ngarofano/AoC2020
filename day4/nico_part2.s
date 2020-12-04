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
    ; x21           ; copied_entry

    ; MALLOC ENTRY BUFFER
    mov x0, #0x400
    bl _malloc
    mov x21, x0

    ; VALIDATE BYR
    mov x0, x21
    mov x1, x19
    mov x2, #0x400
    bl _memcpy
    adrp x9, byr@PAGE
    add x1, x9, byr@PAGEOFF
    mov x0, x21
    bl _strstr
    cmp x0, #0x0
    beq validateEntry_end
    adrp x1, space@PAGE
    add x1, x1, space@PAGEOFF
    bl _strtok
    cmp x0, #0x0
    beq validateEntry_end
    add x0, x0, #0x4
    bl validateByr
    cmp x0, #0x0
    beq validateEntry_end

    ; VALIDATE IYR
    mov x0, x21
    mov x1, x19
    mov x2, #0x400
    bl _memcpy
    adrp x9, iyr@PAGE
    add x1, x9, iyr@PAGEOFF
    mov x0, x21
    bl _strstr
    cmp x0, #0x0
    beq validateEntry_end
    adrp x1, space@PAGE
    add x1, x1, space@PAGEOFF
    bl _strtok
    cmp x0, #0x0
    beq validateEntry_end
    add x0, x0, #0x4
    bl validateIyr
    cmp x0, #0x0
    beq validateEntry_end

    ; VALIDATE EYR
    mov x0, x21
    mov x1, x19
    mov x2, #0x400
    bl _memcpy
    adrp x9, eyr@PAGE
    add x1, x9, eyr@PAGEOFF
    mov x0, x21
    bl _strstr
    cmp x0, #0x0
    beq validateEntry_end
    adrp x1, space@PAGE
    add x1, x1, space@PAGEOFF
    bl _strtok
    cmp x0, #0x0
    beq validateEntry_end
    add x0, x0, #0x4
    bl validateEyr
    cmp x0, #0x0
    beq validateEntry_end

    ; VALIDATE HGT
    mov x0, x21
    mov x1, x19
    mov x2, #0x400
    bl _memcpy
    adrp x9, hgt@PAGE
    add x1, x9, hgt@PAGEOFF
    mov x0, x21
    bl _strstr
    cmp x0, #0x0
    beq validateEntry_end
    adrp x1, space@PAGE
    add x1, x1, space@PAGEOFF
    bl _strtok
    cmp x0, #0x0
    beq validateEntry_end
    add x0, x0, #0x4
    bl validateHgt
    cmp x0, #0x0
    beq validateEntry_end

    ; VALIDATE HCL
    mov x0, x21
    mov x1, x19
    mov x2, #0x400
    bl _memcpy
    adrp x9, hcl@PAGE
    add x1, x9, hcl@PAGEOFF
    mov x0, x21
    bl _strstr
    cmp x0, #0x0
    beq validateEntry_end
    adrp x1, space@PAGE
    add x1, x1, space@PAGEOFF
    bl _strtok
    cmp x0, #0x0
    beq validateEntry_end
    add x0, x0, #0x4
    bl validateHcl
    cmp x0, #0x0
    beq validateEntry_end

    ; VALIDATE ECL
    mov x0, x21
    mov x1, x19
    mov x2, #0x400
    bl _memcpy
    adrp x9, ecl@PAGE
    add x1, x9, ecl@PAGEOFF
    mov x0, x21
    bl _strstr
    cmp x0, #0x0
    beq validateEntry_end
    adrp x1, space@PAGE
    add x1, x1, space@PAGEOFF
    bl _strtok
    cmp x0, #0x0
    beq validateEntry_end
    add x0, x0, #0x4
    bl validateEcl
    cmp x0, #0x0
    beq validateEntry_end

    ; VALIDATE PID
    mov x0, x21
    mov x1, x19
    mov x2, #0x400
    bl _memcpy
    adrp x9, pid@PAGE
    add x1, x9, pid@PAGEOFF
    mov x0, x21
    bl _strstr
    cmp x0, #0x0
    beq validateEntry_end
    adrp x1, space@PAGE
    add x1, x1, space@PAGEOFF
    bl _strtok
    cmp x0, #0x0
    beq validateEntry_end
    add x0, x0, #0x4
    bl validatePid
    cmp x0, #0x0
    beq validateEntry_end

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
validatePid:
; param0: char* data
    ; FUNCTION HEADER
    stp x29, x30, [sp, #-0x10]!
    stp x19, x20, [sp, #-0x10]!
    mov x29, sp
    
    ; LOCAL VARIABLES
    mov x19, x0     ; data
    mov x20, #0x0   ; valid

    mov x0, x19
    bl _strlen
    cmp x0, #0x9 
    bne validatePid_end

    mov x10, #0x0
validatePid_loop:
    ldrb w9, [x19, x10]
    and w9, w9, #0xFF

    cmp w9, #0x30
    blo validatePid_end
    cmp w9, #0x39
    bhi validatePid_end

    add x10, x10, #0x1
    cmp x10, #0x7
    blo validatePid_loop

    mov x20, #0x1

validatePid_end:
    mov x0, x20

    ;FUNCTION FOOTER
    mov sp, x29
    ldp x19, x20, [sp], #0x10
    ldp x29, x30, [sp], #0x10
    ret
;;;;;;;;;; FUNCTION END ;;;;;;;;;;

;;;;;;;;;; FUNCTION START ;;;;;;;;;;
validateEcl:
; param0: char* data
    ; FUNCTION HEADER
    stp x29, x30, [sp, #-0x10]!
    stp x19, x20, [sp, #-0x10]!
    stp x21, x22, [sp, #-0x10]!
    mov x29, sp
    
    ; LOCAL VARIABLES
    mov x19, x0     ; data
    mov x20, #0x0   ; valid
    ; x21           ; value_array
    mov x22, #0x0   ; array_index

    mov x0, x19
    bl _strlen
    cmp x0, #0x3
    bne validateEcl_end

    adrp x21, ecl_values@PAGE
    add x21, x21, ecl_values@PAGEOFF

validateEcl_loop:
    lsl x9, x22, #0x2
    add x1, x21, x9
    mov x0, x19
    bl _strcmp
    cmp x0, #0x0
    beq validateEcl_success

    add x22, x22, #0x1
    cmp x22, #0x7
    blo validateEcl_loop
    b validateEcl_end

validateEcl_success:
    mov x20, #0x1

validateEcl_end:
    mov x0, x20

    ;FUNCTION FOOTER
    mov sp, x29
    ldp x21, x22, [sp], #0x10
    ldp x19, x20, [sp], #0x10
    ldp x29, x30, [sp], #0x10
    ret
;;;;;;;;;; FUNCTION END ;;;;;;;;;;

;;;;;;;;;; FUNCTION START ;;;;;;;;;;
validateHcl:
; param0: char* data
    ; FUNCTION HEADER
    stp x29, x30, [sp, #-0x10]!
    stp x19, x20, [sp, #-0x10]!
    mov x29, sp
    
    ; LOCAL VARIABLES
    mov x19, x0     ; data
    mov x20, #0x0   ; valid

    mov x0, x19
    bl _strlen
    cmp x0, #0x7 
    bne validateHcl_end
    ldrb w9, [x19]
    and w9, w9, #0xFF
    cmp w9, #0x23
    bne validateHcl_end

    mov x10, #0x1
validateHcl_loop:

    ldrb w9, [x19, x10]
    and w9, w9, #0xFF

    cmp w9, #0x30
    blo validateHcl_end
    cmp w9, #0x66
    bhi validateHcl_end
    cmp w9, #0x39
    bls validateHcl_continue
    cmp w9, #0x61
    bhs validateHcl_continue
    b validateHgt_end

validateHcl_continue:
    add x10, x10, #0x1
    cmp x10, #0x7
    blo validateHcl_loop

    mov x20, #0x1

validateHcl_end:
    mov x0, x20

    ;FUNCTION FOOTER
    mov sp, x29
    ldp x19, x20, [sp], #0x10
    ldp x29, x30, [sp], #0x10
    ret
;;;;;;;;;; FUNCTION END ;;;;;;;;;;

;;;;;;;;;; FUNCTION START ;;;;;;;;;;
validateHgt:
; param0: char* data
    ; FUNCTION HEADER
    stp x29, x30, [sp, #-0x10]!
    stp x19, x20, [sp, #-0x10]!
    stp x21, x22, [sp, #-0x10]!
    mov x29, sp
    
    ; LOCAL VARIABLES
    mov x19, x0     ; data
    mov x20, #0x0   ; valid
    ; x21           ; unit_index

    mov x0, x19
    bl _strlen
    cmp x0, #0x4 
    blo validateHgt_end
    cmp x0, #0x5 
    bhi validateHgt_end
    sub x21, x0, #0x2

    add x0, x19, x21   
    adrp x1, cm@PAGE
    add x1, x1, cm@PAGEOFF  
    bl _strcmp
    cmp x0, #0x0 
    beq validateHgt_cm

    add x0, x19, x21   
    adrp x1, in@PAGE
    add x1, x1, in@PAGEOFF  
    bl _strcmp
    cmp x0, #0x0 
    beq validateHgt_in
    b validateHgt_end

validateHgt_cm:
    strb wzr, [x19, x21]
    mov x0, x19
    bl _atoi
    cmp x0, #150
    blo validateHgt_end
    cmp x0, #193
    bhi validateHgt_end
    b validateHgt_success


validateHgt_in:
    strb wzr, [x19, x21]
    mov x0, x19
    bl _atoi
    cmp x0, #59
    blo validateHgt_end
    cmp x0, #76
    bhi validateHgt_end

validateHgt_success:
    mov x20, #0x1

validateHgt_end:
    mov x0, x20

    ;FUNCTION FOOTER
    mov sp, x29
    ldp x21, x22, [sp], #0x10
    ldp x19, x20, [sp], #0x10
    ldp x29, x30, [sp], #0x10
    ret
;;;;;;;;;; FUNCTION END ;;;;;;;;;;

;;;;;;;;;; FUNCTION START ;;;;;;;;;;
validateEyr:
; param0: char* data
    ; FUNCTION HEADER
    stp x29, x30, [sp, #-0x10]!
    stp x19, x20, [sp, #-0x10]!
    mov x29, sp
    
    ; LOCAL VARIABLES
    mov x19, x0     ; data
    mov x20, #0x0   ; valid

    mov x0, x19
    bl _strlen
    cmp x0, #0x4 
    bne validateEyr_end
    mov x0, x19
    bl _atoi
    cmp x0, #2020
    blo validateEyr_end
    cmp x0, #2030
    bhi validateEyr_end

    mov x20, #0x1

validateEyr_end:
    mov x0, x20

    ;FUNCTION FOOTER
    mov sp, x29
    ldp x19, x20, [sp], #0x10
    ldp x29, x30, [sp], #0x10
    ret
;;;;;;;;;; FUNCTION END ;;;;;;;;;;

;;;;;;;;;; FUNCTION START ;;;;;;;;;;
validateIyr:
; param0: char* data
    ; FUNCTION HEADER
    stp x29, x30, [sp, #-0x10]!
    stp x19, x20, [sp, #-0x10]!
    mov x29, sp
    
    ; LOCAL VARIABLES
    mov x19, x0     ; data
    mov x20, #0x0   ; valid

    mov x0, x19
    bl _strlen
    cmp x0, #0x4 
    bne validateIyr_end
    mov x0, x19
    bl _atoi
    cmp x0, #2010
    blo validateIyr_end
    cmp x0, #2020
    bhi validateIyr_end

    mov x20, #0x1

validateIyr_end:
    mov x0, x20

    ;FUNCTION FOOTER
    mov sp, x29
    ldp x19, x20, [sp], #0x10
    ldp x29, x30, [sp], #0x10
    ret
;;;;;;;;;; FUNCTION END ;;;;;;;;;;

;;;;;;;;;; FUNCTION START ;;;;;;;;;;
validateByr:
; param0: char* data
    ; FUNCTION HEADER
    stp x29, x30, [sp, #-0x10]!
    stp x19, x20, [sp, #-0x10]!
    mov x29, sp
    
    ; LOCAL VARIABLES
    mov x19, x0     ; data
    mov x20, #0x0   ; valid

    mov x0, x19
    bl _strlen
    cmp x0, #0x4 
    bne validateByr_end
    mov x0, x19
    bl _atoi
    cmp x0, #1920
    blo validateByr_end
    cmp x0, #2002
    bhi validateByr_end

    mov x20, #0x1

validateByr_end:
    mov x0, x20

    ;FUNCTION FOOTER
    mov sp, x29
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

byr: 
    .string "byr:"
iyr: 
    .string "iyr:"
eyr: 
    .string "eyr:"
hgt: 
    .string "hgt:"
hcl: 
    .string "hcl:"
ecl: 
    .string "ecl:"
pid: 
    .string "pid:"

cm: 
    .string "cm"
in: 
    .string "in"

ecl_values:
    .string "amb"
    .string "blu"
    .string "brn"
    .string "gry"
    .string "grn"
    .string "hzl"
    .string "oth"

format:
    .string "Valid Entry Count: %d\n"


