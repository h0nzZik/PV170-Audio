module gen_clock(
	clock_in,
	in_freq,
	clock_out,
	out_freq
);


input clock_in;
input [31:0]in_freq;
input [31:0]out_freq;
output clock_out;

reg [31:0]lim;
reg [31:0]cnt;


always@(in_freq or out_freq)
begin
	/* something magic */
	lim <= in_freq / (2*out_freq) - 1;
end


always@(posedge clock_in)
begin
	if (cnt >= lim)
	begin
		cnt <= 0;
		clock_out <= ~clock_out;
	end
	else
	begin
		cnt <= cnt + 1;	
	end
end



endmodule