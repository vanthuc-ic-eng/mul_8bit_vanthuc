create_clock -name vclk -period 10.0

set_input_delay -clock vclk 2.0 [get_ports {<Input_1>[*]}]
set_input_delay -clock vclk 2.0 [get_ports {<Input_2>[*]}]
set_output_delay -clock vclk 2.0 [get_ports {<Output>[*]}]

set_load 0.05 [get_ports {<Output>[*]}]
set_driving_cell -lib_cell BUF_X1 [get_ports {<Input_1>[*] <Input_2>[*]}]
