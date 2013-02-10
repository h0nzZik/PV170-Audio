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

/* Inputs */
input	[31:0]	sys_clk_freq;	// FIXME
input		sys_clk;	// clock
input	[31:0]	usec;		// how many microseconds would you like?
input		start;		// input
/* Outputs */
output	[7:0]	incomplete;	// 'percentage' of completetion


/* Internals */

reg		usec_clock;
reg		usec_clock_last;
reg	[31:0]	usec_lapsed;
reg	[31:0]	usec_sampled;

/* Create 1 us timer */
gen_clock data_reset_clock
(
	.clock_in(sys_clk),
	.in_freq(sys_clk_freq),
	.out_freq(1_000_000),
	.clock_out(usec_clock)
);


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
		if (usec_clock_last == 0 && usec_clock == 1)
		begin
		if (usec_lapsed < usec)
			usec_lapsed <= usec_lapsed + 1;
		end

	end
	usec_clock_last <= usec_clock;
end

wire	[31+8:0]	_incomplete;
wire	[31+8:0]	usec_remain;

assign	usec_remain	= (usec_sampled - usec_lapsed) * 255;
assign	_incomplete	= (usec_remain / usec_sampled);
assign	incomplete	= _incomplete[7:0];

endmodule
