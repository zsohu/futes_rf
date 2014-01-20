$regfile = "m32def.dat"
$crystal = 11059200
$baud = 115200
$lib "mcsbyteint.lbx"                                       'a kisebb kod miatt
$lib "LUC_lcd4busy_timeout.lib"                             'Luciano's fast LCD lib

$hwstack = 256
$swstack = 256
$framesize = 256


Config Lcd = 20x4
'Config Lcdpin = Pin , Db4 = Portc.2 , Db5 = Portc.3 , Db6 = Portc.4 , Db7 = Portc.5 , E = Portc.6 , Rs = Portc.7 , Wr = Portd.7

'#######################Lucaiano's LCD LIB konstansok###########################
Const _lcddb4_portx = Portc                                 'Valid values: PORTA, PORTB, PORTC, PORTD, PORTE.
Const _lcddb4_ddrx = Ddrc                                   'Valid values: DDRA, DDRB, DDRC, DDRD, DDRE.
Const _lcddb4_pinnumber = 2                                 'Valid values: 0, 1, 2, 3, 4, 5, 6, 7.

Const _lcddb5_portx = Portc                                 'Valid values: PORTA, PORTB, PORTC, PORTD, PORTE.
Const _lcddb5_ddrx = Ddrc                                   'Valid values: DDRA, DDRB, DDRC, DDRD, DDRE.
Const _lcddb5_pinnumber = 3                                 'Valid values: 0, 1, 2, 3, 4, 5, 6, 7.

Const _lcddb6_portx = Portc                                 'Valid values: PORTA, PORTB, PORTC, PORTD, PORTE.
Const _lcddb6_ddrx = Ddrc                                   'Valid values: DDRA, DDRB, DDRC, DDRD, DDRE.
Const _lcddb6_pinnumber = 4                                 'Valid values: 0, 1, 2, 3, 4, 5, 6, 7.

Const _lcddb7_portx = Portc                                 'Valid values: PORTA, PORTB, PORTC, PORTD, PORTE.
Const _lcddb7_ddrx = Ddrc                                   'Valid values: DDRA, DDRB, DDRC, DDRD, DDRE.
Const _lcddb7_pinx = Pinc                                   'Valid values: PINA, PINB, PINC, PIND, PINE.
Const _lcddb7_pinnumber = 5                                 'Valid values: 0, 1, 2, 3, 4, 5, 6, 7.

Const _lcde_portx = Portc                                   'Valid values: PORTA, PORTB, PORTC, PORTD, PORTE.
Const _lcde_ddrx = Ddrc                                     'Valid values: DDRA, DDRB, DDRC, DDRD, DDRE.
Const _lcde_pinnumber = 6                                   'Valid values: 0, 1, 2, 3, 4, 5, 6, 7.

Const _lcdrw_portx = Portd                                  'Valid values: PORTA, PORTB, PORTC, PORTD, PORTE.
Const _lcdrw_ddrx = Ddrd                                    'Valid values: DDRA, DDRB, DDRC, DDRD, DDRE.
Const _lcdrw_pinnumber = 7                                  'Valid values: 0, 1, 2, 3, 4, 5, 6, 7.

Const _lcdrs_portx = Portc                                  'Valid values: PORTA, PORTB, PORTC, PORTD, PORTE.
Const _lcdrs_ddrx = Ddrc                                    'Valid values: DDRA, DDRB, DDRC, DDRD, DDRE.
Const _lcdrs_pinnumber = 7                                  'Valid values: 0, 1, 2, 3, 4, 5, 6, 7.
'###############################################################################

'SCL és SDA portok az I2C-hez
Config Sda = Portc.1
Config Scl = Portc.0

Const Ds1307w = &HD0                                        ' A Ds1307 óra címe
Const Ds1307r = &HD1

Config Clock = User                                         'Saját óra fv használata
Config Date = Ymd , Separator = .                           'Dátum formázás
Dim Weekday As Byte

'Various
Const True = 1
Const False = 0

'######################### nRF dolgok ##########################################
'=== Declare sub routines
Declare Sub R_register(byval Command As Byte , Byval C_bytes As Byte)
Declare Sub W_register(byval C_bytes As Byte)

