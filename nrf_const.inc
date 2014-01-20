$nocompile

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
Const Fifo_status = &H17                                    'FIFO Status Register' register address

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
D_bytes(1) = Write_reg + Rx_pw_p0                           'Set RX pload width for pipe0
D_bytes(2) = 5
Call W_register(2)
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

Dump_registers:                                             'Dumps all nRF24L01 registers to the terminal, handy for debugging
Print "* Dump nRF24L01 Registers *"
Call R_register(config_nrf , 1)
Print "CONFIG : " ; Bin(b_bytes(1))
Call R_register(en_aa , 1)
Print "EN_AA : " ; Bin(b_bytes(1))
Call R_register(en_rxaddr , 1)
Print "EN_RXADDR : " ; Bin(b_bytes(1))
Call R_register(setup_aw , 1)
Print "SETUP_AW : " ; Bin(b_bytes(1))
Call R_register(setup_retr , 1)
Print "SETUP_RETR : " ; Bin(b_bytes(1))
Call R_register(rf_ch , 1)
Print "RF_CH : " ; B_bytes(1)
Call R_register(rf_setup , 1)
Print "RF_SETUP : " ; Bin(b_bytes(1))
Call R_register(status , 1)
Print "STATUS : " ; Bin(b_bytes(1))
Call R_register(observe_tx , 1)
Print "OBSERVE_TX : " ; Bin(b_bytes(1))
Call R_register(cd , 1)
Print "CD : " ; Bin(b_bytes(1))
Call R_register(rx_addr_p0 , 5)
Print "RX_ADDR_P0 : " ; Hex(b_bytes(1)) ; Hex(b_bytes(2)) ; Hex(b_bytes(3)) ; Hex(b_bytes(4)) ; Hex(b_bytes(5))
Call R_register(rx_addr_p1 , 5)
Print "RX_ADDR_P1 : " ; Hex(b_bytes(1)) ; Hex(b_bytes(2)) ; Hex(b_bytes(3)) ; Hex(b_bytes(4)) ; Hex(b_bytes(5))
Call R_register(rx_addr_p2 , 5)
Print "RX_ADDR_P2 : " ; Hex(b_bytes(1)) ; Hex(b_bytes(2)) ; Hex(b_bytes(3)) ; Hex(b_bytes(4)) ; Hex(b_bytes(5))
Call R_register(rx_addr_p3 , 5)
Print "RX_ADDR_P3 : " ; Hex(b_bytes(1)) ; Hex(b_bytes(2)) ; Hex(b_bytes(3)) ; Hex(b_bytes(4)) ; Hex(b_bytes(5))
Call R_register(rx_addr_p4 , 5)
Print "RX_ADDR_P4 : " ; Hex(b_bytes(1)) ; Hex(b_bytes(2)) ; Hex(b_bytes(3)) ; Hex(b_bytes(4)) ; Hex(b_bytes(5))
Call R_register(rx_addr_p5 , 5)
Print "RX_ADDR_P5 : " ; Hex(b_bytes(1)) ; Hex(b_bytes(2)) ; Hex(b_bytes(3)) ; Hex(b_bytes(4)) ; Hex(b_bytes(5))
Call R_register(tx_addr , 5)
Print "TX_ADDR : " ; Hex(b_bytes(1)) ; Hex(b_bytes(2)) ; Hex(b_bytes(3)) ; Hex(b_bytes(4)) ; Hex(b_bytes(5))
Call R_register(rx_pw_p0 , 5)
Print "RX_PW_P0 : " ; Hex(b_bytes(1)) ; Hex(b_bytes(2)) ; Hex(b_bytes(3)) ; Hex(b_bytes(4)) ; Hex(b_bytes(5))
Call R_register(rx_pw_p1 , 5)
Print "RX_PW_P1 : " ; Hex(b_bytes(1)) ; Hex(b_bytes(2)) ; Hex(b_bytes(3)) ; Hex(b_bytes(4)) ; Hex(b_bytes(5))
Call R_register(rx_pw_p2 , 5)
Print "RX_PW_P2 : " ; Hex(b_bytes(1)) ; Hex(b_bytes(2)) ; Hex(b_bytes(3)) ; Hex(b_bytes(4)) ; Hex(b_bytes(5))
Call R_register(rx_pw_p3 , 5)
Print "RX_PW_P3 : " ; Hex(b_bytes(1)) ; Hex(b_bytes(2)) ; Hex(b_bytes(3)) ; Hex(b_bytes(4)) ; Hex(b_bytes(5))
Call R_register(rx_pw_p4 , 5)
Print "RX_PW_P4 : " ; Hex(b_bytes(1)) ; Hex(b_bytes(2)) ; Hex(b_bytes(3)) ; Hex(b_bytes(4)) ; Hex(b_bytes(5))
Call R_register(rx_pw_p5 , 5)
Print "RX_PW_P5 : " ; Hex(b_bytes(1)) ; Hex(b_bytes(2)) ; Hex(b_bytes(3)) ; Hex(b_bytes(4)) ; Hex(b_bytes(5))
Call R_register(fifo_status , 1)
Print "FIFO_STATUS : " ; Bin(b_bytes(1))
Return