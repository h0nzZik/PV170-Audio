module gen_square (
	clock,
	clock_freq,
	out_freq,
	out
);

input clock;
input clock_freq;
input out_freq;
reg div;
reg cnt;
output [15:0]out;

always@(clock_freq or out_freq)
begin
	div <= clock_freq / (2*out_freq);
end


always@(posedge clock)
begin
	if (div == cnt)
	begin
		cnt <= 0;
		out <= ~out;
	end
	else
	begin
		cnt <= cnt + 1;	
	end

end

endmodule