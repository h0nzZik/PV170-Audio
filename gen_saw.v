module gen_saw (
	out,
	freq,

	sys_clk,
	sys_clk_freq
);

input	[15:0]	freq;
input	[31:0]	sys_clk_freq;
input			sys_clk;

output	[23:0]	out;
reg 	[23:0]	out;





// generate 'data_reset' clock

wire data_reset;
gen_clock data_reset_clock
(
	.clock_in(sys_clk),
	.in_freq(sys_clk_freq),
	.out_freq(freq),
	.clock_out(data_reset)
);


// sys_clock_freq at least 2^20 Hz (sizeof(tmp) - no_bits(sys_clock_freq))))
reg [19:0] increment;

// calculate increment
always@( * )
begin
	reg [39:0]tmp;
	tmp = freq << 24;
	increment = tmp / sys_clk_freq;
end

reg last_reset;
always@(posedge sys_clk)
begin
	if ((data_reset == 1) && (last_reset == 0)) begin
		out <= 0;
	end else begin
		out <= out + increment;
	end
	last_reset <= data_reset;
end



endmodule
