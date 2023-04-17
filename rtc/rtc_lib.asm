;RTC Date and Time Module for Z80
;DateTime validation, modification and String Conversion Routines 
;
;RTC Data Structure (Each 1 byte field is 2 BCD digits)
;+0 fnd RTC Found     $FF if found, else 0
;+1 cc  Centiseconds
;+2 ss  Seconds
;+3 mm  Minutes
;+4 HH  Hour          Needs to be in 24 Hour Format
;+5 DD  Day
;+6 MM  Month 
;+7 YY  Year
;+8 WD  Weekday      Not used by this module
;+9 ovf Overflow     Set to 0 after RTC Read/Write
;        May be used as an extra overflow byte
;

;Date String Structure: 17 bytes (14 unformatted)
;      Raw: YYMMDDHHmmsscc.  
;Formatted: YYYY-MM-DD HH:mm.
;   Offset: 01234567890123456
;* period denotes null terminator

;Convert BCD Date to Formatted Date String
;Args: HL = Address of RTC Data 
;      DE = Address of Date String Buffer
;Destroys: AF, BC
;Returns: DE and HL unchanged
rtc_to_fmt:
        call  rtc_to_str          ;Convert RTC Date to Unformatted Date String
                                  ;then Fall into Formatting Routine
;Format Date String
;Converts Date String from YYMMDDHHmmsscc to YYYY-MM-DD HH:mm
;Args: DE = Address of String Buffer
;Destroys AF, BC
rtc_fmt_str: 
        ld      a,(de)            ;If Date is Empty String
        or      a                 ;  just Return 
        ret     z                 
        push    hl                ;Save Registers
        push    de
        ld      h,d               ;DE = Start Position in Raw String
        ld      l,e
        ld      bc,9              ;(Second Digit of Minutes)
        add     hl,bc
        ld      d,h
        ld      e,l
        ld      bc,7              ;HL = Start Position in Formatted String
        add     hl,bc             ;(Terminator Ending String)
        ld      c,0
        call    rtc_str_mov       ;Move Minutes + ASCII NUL
        ld      c,':'
        call    rtc_str_mov       ;Move Hours + Colon
        ld      c,' '
        call    rtc_str_mov       ;Move Day + Space
        ld      c,'-'
        call    rtc_str_mov       ;Move Month + Dash
        call    rtc_str_mov       ;Move Year + Dash
        ld      bc,$3230          ;Add Century to Beginning
        ld      (hl),c
        dec     hl
        ld      (hl),b
        dec     hl
        pop     de                ;Restore Registers
        pop     hl                
        xor     a                 ;Return Success
        ret
    
;Move Characters from Raw to Formatted (Moving Backwards)
;C = Character to Insert, DE = Raw String Position, HL = Formatted String Position
rtc_str_mov:
        ld    (hl),c        ;Store Insertion Character
        dec   hl            ;and Move Backward
        ld    a,(de)        ;Copy Right Digit
        ld    (hl),a
        dec   de            ;and Move Backward
        dec   hl            
        ld    a,(de)        ;Copy Left Digit
        ld    (hl),a
        dec   de            ;and Move Backward
        dec   hl            
        ret

;Convert RTC Date to Unformatted Date String
;Args: HL = Address of RTC Buffer
;      DE = Address of Date String Buffer
;Destroys: AF, BC
;Returns: DE and HL unchanged
rtc_to_str:
        ld      a,(hl)            ;+0 - RTC Found
        or      a                 ;Set Flags
        jr      nz,rtc_str_do     ;If Not Found
        ld      (de),a            ;  Return a Null String
        ret                   
rtc_str_do:
        push    hl                ;Save Arguments
        push    de
        ld      bc,7              ;Start at RTC Field 7 (Year)
        add     hl,bc             
        ld      b,c               ;and Process 7 Fields
rtc_str_loop:        
        ld      a,(hl)            ;Get RTC Field 
        ld      c,a               ;and Save it
        srl     a                 ;Shift Tens Digit to Low Nybble
        srl     a
        srl     a
        srl     a
        or      '0'               
        ld      (de),a            
        inc     de                
        ld      a,c               ;Get Back RTC Field
        and     $0F               ;Isolate Ones Digit
        or      '0'               ;Convert it to ASCII
        ld      (de),a            ;Put it in the String
        inc     de                ;  and Move to Next Character Position
        dec     hl                ;Move to Previous RTC Field
        djnz    rtc_str_loop      ;  and Convert It
        xor     a
        ld      (de),a            ;Terminate String
        pop     de                ;Restore Arguments
        pop     hl
        ret

;Convert Raw Date String to RTC Date
;Args: HL = Base Address of RTC Buffer
;      DE = Address of Date String Buffer
;           Must be in format YYMMDDHHmmss (any following characters are ignored)
;Destroys: BC
;Returns: A = 0 if Successful, $FF if Date String is Invalid
;         DE and HL unchanged
str_to_rtc:
        push    hl                ;Save Arguments
        push    de
        ld      bc,7              ;Start at RTC Field 7 (Year)
        add     hl,bc             
        ld      b,c               ;and Process 7 Fields
str_rtc_loop: 
        call    str_rtc_digit     ;Get Tens Digit
        sla     a                 ;Shift to High Nybble
        sla     a  
        sla     a  
        sla     a  
        ld      c,a               ;and save it
        call    str_rtc_digit     ;Get Ones Digit
        or      c                 ;Combine with Tens Digit
        ld      (hl),a            ;Store in rtc_bcd
        dec     hl                ;and Move Backwards
        djnz    str_rtc_loop      ;Do Next Two Digits
        xor     a                 ;Set centiseconds to 0
        ld      (hl),a            
        pop     de                ;Restore Arguments
        pop     hl
        jp      rtc_validate      ;then Execute Validation Routine

;Return Binary Value of ASCII Digit at DE, Error Out if Not Digit
str_rtc_digit:
        ld      a,(de)            ;Get ASCII Digit
        sub     '0'               ;Convert to Binary Value
        jr      c,str_rtc_err     ;Error if Less than '0'
        cp      ':'
        jr      nc,str_rtc_err    ;Error if Greater than '9'
        inc     de                ;Move to Next Digit
        ret
        
str_rtc_err:
        pop     bc                ;Discard Subroutine Return Address
        ld      a,$FF             ;Date Format Error
        pop     de                ;Restore Arguments
        pop     hl
        ret                       ;All Done

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

