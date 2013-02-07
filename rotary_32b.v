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



/* filter */
reg [31:0] lock;
reg trig_it;
monostable m
(
	.usec(udelay),
	.sys_clk(sys_clk),
	.sys_clk_freq(sys_clk_freq),
	.start(trig_it),
	.incomplete(lock)
);



reg A_last;
always@(posedge sys_clk)
begin
	/* filter */
	if (lock != 0)
	begin
		trig_it <= 0;
	end
	else	// <unlocked>
	begin

		if (A_last == 1 &&  A == 0)
		begin
			if (B == 1 && data < bound_upper)
				data <= data + 1;
			if (B == 0 && data > bound_lower)
				data <= data - 1;
			trig_it <= 1;
		end
	end	// </unlocked>

	A_last <= A;
end


endmodule
