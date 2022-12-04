###################################################################

# Created by write_sdc on Thu Dec 1 15:50:16 2022

###################################################################
set sdc_version 2.1

set_units -time ns -resistance kOhm -capacitance pF -voltage V -current mA
set_max_area 0
create_clock [get_ports CLK]  -period 5  -waveform {0 2.5}
