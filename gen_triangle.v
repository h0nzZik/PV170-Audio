module gen_triangle (
	out,
	freq,

	sys_clk,
	sys_clk_freq,
	duty
);


input		[13:0]	freq;				// 1 Hz to 16 kHz
input		[31:0]	sys_clk_freq;	// > 1 MHz (>= 2^20 Hz)
input					sys_clk;

output	[23:0]	out;
reg		[23:0]	out;

input		[7:0]		duty;				// 1 to 255

// generate 'data_reset' clock

reg data_reset;
gen_clock data_reset_clock
(
	.clock_in(sys_clk),
	.in_freq(sys_clk_freq),
	.out_freq(freq),
	.clock_out(data_reset)
);



/* new and better */
wire	[31:0]	ticks_per_period;
wire	[31:0]	ticks_up;
wire	[31:0]	ticks_dn;
reg	[31:0]	ticks_elapsed = 0;

assign ticks_per_period = sys_clk_freq / freq;
assign ticks_up	= duty * (ticks_per_period >> 4'h8);
assign ticks_dn	= ticks_per_period - ticks_up;

wire [23:0] increment;
wire [23:0] decrement;

assign increment = (ticks_up == 32'h0)? 25'h0: 25'h1000000 / ticks_up;
assign decrement = (ticks_dn == 32'h0)? 25'h0: 25'h1000000 / ticks_dn;

reg last_reset=0;
always@(posedge sys_clk)
begin
	/* Periodic reset */
	if ((data_reset == 1) && (last_reset == 0))
	begin
		out <= 0;
		ticks_elapsed <= 0;
	end
	else
	begin
		if (ticks_elapsed < ticks_up)
		begin
			out <= out + increment;
			ticks_elapsed <= ticks_elapsed + 1;
		end
		else if (ticks_elapsed < ticks_per_period)
		begin
			out <= out - decrement;
			ticks_elapsed <= ticks_elapsed + 1;
		end
		else
		begin
			/* reset */
			out <= 0;
			ticks_elapsed <= 0;
			
		end
	end
	last_reset <= data_reset;
end





endmodule
