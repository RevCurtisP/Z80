;RTC Chip Read/Write Stub
;For use with String Conversion Module rtc_str.asm
;
;Copy and modify for specific RTC chip
;Naming Convention: rtc_{part#}.asm

;;;MUCH TO DO IN HERE

;Normalized RTC Data Structure (Each 1 byte field is 2 BCD digits)
;+0 fnd RTC Found     $FF if found, else 0
;+1 cc  Centiseconds
;+2 ss  Seconds
;+3 mm  Minutes
;+4 HH  Hour         24 Hour Format
;+5 DD  Day
;+6 MM  Month 
;+7 YY  Year
;+8 WD  Weekday      Supported by some RTC chips
;+9 ovf Overflow     Set to 0 after RTC Read/Write


;Sample RTC Date/Time Registers  (DTS1244)
;Mapped into Normalized Data Structure
;Read: If HH is in 12 hour Format, Convert to 24 hour
;  DD/MM/YY shifted up one byte and WD moved to end
;Write: Possibly set 24 hour mode control bit
;       Move WD back to original position
;0 cc  Centiseconds
;1 ss  Seconds
;2 mm  Minutes
;3 HH  Hour          With 12/24 control bits
;4 WD  Weekday      
;5 DD  Day
;6 MM  Month 
;7 YY  Year

;Read Real Time Clock
;Args: HL = Address of RTC Normalized Data Structure 
;Destroys: ???
;Returns: A = 0 if Successful, otherwise $FF
;         DE and HL unchanged
rtc_read:
    push    hl
    push    de
;Stub sets RTC Not Found and Returns
    xor     a         
    ld      (hl),a    ;RTC Not Found
    dec     a         ;Return $FF = Failure
;Sample Code 
;
;
    pop     de
    push    hl
    ret

;Write Real Time Clock
;Args: HL = Address of RTC Normalized Data Structure 
;Destroys: ???
;Returns: A = 0 if Successful, otherwise $FF
;         DE and HL unchanged
rtc_write:
    push    hl
    push    de
;Stub sets RTC Not Found and Returns Failure
    ld      a,0
    ld      (hl),a    ;RTC Not Found
    dec     a         ;Return $FF = Failure
;Sample Code 
;
;
    pop     de
    push    hl
    ret



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
dtm_del_weekday:
       ld       IX,rtc_bcd
       ld       b,6
dtm_del_loop:
       ld       a,(IX+6)
       ld       (IX+5),a
       inc      IX
       djnz     dtm_del_loop
       ret

;Shift Up RTC data to add Weekday and set it to 1
;Some RTC chips have a day of the week field between hours and days which 
;this module does not use
;Changes: rtc_bcd - RTC fields
;Destroys: A,B,IX
dtm_add_weekday:
       ld       IX,rtc_bcd
       ld       b,6
dtm_add_loop:
       ld       a,(IX+7)
       ld       (IX+8),a
       dec      IX
       djnz     dtm_del_loop
       ret

        .end
