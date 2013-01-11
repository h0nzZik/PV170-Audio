include <SystemVerilog>;


module i2c (
	sda,
	scl, 
	
	start,		// send start bit
	stop,		// send stop bit
	
	
	data,
	write,

	cmd_done,
	cmd_status,
	sys_clk
);

input write;
input start;
input stop;
input sys_clk;
input [7:0] data;

output sda; reg sda = 1'bz;
output scl; reg scl = 1'bz;


output cmd_done; reg cmd_done = 0;
output cmd_status; reg cmd_status = 0;
/* watch */

reg lock = 0;

reg sda_last = 1;
always@(posedge sys_clk)
begin

	if (scl == 1)
	begin
		/* falling edge <=> START operation */
		if ( sda_last == 1 && sda == 0)
		begin
			lock <= 1;
		end
		
		/* raising edge <=> STOP operation */
		if (sda_last == 0 && sda == 1)
		begin
			lock <= 0;		
		end
	
	end
	sda_last <= sda;
end

/* main driver */


reg [1:0] cycle;
reg [3:0] bit_no;

reg ack_bit;

always@(posedge sys_clk)
begin

	// cmd ok on start
	if (start == 1)
		cmd_done <= 1;
	else
	// 
	if (stop == 1 && cycle == 3)
		cmd_done <= 1;
	else
	// Tx finished
	if (write == 1'b1 && bit_no == 4'd8 && cycle == 2'd3)
	begin
		cmd_status <= ack_bit;
		cmd_done <= 1;
	end
	// Nothing
	else
		cmd_done <= 0;
		
	// Start bit
	// requires sda == 1 and scl == 1
	if (start == 1)
	begin
		sda <= 0;
		cmd_done <= 1;
		// and sometimes perform 'reset'..
		cycle <= 0;
		bit_no <= 0;
	end
	
	// requires sda == 0 and scl == 1
	if (stop == 1)
	begin
		if (cycle == 0)
		begin
			scl <= 1'b0;
		end
		
		if (cycle == 1)
		begin
			sda <= 1'b0;
		end
		
		if (cycle == 2)
		begin
			scl <= 1'bz;
		end
		
		if (cycle == 3)
		begin
			sda <= 1'bz;		
		end
		
		cycle <= cycle + 2'b1;
	
	end
	
	/* write to i2c */
	if (write == 1)
	begin
		// falling edge
		if (cycle == 0)
			scl <= 1'b0;

		// data Tx
		if (cycle == 1)

			// this bit may be pulled down by a slave, so..
			if (bit_no == 4'd8)
				sda <= 1'bz;
			else
			// send data
			if (data[7 - bit_no] == 1)
				sda <= 1'bz;
			else
				sda <= 1'b0;
		
		// raising edge
		if (cycle == 2)
			scl <= 1'bz;

		// nothing but..
		if (cycle == 3)
			if (bit_no == 4'd8)
			begin
				/* there may be acknoledgement */
				ack_bit <= sda;
				bit_no <= 4'd0;
			end
			else
				bit_no <= bit_no + 4'b1;

		cycle <= cycle + 2'b1;
		
	
	end
end




endmodule