'=== Constante ===
'Define nRF24L01 interrupt flag's
Const Idle_int = &H00                                       'Idle, no interrupt pending
Const Max_rt = &H10                                         'Max #of Tx Retrans Interrupt
Const Tx_ds = &H20                                          'Tx Data Sent Interrupt
Const Rx_dr = &H40                                          'Rx Data Received
'SPI(nRF24L01) commands
Const Read_reg = &H00                                       'Define Read Command To Register
Const Write_reg = &H20                                      'Define Write Command To Register
Const Rd_rx_pload = &H61                                    'Define Rx Payload Register Address
Const Wr_tx_pload = &HA0                                    'Define Tx Payload Register Address
Const Flush_tx = &HE1                                       'Define Flush Tx Register Command
Const Flush_rx = &HE2                                       'Define Flush Rx Register Command
Const Reuse_tx_pl = &HE3                                    'Define Reuse Tx Payload Register Command
Const Nop_comm = &HFF                                       'Define No Operation , Might Be Used To Read Status Register
'SPI(nRF24L01) registers(addresses)
Const Config_nrf = &H00                                     'Config' register address
Const En_aa = &H01                                          'Enable Auto Acknowledgment' register address
Const En_rxaddr = &H02                                      'Enabled RX addresses' register address
Const Setup_aw = &H03                                       'Setup address width' register address
Const Setup_retr = &H04                                     'Setup Auto. Retrans' register address
Const Rf_ch = &H05                                          'RF channel' register address
Const Rf_setup = &H06                                       'RF setup' register address
Const Status = &H07                                         'Status' register address
Const Observe_tx = &H08                                     'Observe TX' register address
Const Cd = &H09                                             'Carrier Detect' register address
Const Rx_addr_p0 = &H0A                                     'RX address pipe0' register address
Const Rx_addr_p1 = &H0B                                     'RX address pipe1' register address
Const Rx_addr_p2 = &H0C                                     'RX address pipe2' register address
Const Rx_addr_p3 = &H0D                                     'RX address pipe3' register address
Const Rx_addr_p4 = &H0E                                     'RX address pipe4' register address
Const Rx_addr_p5 = &H0F                                     'RX address pipe5' register address
Const Tx_addr = &H10                                        'TX address' register address
Const Rx_pw_p0 = &H11                                       'RX payload width, pipe0' register address
Const Rx_pw_p1 = &H12                                       'RX payload width, pipe1' register address
Const Rx_pw_p2 = &H13                                       'RX payload width, pipe2' register address
Const Rx_pw_p3 = &H14                                       'RX payload width, pipe3' register address
Const Rx_pw_p4 = &H15                                       'RX payload width, pipe4' register address
Const Rx_pw_p5 = &H16                                       'RX payload width, pipe5' register address
Const Fifo_status = &H17

Dim D_bytes(33) As Byte , B_bytes(33) As Byte               'Dim the bytes use for SPI, D_bytes = outgoing B_bytes = Incoming
Dim D_szoveg As String * 32 At D_bytes(2) Overlay
Dim B_szoveg As String * 32 At B_bytes(1) Overlay
'###############################################################################

'############################# Config hardware SPI #############################
Config Spi = Hard , Interrupt = Off , Data Order = Msb , Master = Yes , Polarity = Low , Phase = 0 , Clockrate = 4 , Noss = 1
'Software SPI is NOT working with the nRF24L01, use hardware SPI only, but the SS pin must be controlled by our self
Config Pinb.3 = Output                                      'CE pin is output
Config Pinb.4 = Output                                      'SS pin is output
Config Pinb.1 = Input                                       'IRQ pin is input

Ce Alias Portb.3
Ss Alias Portb.4
Irq Alias Pinb.1

Spiinit                                                     'init the spi pins
Set Ce
Waitms 10                                                   'Wait a moment until all hardware is stable
Reset Ce                                                    'Set CE pin low
Reset Ss                                                    'Set SS pin low (CSN pin)
'###############################################################################

'######################### 595 setup ###########################################
Const Shift_delay = 20

