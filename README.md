# UART_verilog
This project involves the implementation of the UART communication protocol on an FPGA device using Verilog coding within the Xilinx Vivado tool. 
It consists of three Verilog files and an IP catalogue file for fifo generator. 
I created distinct files for transmission and reception purposes, each featuring an oversampling counter of 16 and a baud rate of 9600, with a clock frequency of 100 MHz.
The main Verilog file (uart_main) acts as the source and instantiates both the reception (uart_rx_main) and transmission (uart_tx_main) files,and fifo_generate file as a register.
To provide a visual representation of the system, I have also attached an image file depicting the elaborated design.

Thank you for considering my work.

