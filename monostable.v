/**
 * Monostable circuit
 */

module monostable 
(
	usec,
	sys_clk,
	sys_clk_freq,
	start,
	incomplete
);

input		[31:0]	sys_clk_freq;	// > 1 MHz (>= 2^20 Hz)
input				sys_clk;
input		[31:0]	usec;			// how many microseconds would you like?
input				start;			// input
output		[7:0]	incomplete;		// 'percentage'


reg		usec_clock;
gen_clock data_reset_clock
(
	.clock_in(sys_clk),
	.in_freq(sys_clk_freq),
	.out_freq(1_000_000),
	.clock_out(usec_clock)
);

reg		[31:0]	usec_lapsed;
reg		[31:0]	usec_sampled;


reg usec_clk_last;
always@(posedge sys_clk)
begin
	// start timing
	if (start)
	begin
		usec_lapsed <= 0;
		usec_sampled <= usec;		
	
	end
	// increment counter on raising edge of usec_clock
	else
	begin
		if (usec_clk_last == 0 && usec_clock == 1)
		begin
		if (usec_lapsed < usec)
			usec_lapsed <= usec_lapsed + 1;
		end

	end
	usec_clk_last <= usec_clock;
end


wire		[31+8:0]	usec_remain;
assign	usec_remain = (usec_sampled - usec_lapsed) * 255;

wire		[31+8:0]	_incomplete;
assign	_incomplete	= (usec_remain / usec_sampled);
assign	incomplete = _incomplete[7:0];

/* calculate how many 'percents' left */



endmodule
