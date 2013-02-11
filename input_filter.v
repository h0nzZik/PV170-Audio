module input_filter
(
	in,
	out,
	
	sys_clk,
	nres
);

input		in;
output		out;
	
input		sys_clk;
input		nres;

reg		last_nres;
reg		out;
reg	[19:0]	state;
always@(posedge sys_clk)
begin
	if (nres == 1 && last_nres == 0)
		state <= 20'h800000;
	else if (in == 1 && state < 20'hFFFFFF)
		state <= state + 1;
	else if (in == 0 && state > 20'h000000)
		state <= state - 1;
	last_nres <= nres;
	
	if (out == 1 && state < 20'h400000)
		out <= 0;
	else if (out == 0 && state > 20'hC00000)
		out <= 1;
end


endmodule
