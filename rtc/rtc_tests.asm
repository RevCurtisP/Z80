;;Test in Z80 Simulator IDE 
;;tasm -80 -b -s rtc_tests.asm


        .org    $0000
        call    rtc_test
        halt

        .org    $0060
rtc_bcd:
        ;        fnd  cc  ss  mm  HH  WD  DD  MM  YY
        ;.byte   $FF,$99,$32,$54,$21,$01,$12,$04,$23
        ;       fnd  cc  ss  mm  HH  DD  MM  YY
        .byte   $FF,$99,$32,$54,$21,$12,$04,$23

        .org    $0080
rtc_str:
        ;.byte   "230412215659",0

        .org $0100

rtc_test:
        ld      hl,rtc_bcd
        ld      de,rtc_str
        call    rtc_to_str
        halt

#include "rtc_str.asm"

        .end