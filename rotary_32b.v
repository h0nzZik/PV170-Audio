/**
 * Rotary encoder driver
 */

module rotary_32b
(
	A,
	B,
	data,
	bound_upper,
	bound_lower,
	sys_clk,
	sys_clk_freq,
	udelay
);

input sys_clk;

input [31:0]	bound_upper;
input [31:0]	bound_lower;
input [31:0]	sys_clk_freq;
input [31:0]	udelay;
input A;
input B;

output	[31:0]	data;
reg		[31:0]	data;



/* bounce filter timer */
reg [31:0] incm;
reg trig_it;
monostable m
(
	.usec(udelay),
	.sys_clk(sys_clk),
	.sys_clk_freq(sys_clk_freq),
	.start(trig_it),
	.incomplete(incm)
);



reg A_last;
reg B_last;
reg lock;
/*
always@(posedge sys_clk)
begin
	// bounce filter 
	if (trig_it == 1 && A == 1 && B == 1)
	begin
		trig_it <= 0;
	end
	else if (incm == 0)	// <unlocked>
	begin
		if (A == 1 && B == 1 && lock == 1)
			lock <= 0;
		if (A_last == 1 &&  A == 0 && lock == 0)
		begin
			if (B == 1 && data != bound_upper)
			begin
				data <= data + 1;
			end
			if (B == 0 && data != bound_lower)
			begin
				data <= data - 1;
			end
		
			trig_it <= 1;
			lock <= 1;
		end
	end	// </unlocked>

	A_last <= A;
	B_last <= B;
end
*/
reg [2:0] state;
always@(posedge sys_clk)
begin
	if (state == 0)
	begin
		if (A == 1 && B == 0)
		begin
			if (data < bound_upper)
				data <= data + 1;
			state <= 1;
			trig_it <= 1;
		end
		else if (A == 0 && B == 1)
		begin
			if (data > bound_lower)
				data <= data - 1;
			state <= 1;
			trig_it <= 1;		
		end
		else if (A == 0 && B == 0)
		begin
			state <= 4;
		end
	end
	
	if (state == 1)
	begin
		trig_it <= 0;
		state <= 2;
	end
	
	if (state == 2)
	begin
		if (incm == 0)
			state <= 4;
	end

	
	if (state == 4)
	begin
		if (A == 1 && B == 1)
			state <= 0;
	end
	
	A_last <= A;
	B_last <= B;	
end

endmodule
