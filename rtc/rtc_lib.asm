;RTC Module Common Code
;
;Validate RTC fields 
;Args: HL = Address of RTC Data Structure
;Destroys: BC
;Returns: A=0, Z=1 if Successful, A=$FF, Z=0 if not
;         DE and HL unchanged
rtc_validate:
        push    hl                ;Save Arguments
        push    de
        inc     hl                
        inc     hl
        ld      d,h               ;DE = Address of RTC Field 2 (Seconds)
        ld      e,l
        ld      hl,rtc_bounds     ;Field Min/Max Values
        ld      b,5
rtc_val_loop:
        ld      a,(de)            ;Get RTC Byte
        cp      (hl)              ;If < Than Lower Bound
        jr      c,rtc_ret_err     ;  Error Out
        inc     hl
        cp      (hl)              ;If >= Upper Bound
        jr      nc,rtc_ret_err    ;  Error Out
        inc     hl                ;
        inc     de                ;Move to Next RTC Byte
        djnz    rtc_val_loop      ;and Check It
        xor     a                 ;No Errors - Return Success
        pop     de                ;after Restoring Arguments
        pop     hl
        ret                       

rtc_ret_err:
        ld      a,$FF             ;Date Format Error
        or      a                 ;Set Flags to match Return Value
        pop     de                ;Restore Arguments
        pop     hl
        ret                       ;All Done

rtc_bounds:     ;seconds minutes    hour     day     month
        .byte   $00,$60, $00,$60, $00,$24, $01,$32, $01,$13

;Note: The DTS1244 has a Weekday register between Hour and Day (called 
;Date in the data sheet). 
;
;The RTC read routine must shift Date, Month, and Year forward 1 byte to 
;match the data structure below. In addition, if Hour is in AM/PM it will 
;need to be converted to 24 hour. Any other control bits must be masked
;to zeros.
;
;The write routine will shift Day, Month, and Year forward one bit and
;set Weekday to 1.  


;Shift Down RTC data to remove Weekday
;Some RTC chips have a day of the week field between hours and days which 
;this module does not use
;Changes: rtc_bcd - RTC fields
;Destroys: A,B,IX
dtm_del_field:
;       ld       IX,rtc_bcd
;       ld       b,6
;dtm_del_loop:
;       ld       a,(IX+6)
;       ld       (IX+5),a
;       inc      IX
;       djnz     dtm_del_loop
;       ret

;Shift Up RTC data to add Weekday and set it to 1
;Some RTC chips have a day of the week field between hours and days which 
;this module does not use
;Changes: rtc_bcd - RTC fields
;Destroys: A,B,IX
dtm_ins_field:
;       ld       IX,rtc_bcd
;       ld       b,6
;dtm_add_loop:
;       ld       a,(IX+7)
;       ld       (IX+8),a
;       dec      IX
;       djnz     dtm_del_loop
;       ret

