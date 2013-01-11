include <SystemVerilog>;


module i2c (
	sda,
	scl, 
	
	start,		// send start bit
	stop,		// send stop bit
	
	block,		// 
	
	data,
	write,

	cmd_ok,
	cmd_err
	sys_clk
);

input write;
input start;
input stop;
input sys_clk;
input [7:0] data;

output sda; reg sda = 1'bz;
output scl; reg scl = 1'bz;


output cmd_ok; reg cmd_ok = 0;
output cmd_err; reg cmd_err = 0;
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
reg [2:0] bit_no;
always@(posedge sys_clk)
begin
	/* only if sda == 1 and scl == 1 */
	if (start == 1)
	begin
		sda <= 0;
		cmd_ok <= 1;
		/* perform reset.. */
		cycle <= 0;
		bit_no <= 0;
	end
	
	if (write == 1)
	begin
		if (cycle == 0)
			scl <= 1'b0;	// low

		if (cycle == 1)
			if (data[bit_no] == 1)
				sda <= 1'bz;
			else
				sda <= 1b'0;
		
		if (cycle == 2)
			scl <= 1'bz;	// high

		if (cycle == 3)
		begin
			if (bit_no == 3b'7)
			begin
				cmd_ok <= 1b'1;
				bit_no <= 3b'0;
			end
			else
			begin
				bit_no <= bit_no + 3b'1;
			end
		end
		cycle <= cycle + 3b'1;
		
	
	end
end




endmodule
