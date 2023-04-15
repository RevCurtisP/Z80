;RTC Chip Null Driver
;Simulate RTC Chip I/O for testing
;
;This module assumes that the contents of the date-time buffer
;does not change between reads and writes 


;RTC Date-Time Buffer
;+0 fnd RTC Found     $FF if found, else 0
;+1 cc  Centiseconds
;+2 ss  Seconds
;+3 mm  Minutes
;+4 HH  Hour         24 Hour Format
;+5 DD  Day
;+6 MM  Month 
;+7 YY  Year
;+8     Unused       
;+9 ovf Overflow     Set to 0 after RTC Read/Write

;Initialize Real Time Clock
;  Fills date-time buffer with zeros
;  causing following reads to return RTC Not Found
;Args: HL = Address of RTC Normalized Data Structure 
;Destroys: BC
;Returns: A = 0 if Successful, otherwise $FF
;         DE and HL unchanged
rtc_init:
    push   hl           ;Save Argument
    xor    a            ;Set RTC Not Found so initial
    ld     b,10         ;Clear entire date-time buffer
rtc_init_loop:
    ld    (hl),a        ;Clear field
    inc   hl            ;Move to Next One
    djnz  rtc_init_loop ;and clear it
    xor a               ;Return A=0 - Success
    pop   hl
    ret                 

;Read Real Time Clock
;Args: HL = Address of RTC Normalized Data Structure 
;Destroys: BC
;Returns: A=0, Z=1 if Successful, A=$FF, Z=0 if not
;         DE and HL unchanged
rtc_read:
    ld      a,(HL)            ;Check RTC Found flag
    or      a                 ;If 0 (Not Found)
    jr      z,rtc_read_fail   ;  return Failure
    call    rtc_validate      ;Validate date-time buffer
    jr      nz,rtc_read_fail  ;If Invalid, return Failure
    xor     a                 ;Else return Success
    ret
rtc_read_fail:
    ld      a,$FF             ;Return Failure
    ret

;Write Real Time Clock
;Args: HL = Address of RTC Normalized Data Structure 
;Destroys: BC
;Returns: A=0, Z=1 if Successful, A=$FF, Z=0 if not
;         DE and HL unchanged
rtc_write:
    call    rtc_validate      ;Validate date-time buffer
    jr      z,rtc_write_ok    ;If Valid
    ld      (hl),0            ;Set RTC Not Found for following reads
    ret                       ;and return Failure
rtc_write_ok:
    ld      (hl),$FF          ;Set RTC Found for following reads
    xor     a                 ;Return Success
    ret

        .end
