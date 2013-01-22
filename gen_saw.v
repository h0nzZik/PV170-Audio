module gen_saw (
	out,
	freq,

	sys_clk,
	sys_clk_freq,
	debug_out
);

input	[31:0]	freq;
input	[31:0]	sys_clk_freq;
input			sys_clk;

output	[23:0]	out;
reg [23:0] out;


output [31:0] debug_out;


// generate 'data_reset' clock

reg data_reset;
gen_clock data_reset_clock
(
	.clock_in(sys_clk),
	.in_freq(sys_clk_freq),
	.out_freq(2*freq),
	.clock_out(data_reset)
);

reg way;	//up or down

reg [31+24:0] increment;
//assign increment = 32'h7fffff * freq / sys_clk_freq;
assign debug_out = increment;


// calculate increment
always@( * )
begin
	increment = 32'h7fffff * freq / sys_clk_freq;
end



always@(posedge data_reset)
begin
	way = ~way;
end

reg old_way;
always@(posedge sys_clk)
begin
	if (old_way != way)
		out <= 0;
	else
	begin
		if (way)
			out <= out - increment;
		else
			out <= out + increment;
	
	end
	
	old_way <= way;

end



endmodule
