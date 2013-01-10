include <SystemVerilog>;

module mixer(
	/* input data */
	data_in,

	/* output */
	data_out
);

input [15:0]data_in [7:0]; 


/* data output */
output [15:0]data_out;
reg [15:0]data_out;


always@( * )
begin
	reg [3+15:0] data;
	reg i;
	data = 0;
	
	for(i=0; i<8; i = i + 1)
	begin
		data = data + data_in[i];
	end
	
	data_out = data >> 3;

end




endmodule
