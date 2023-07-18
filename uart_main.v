`timescale 1ns / 1ps


module uart_main
    #(
        parameter DBIT = 8,     // # data bits
                  SB_TICK = 16  // # stop bit ticks                  
     )     
    (
        input clk, reset_n,
        
        // receiver port
        output [DBIT - 1: 0] r_data,
        input rd_uart,
        output rx_empty,
        input rx,
        
        // transmitter port
        input [DBIT - 1: 0] w_data,
        input wr_uart,
        output tx_full,
        output tx
        
        
    );
    
   
    // Receiver
    wire rx_done_tick;
    wire [DBIT - 1: 0] rx_dout;
    uart_rx_main #(.DBIT(DBIT), .SB_TICK(SB_TICK)) receiver(
        .clk(clk),
        .reset_n(reset_n),
        .rx(rx),
        .rx_done_tick(rx_done_tick),
        .rx_dout(rx_dout)
    );
    
    fifo_generator_0 rx_FIFO (
        .clk(clk),          // input wire clk
        .srst(~reset_n),    // input wire srst
        .din(rx_dout),      // input wire [7 : 0] din
        .wr_en(rx_done_tick),  // input wire wr_en
        .rd_en(rd_uart),    // input wire rd_en
        .dout(r_data),      // output wire [7 : 0] dout
        .full(),            // output wire full
        .empty(rx_empty)    // output wire empty
    );

    // Transmitter
    wire tx_fifo_empty, tx_done_tick;
    wire [DBIT - 1: 0] tx_din;
    uart_tx_main #(.DBIT(DBIT), .SB_TICK(SB_TICK)) transmitter(
        .clk(clk),
        .reset_n(reset_n),
        .tx_start(~tx_fifo_empty),
        .tx_din(tx_din),
        .tx_done_tick(tx_done_tick),
        .tx(tx)
    );
    
    fifo_generator_0 tx_FIFO (
        .clk(clk),          // input wire clk
        .srst(~reset_n),    // input wire srst
        .din(w_data),      // input wire [7 : 0] din
        .wr_en(wr_uart),  // input wire wr_en
        .rd_en(tx_done_tick),    // input wire rd_en
        .dout(tx_din),      // output wire [7 : 0] dout
        .full(tx_full),            // output wire full
        .empty(tx_fifo_empty)    // output wire empty
    );    
endmodule


