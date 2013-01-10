module gen_square (
	clock,
	clock_freq,
	out_freq,
	out
);

input clock;
input [31:0]clock_freq;
input [31:0]out_freq;
output [23:0]out;

reg [31:0]div;
reg [31:0]cnt;


always@(clock_freq or out_freq)
begin
	div <= clock_freq / (2*out_freq);
end


always@(posedge clock)
begin
	if (div == cnt)
	begin
		cnt <= 0;
		if (out == 0)
			out <= 8_000_000;
		else
			out <= 0;
	end
	else
	begin
		cnt <= cnt + 1;	
	end

end

endmodule
