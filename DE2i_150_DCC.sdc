#**************************************************************
# Create Clock
#**************************************************************
create_clock -period 20 [get_ports CLOCK_50]
create_clock -period 20 [get_ports CLOCK2_50]
create_clock -period 20 [get_ports CLOCK3_50]
		

create_clock -period 10 [get_ports HSMC_ADA_DCO]
create_clock -period 10 [get_ports HSMC_ADB_DCO]

create_clock -period 10 [get_ports HSMC_FPGA_CLK_A_N]
create_clock -period 10 [get_ports HSMC_FPGA_CLK_A_P]
create_clock -period 10 [get_ports HSMC_FPGA_CLK_B_N]
create_clock -period 10 [get_ports HSMC_FPGA_CLK_B_P]

