# Z80

Modules for use with Real Time Clock Chips

| File          | Description                                                    |
| ------------- | -------------------------------------------------------------- |
| rtc_io.asm    | RTC I/O driver skeleton source code                            |
| rtc_null.asm  | Test I/O driver - Static RTC Buffer                            |
| rtc_str.asm   | RTC data to and from string conversion routines                |
| rtc_lib.asm   | Common routines used by other modules                          |
| rtc_tests.asm | Program to test modules                                        |

## Data Structures 

### RTC Buffer 
Each 1 byte field is 2 BCD digits

| Offset | Name | Description  | Notes                             |
| ------ | ---- | ------------ | --------------------------------- |
|   +0   | fnd  | RTC Found    | $FF if found, else 0              |
|   +1   |  cc  | Centiseconds |                                   |
|   +2   |  ss  | Seconds      |                                   |
|   +3   |  mm  | Minutes      |                                   |
|   +4   |  HH  | Hour         | 24 Hour Format                    |
|   +5   |  DD  | Day          |                                   |
|   +6   |  MM  | Month        |                                   |
|   +7   |  YY  | Year         |                                   |
|   +8   |  WD  | Weekday      | Set to 0 if Weekday not supported |
|   +9   | ovf  | Overflow     | Set to 0 after RTC Read/Write     |

### String Buffer 

| Name | Description  |  Raw  | Formatted |
| ---- | ------------ | ----- | --------- |
|  CC  | Century      |       |  0-1 "20" |
|  YY  | Year         |  0-1  |  2-3      |
|      |              |       |   4   "-" |
|  MM  | Month        |  2-3  |  5-6      |
|      |              |       |   7   "-" |
|  DD  | Day          |  4-5  |  8-9      |
|      |              |       |   10  " " |
|  HH  | Hour         |  6-7  | 11-12     |
|      |              |       |   13  ":" |
|  mm  | Minutes      |  8-9  | 14-15     |
|      |              |       |   16  ":" |
|  ss  | Seconds      | 10-11 | 17-18     |
|  cc  | Centiseconds | 12-13 |           |
| null | Terminator   |   14  |   19  $00 |

## Assembly Language Routines

Notes: All routines return with HL and DE unchanged.

If the RTC chip is memory mapped, then instead of passing
a port number, the chip's base address is passed in BC.

### rtc_init
Initialize Real Time Clock

Module
: RTC Driver (rtc_io)

Args 
: HL = Address of RTC Buffer, C = Z80 I/O Port

Returns
: A=0, ZF=1 if Successful, A=$FF, ZF=0 if not

### rtc_read
Read Real Time Clock

Module
: RTC Driver (rtc_io)

Args 
: HL = Address of RTC Buffer, C = Z80 I/O Port

Returns
: A=0, ZF=1 if Successful, A=$FF, ZF=0 if not

### rtc_write
Write to Real Time Clock

Module
: RTC Driver (rtc_io)

Args 
: HL = Address of RTC Buffer, C = Z80 I/O Port

Returns
: A=0, ZF=1 if Successful, A=$FF, ZF=0 if not

### rtc_to_str
Convert RTC date to String date

Module
: rtc_str

Args 
: HL = Address of RTC Buffer, DE = Address of String Buffer

### rtc_fmt_str
Format Date String

Module
: rtc_str

Args
: DE = Address of String Buffer

### str_to_rtc
Convert String date to RTC date

Module
: rtc_str

Args 
: HL = Address of RTC Buffer, DE = Address of String Buffer

Returns
: A=0, ZF=1 if Successful, A=$FF, ZF=0 if Invalid Date

### rtc_validate
Validate RTC fields 

Module
: rtc_lib

Args
: HL = Address of RTC Data Structure

Returns
: A=0, ZF=1 if Successful, A=$FF, ZF=0 if not
