;Test in Z80 Simulator IDE 
;tasm -80 -b -s dtm_tests.asm


        .org    $0000
        ld      sp,$FF          ;Set Stack
        call    dtm_test
        halt

        .org    $0040
soft_clock:
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        
        .org    $0050
sample_dtm:
        ;       fnd  cc  ss  mm  HH  DD  MM  YY
        .byte   $FF,$99,$32,$54,$21,$12,$04,$23

        .org    $0060
dtm_buffer:
        ;       fnd  cc  ss  mm  HH  DD  MM  YY
        .byte   $00,$00,$00,$00,$00,$00,$00,$00

        .org    $0070
invalid_str:
        .byte   "23041224565999",0


        .org    $0080
sample_str:
        .byte   "23041221565999",0

        .org    $0090
str_buffer:    
        .byte   0

        .org $0100

dtm_test:
        ld      bc,soft_clock
        call    rtc_init
 
        ld      hl,sample_dtm
        call    rtc_write
 
        ld      hl,dtm_buffer
        call    rtc_read
        ld      ($E0),a
        
        ld      de,str_buffer
        call    dtm_to_str
        ld      ($E1),a

        ld      hl,dtm_buffer
        call    str_to_dtm
        ld      ($E2),a
        call    rtc_write
        ld      ($E3),a

        call    dtm_fmt_str
        ld      ($E4),a

        ld      de,sample_str
        call    str_to_dtm
        ld      ($E5),a
        call    rtc_write
        ld      ($E6),a
        
        ld      de,str_buffer
        call    dtm_to_str
        ld      ($E7),a

        ld      hl,sample_dtm
        ld      de,str_buffer
        call    dtm_to_fmt
        ld      ($E8),a

        ld      de,invalid_str
        call    str_to_dtm
        ld      ($E9),a
        
        ret

#include "dtm_lib.asm"
#include "softclock.asm"

        .end