Data_out Alias Porta.0                                      ' SER - first 595 pin 14
Latch_out Alias Porta.1                                     ' RCLK- all chips pin 12
Clock_out Alias Porta.2                                     ' SRCLK- all chips pin 11
                                                             'Chip 1 QH' -> 2nd SER OE connected to ground
Config Clock_out = Output                                   'set output to 595.
Config Data_out = Output                                    'set output to 595.
Config Latch_out = Output                                   'set output to 595.

Set Clock_out                                               'switch off 595
Reset Data_out                                              'switch off 595
Reset Latch_out                                             'switch off 595
'###############################################################################

Declare Sub Eeprom_iras(byval Cim As Word , Byval Ertek As Byte)       'EEPROM írás rutin deklarálás
Declare Function Eeprom_olvasas(byval Cim As Word) As Byte  'EEPROM olvasás rutin deklarálás

'###############################################################################

Dim Temp As Byte , W As Word
Dim Packet_count As Byte , I As Byte
Dim Header As String * 3
Dim Rele As String * 16
Dim Adatok(10) As String * 29
Dim Atvalto_b As Byte , Atvalto_w As Word

Declare Sub Send595(byval Pattern As Word)                  'send to shift registers
Dim Pattern As Word

'###############################################################################

Initlcd
Cursor Off
Cls
Lcd "Ready..."
Wait 1
Cls

Call R_register(status , 1)                                 'Read STATUS register
Reset Ce                                                    'Set CE low to access the registers
Gosub Setup_rx                                              'Setup the nRF24L01 for RX
Waitms 2                                                    'Add a delay before going in RX
Set Ce                                                      'Set nRF20L01 in RX mode

Do
                                                          'Main loop for RX
   If Irq = 0 Then                                          'Wait until IRQ occurs, pin becomes low on interrupt
    Locate 3 , 1 : Lcd "                    "
    Reset Ce                                                'Receiver must be disabled before reading pload

    Do                                                      'Loop until all 3 fifo buffers are empty
      Call R_register(rd_rx_pload , 32)                     'Read 32 bytes RX pload register
      Locate 3 , 1 : Lcd B_szoveg

      Temp = Split(b_szoveg , Adatok(1) , ",")

      Select Case Adatok(1)
         Case "$TM"
            Locate 4 , 1 : Lcd "Parancs: " ; Adatok(1)
            Time$ = Adatok(2)
            B_szoveg = ""

         Case "$DT"
            Locate 4 , 1 : Lcd "Parancs: " ; Adatok(1)
            Date$ = Adatok(2)
            B_szoveg = ""

         Case "$RL"
            Locate 4 , 1 : Lcd "Parancs: " ; Adatok(1)
            Rele = Adatok(2)
            Pattern = Binval(rele)
            Call Send595(pattern)
            B_szoveg = ""

         Case "$MW"
            Locate 4 , 1 : Lcd "Parancs: " ; Adatok(1)
            Atvalto_w = Val(adatok(2))
            Atvalto_b = Val(adatok(3))
            Call Eeprom_iras(atvalto_w , Atvalto_b)

         Case "$MR"
            Locate 4 , 1 : Lcd "                    "
            Locate 4 , 1 : Lcd "Parancs: " ; Adatok(1)
            Atvalto_w = Val(adatok(2))
            Temp = Eeprom_olvasas(atvalto_w)
            Locate 4 , 14 : Lcd "Mem:" ; Temp

      End Select

      Call R_register(fifo_status , 1)                      'Read FIFO_STATUS
    Loop Until B_bytes(1).0 = True                          'Test or RX_EMPTY bit is true, RX FIFO empty
    D_bytes(1) = Write_reg + Status                         'Reset the RX_DR status bit
    D_bytes(2) = &B01000000                                 'Write 1 to RX_DR bit to reset IRQ
    Call W_register(2)
    Set Ce                                                  'Enable receiver again
    Waitms 2
   End If

   Set Portd.5
   Waitms 100
   Reset Portd.5
   Waitms 150

   Locate 1 , 1 : Lcd "Datum: " ; Date$
   Locate 2 , 1 : Lcd "Ido:   " ; Time$

