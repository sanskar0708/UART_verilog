`timescale 1ns / 1ps


module uart_tx_main
    #(parameter DBIT = 8,    
                SB_TICK = 16 
    )
    (
        input clk, reset_n,
        input tx_start,        
        input [DBIT - 1:0] tx_din,
        output reg tx_done_tick,
        output tx
        
    );
    
    localparam  idle = 0, start = 1,
                data = 2, stop = 3;
                
    reg [1:0] state_reg, state_next;
    reg [3:0] s_reg, s_next;               
    reg [$clog2(DBIT) - 1:0] n_reg, n_next;
    reg [DBIT - 1:0] b_reg, b_next;        
    reg tx_reg, tx_next; 
    reg s_tick; 
    reg [10:0] baud;
    reg [10:0] rate=10'd650;               
    
    
always @(posedge clk, negedge reset_n)
begin
if(~reset_n)
	begin
	baud<=0;
	s_tick<=0;
	end
else
	begin
		if(baud<rate-1)
		begin
		baud<=baud+1;
		s_tick<=0;
		end
		else if(baud==rate-1)
			begin
			s_tick<=1;
			baud<=0;
			end
	end
		
end
    
    
    // State and other registers
    always @(posedge clk, negedge reset_n)
    begin
        if (~reset_n)
        begin
            state_reg <= idle;
            s_reg <= 0;
            n_reg <= 0;
            b_reg <= 0;
            tx_reg <= 1'b1;
        end
        else
        begin
            state_reg <= state_next;
            s_reg <= s_next;
            n_reg <= n_next;
            b_reg <= b_next;
            tx_reg <= tx_next;
        end
    end
    
    // Next state logic
    always @(*)
    begin
        state_next = state_reg;
        s_next = s_reg;
        n_next = n_reg;
        b_next = b_reg;
        tx_done_tick = 1'b0;
        case (state_reg)
            idle:   
            begin    
                tx_next = 1'b1;         
                if (tx_start)
                begin
                    s_next = 0;
                    b_next = tx_din;
                    state_next = start;                        
                end
            end                 
            start:    
            begin
                tx_next = 1'b0;            
                if (s_tick)
                    if (s_reg == 15)
                    begin
                        s_next = 0;
                        n_next = 0;
                        state_next = data;
                    end
                    else                        
                        s_next = s_reg + 1;
            end                                                                                       
            data:
            begin
                tx_next = b_reg[0];
                if (s_tick)
                    if(s_reg == 15)
                    begin
                        s_next = 0;
                        b_next = {1'b0, b_reg[DBIT - 1:1]}; // Right shift
                        if (n_reg == (DBIT - 1))
                            state_next = stop;
                        else
                            n_next = n_reg + 1;
                    end
                    else
                        s_next = s_reg + 1;
            end
            stop:
            begin
                tx_next = 1'b1;
                if (s_tick)
                    if(s_reg == (SB_TICK - 1))
                    begin
                        tx_done_tick = 1'b1;
                        state_next = idle;
                    end
                    else
                        s_next = s_reg + 1;                        
            end
            default:
                state_next = idle;
        endcase
    end
    
    // output logic
    assign tx = tx_reg;

endmodule
