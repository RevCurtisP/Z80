;;Test in Z80 Simulator IDE 
;;tasm -80 -b -s rtc_tests.asm


        .org    $0000
        ld      sp,$FF          ;Set Stack
        call    rtc_test
        halt

        .org    $0040
sample_dtm:
        ;       fnd  cc  ss  mm  HH  DD  MM  YY
        .byte   $FF,$99,$32,$54,$21,$12,$04,$23

        .org    $0050
dtm_buffer:
        ;       fnd  cc  ss  mm  HH  DD  MM  YY
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF

        .org    $0060
invalid_str:
        .byte   "23041224565999",0


        .org    $0070
sample_str:
        .byte   "23041221565999",0

        .org    $0080
str_buffer:    
        .byte   0

        .org $0100

rtc_test:
        ld      hl,dtm_buffer
        call    rtc_init
        
        ld      hl,sample_dtm
        ld      de,str_buffer
        call    rtc_to_str
        ld      ($E0),a

        ld      hl,dtm_buffer
        call    str_to_rtc
        ld      ($E1),a
        call    rtc_write
        ld      ($E2),a

        call    rtc_fmt_str
        ld      ($E3),a

        ld      de,sample_str
        call    str_to_rtc
        ld      ($E4),a
        call    rtc_write
        ld      ($E5),a
        
        ld      de,str_buffer
        call    rtc_to_str
        ld      ($E6),a

        ld      hl,sample_dtm
        ld      de,str_buffer
        call    rtc_to_fmt
        ld      ($E7),a

        ld      de,invalid_str
        call    str_to_rtc
        ld      ($E8),a
        
        ret

#include "rtc_lib.asm"
#include "rtc_null.asm"
#include "rtc_str.asm"



        .end