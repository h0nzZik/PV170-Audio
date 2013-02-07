module vol
(
	in,
	vol,
	out
);


input		[23:0]	in;
output	[23:0]	out;
input		[7:0]		vol;

wire [23+8:0] tmp;
assign tmp = vol * in;
assign out = tmp[23+8:8];

endmodule
