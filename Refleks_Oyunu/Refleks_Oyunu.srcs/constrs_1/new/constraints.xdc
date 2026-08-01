# 100 MHz Clock
set_property PACKAGE_PIN W5 [get_ports clk]
    set_property IOSTANDARD LVCMOS33 [get_ports clk]

# USB-UART TX Ç?k??? (FPGA -> PC)
set_property PACKAGE_PIN A18 [get_ports tx]
    set_property IOSTANDARD LVCMOS33 [get_ports tx]

# Butonlar
set_property PACKAGE_PIN U18 [get_ports btnC] 
    set_property IOSTANDARD LVCMOS33 [get_ports btnC]

set_property PACKAGE_PIN T18 [get_ports btnU] 
    set_property IOSTANDARD LVCMOS33 [get_ports btnU]

set_property PACKAGE_PIN T17 [get_ports btnR] 
    set_property IOSTANDARD LVCMOS33 [get_ports btnR]

set_property PACKAGE_PIN U17 [get_ports btnD] 
    set_property IOSTANDARD LVCMOS33 [get_ports btnD]

# tx_done için LED 0
set_property PACKAGE_PIN U16 [get_ports led0]
    set_property IOSTANDARD LVCMOS33 [get_ports led0]

#7 segment display
set_property PACKAGE_PIN W7 [get_ports {seg[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[0]}]
set_property PACKAGE_PIN W6 [get_ports {seg[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[1]}]
set_property PACKAGE_PIN U8 [get_ports {seg[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[2]}]
set_property PACKAGE_PIN V8 [get_ports {seg[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[3]}]
set_property PACKAGE_PIN U5 [get_ports {seg[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[4]}]
set_property PACKAGE_PIN V5 [get_ports {seg[5]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[5]}]
set_property PACKAGE_PIN U7 [get_ports {seg[6]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[6]}]

set_property PACKAGE_PIN V7 [get_ports dp]							
	set_property IOSTANDARD LVCMOS33 [get_ports dp]

set_property PACKAGE_PIN U2 [get_ports {an[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {an[0]}]
set_property PACKAGE_PIN U4 [get_ports {an[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {an[1]}]
set_property PACKAGE_PIN V4 [get_ports {an[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {an[2]}]
set_property PACKAGE_PIN W4 [get_ports {an[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {an[3]}]

# Switchler (Gönderilecek Veri - data_in)
#set_property PACKAGE_PIN V17 [get_ports {sw[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {sw[0]}]
#set_property PACKAGE_PIN V16 [get_ports {sw[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {sw[1]}]
#set_property PACKAGE_PIN W16 [get_ports {sw[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {sw[2]}]
#set_property PACKAGE_PIN W17 [get_ports {sw[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {sw[3]}]
#set_property PACKAGE_PIN W15 [get_ports {sw[4]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {sw[4]}]
#set_property PACKAGE_PIN V15 [get_ports {sw[5]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {sw[5]}]
#set_property PACKAGE_PIN W14 [get_ports {sw[6]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {sw[6]}]
#set_property PACKAGE_PIN W13 [get_ports {sw[7]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {sw[7]}]

set_property PACKAGE_PIN R2 [get_ports reset]
    set_property IOSTANDARD LVCMOS33 [get_ports reset]

#Konfigürasyon
set_property PACKAGE_PIN T1 [get_ports {conf[3]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {conf[3]}]
set_property PACKAGE_PIN U1 [get_ports {conf[2]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {conf[2]}]
set_property PACKAGE_PIN W2 [get_ports {conf[1]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {conf[1]}]
set_property PACKAGE_PIN R3 [get_ports {conf[0]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {conf[0]}]

set_property PACKAGE_PIN T2 [get_ports eleme]
    set_property IOSTANDARD LVCMOS33 [get_ports eleme]

set_property PACKAGE_PIN T3 [get_ports zor_mod]
    set_property IOSTANDARD LVCMOS33 [get_ports zor_mod]