Loop

'###############################################################################
'#        _____       _                    ______                              #
'#       / ____|     | |           ___    |  ____|                             #
'#      | (___  _   _| |__  ___   ( _ )   | |__ _   _ _ __   ___ ___           #
'#       \___ \| | | | '_ \/ __|  / _ \/\ |  __| | | | '_ \ / __/ __|          #
'#       ____) | |_| | |_) \__ \ | (_>  < | |  | |_| | | | | (__\__ \          #
'#      |_____/ \__,_|_.__/|___/  \___/\/ |_|   \__,_|_| |_|\___|___/          #
'#                                                                             #
'###############################################################################

'############################# nRf subs ########################################

Sub W_register(byval C_bytes As Byte)                       'Write register with SPI
Reset Ss                                                    'Manual control SS pin, set SS low before shifting out the bytes
 Spiout D_bytes(1) , C_bytes                                'Shiftout the data bytes trough SPI , C_bytes is the amount bytes to be written
Set Ss                                                      'Set SS high
End Sub

Sub R_register(byval Command As Byte , Byval C_bytes As Byte) As Byte       'C_bytes = Count_bytes, number off bytes to be read
Reset Ss                                                    'Manual controle SS pin, set low before shifting in/out the bytes
 Spiout Command , 1                                         'First shiftout the register to be read
 Spiin B_bytes(1) , C_bytes                                 'Read back the bytes from SPI sended by nRF20L01
Set Ss                                                      'Set SS back to high level
End Sub

Setup_rx:                                                   'Setup for RX
D_bytes(1) = Write_reg + Rx_addr_p0                         'RX adress for pipe0
D_bytes(2) = &H34
D_bytes(3) = &H43
D_bytes(4) = &H10
D_bytes(5) = &H10
D_bytes(6) = &H01
Call W_register(6)                                          'Send 6 bytes to SPI
D_bytes(1) = Write_reg + En_aa                              'Enable auto ACK for pipe0
D_bytes(2) = &H01
Call W_register(2)
D_bytes(1) = Write_reg + En_rxaddr                          'Enable RX adress for pipe0
D_bytes(2) = &H01
Call W_register(2)
D_bytes(1) = Write_reg + Rf_ch                              'Set RF channel
D_bytes(2) = 40
Call W_register(2)
'#################################
D_bytes(1) = Write_reg + Rx_pw_p0                           'Set RX pload width for pipe0
D_bytes(2) = 32
Call W_register(2)
'#################################
D_bytes(1) = Write_reg + Rf_setup                           'Setup RF-> Output power 0dbm, datarate 2Mbps and LNA gain on
D_bytes(2) = &H0F
Call W_register(2)
D_bytes(1) = Write_reg + Config_nrf                         'Setup CONFIG-> PRX=1(RX_device), PWR_UP=1, CRC 2bytes, Enable CRC
D_bytes(2) = &H0F
Call W_register(2)
Return

Setup_tx:                                                   'Setup for TX
D_bytes(1) = Write_reg + Tx_addr                            'TX adress
D_bytes(2) = &H34
D_bytes(3) = &H43
D_bytes(4) = &H10
D_bytes(5) = &H10
D_bytes(6) = &H01
Call W_register(6)
D_bytes(1) = Write_reg + Rx_addr_p0                         'RX adress for pipe0
D_bytes(2) = &H34
D_bytes(3) = &H43
D_bytes(4) = &H10
D_bytes(5) = &H10
D_bytes(6) = &H01
Call W_register(6)
D_bytes(1) = Write_reg + En_aa                              'Enable auto ACK for pipe0
D_bytes(2) = &H01
Call W_register(2)
D_bytes(1) = Write_reg + En_rxaddr                          'Enable RX adress for pipe0
D_bytes(2) = &H01
Call W_register(2)
D_bytes(1) = Write_reg + Rf_ch                              'Set RF channel
D_bytes(2) = 40
Call W_register(2)
D_bytes(1) = Write_reg + Rf_setup                           'Setup RF-> Output power 0dbm, datarate 2Mbps and LNA gain on
D_bytes(2) = &H0F
Call W_register(2)
D_bytes(1) = Write_reg + Config_nrf                         'Setup CONFIG-> PRX=0(TX_device), PWR_UP=1, CRC 2bytes, Enable CRC
D_bytes(2) = &H0E
Call W_register(2)
Return

