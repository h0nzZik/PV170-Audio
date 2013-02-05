module gen_triangle (
	out,
	freq,

	sys_clk,
	sys_clk_freq,
	duty,
	debug_out,
	debug_led
);


input		[13:0]	freq;				// 1 Hz to 16 kHz
input		[31:0]	sys_clk_freq;	// > 1 MHz (>= 2^20 Hz)
input					sys_clk;

output	[23:0]	out;
reg		[23:0]	out;

input		[7:0]		duty;				// 1 to 255
output	[31:0]	debug_out;
output				debug_led;

// generate 'data_reset' clock

reg data_reset;
gen_clock data_reset_clock
(
	.clock_in(sys_clk),
	.in_freq(sys_clk_freq),
	.out_freq(freq),
	.clock_out(data_reset)
);


/*
// sys_clk_freq at least 2^20 Hz (sizeof(tmp) - no_bits(sys_clock_freq) + 1)))
// 2x faster
wire [20:0] increment;
wire [20:0] decrement;

wire [31:0] time_to_change;
reg [31:0] time_elapsed;


assign debug_out = decrement;


wire	[45:0]	big_f;	// 14 bits == frequency,
						// 24 bits == output range, 
						// 8  bits == duty

assign big_f = (freq << (24+8)) / sys_clk_freq;
assign increment = (duty != 0) ? (big_f / duty) : 0;
assign decrement = big_f / (256 - duty);

wire	[39:0]	duty_freq;
assign duty_freq = sys_clk_freq * duty;
assign time_to_change = duty_freq / (256 * freq);

*/

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
		else
		begin
			out <= out - decrement;
		end
	end
	last_reset <= data_reset;
end





endmodule
