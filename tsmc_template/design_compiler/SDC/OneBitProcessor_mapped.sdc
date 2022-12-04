###################################################################

# Created by write_sdc on Sat Dec 3 20:25:52 2022

###################################################################
set sdc_version 2.1

set_units -time ns -resistance kOhm -capacitance pF -voltage V -current mA
set_max_area 0
create_clock [get_ports CLK]  -period 100  -waveform {0 50}