'###############################################################################

Sub Send595(byval Pattern As Word)
  Shiftout Data_out , Clock_out , Pattern , 0 , 16 , Shift_delay       'send pattern
  Set Latch_out                                             'latch shift reg to outputs
  NOP                                                       'wait abit
  Reset Latch_out                                           'latch off, data written
End Sub

'###############################################################################

Sub Eeprom_iras(byval Cim As Word , Byval Ertek As Byte)
   Local Addresshigh As Byte , Addresslow As Byte
   Addresshigh = High(cim)
   Addresslow = Low(cim)

   I2cstart                                                 'start utasitas
   I2cwbyte 160                                             'eeprom hw cime
   I2cwbyte Addresshigh                                     'EEPROM felso cime
   I2cwbyte Addresslow                                      'EEPROM also cime
   I2cwbyte Ertek                                           'ertek tarolasa
   I2cstop                                                  'stop utasitas

   'Print "EEPROM-ba irva Cim: " ; Cim ; " Ertek: " ; Ertek  'Debug
End Sub

'###############################################################################

Function Eeprom_olvasas(byval Cim As Word) As Byte
Local Felsocim As Byte , Alsocim As Byte , Eredmeny As Byte

   Felsocim = High(cim)
   Alsocim = Low(cim)

   I2cstart                                                 'start utasitas
   I2cwbyte 160                                             'EEPROM hw cime (irasi!)
   I2cwbyte Felsocim                                        'EEPROM felso cime
   I2cwbyte Alsocim                                         'EEPROM also cime
   I2cstart                                                 'ujra start
   I2cwbyte 161                                             'EEPROM hw cime (olvasasi)
   I2crbyte Eredmeny , Nack                                 'eredmeny tarolas
   I2cstop                                                  'stop utasitas

   'Print "EEPROM-bol olvasva Cim: " ; Cim ; " Eredmeny: " ; Eredmeny       'Debug
   Eeprom_olvasas = Eredmeny
End Function

'###############################################################################
Getdatetime:
  I2cstart                                                  ' Generate start code
  I2cwbyte Ds1307w                                          ' send address
  I2cwbyte 0                                                ' start address in 1307

  I2cstart                                                  ' Generate start code
  I2cwbyte Ds1307r                                          ' send address
  I2crbyte _sec , Ack
  I2crbyte _min , Ack                                       ' MINUTES
  I2crbyte _hour , Ack                                      ' Hours
  I2crbyte Weekday , Ack                                    ' Day of Week
  I2crbyte _day , Ack                                       ' Day of Month
  I2crbyte _month , Ack                                     ' Month of Year
  I2crbyte _year , Nack                                     ' Year
  I2cstop
  _sec = Makedec(_sec) : _min = Makedec(_min) : _hour = Makedec(_hour)
  _year = Makedec(_year) : _month = Makedec(_month) : _day = Makedec(_day)
Return

'###############################################################################

Setdate:
  _day = Makebcd(_day) : _month = Makebcd(_month) : _year = Makebcd(_year)
  I2cstart                                                  ' Generate start code
  I2cwbyte Ds1307w                                          ' send address
  I2cwbyte 4                                                ' starting address in 1307
  I2cwbyte _day                                             ' Send Data to SECONDS
  I2cwbyte _month                                           ' MINUTES
  I2cwbyte _year                                            ' Hours
  I2cstop
Return

'###############################################################################

Settime:
  _sec = Makebcd(_sec) : _min = Makebcd(_min) : _hour = Makebcd(_hour)
  I2cstart                                                  ' Generate start code
  I2cwbyte Ds1307w                                          ' send address
  I2cwbyte 0                                                ' starting address in 1307
  I2cwbyte _sec                                             ' Send Data to SECONDS
  I2cwbyte _min                                             ' MINUTES
  I2cwbyte _hour                                            ' Hours
  I2cstop
Return

End