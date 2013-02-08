module rom2i2c (
	rom_addr,
	rom_clk,
	rom_out,
	
	i2c_sda,
	i2c_scl,
	
	sys_clk,
	sys_clk_freq,
	
	nres
);

/* memory interaction */
output [7:0] rom_addr;
reg [7:0] rom_addr;
output rom_clk;
reg rom_clk;
input [7:0] rom_out;

input nres;
/* i2c communication */
output			i2c_sda;
inout			i2c_scl;

/* system stuff */
input	[31:0]	sys_clk_freq;
input			sys_clk;




/* Create I2C writer */

reg i2c_addr;
reg i2c_reg;
reg i2c_data;
reg i2c_write;
reg i2c_done;
i2c_write i2c
 (
	.sda		(i2c_sda),
	.scl		(i2c_scl),

	.addr		(i2c_addr),		// Codec's address
	.register	(i2c_reg),
	.data		(i2c_data),
	
	.sys_clk	(sys_clk),
	.sys_freq	(sys_clk_freq),
	.i2c_freq	(4*10_000),
	.write		(i2c_write),
	.done		(i2c_done)
 );

 

 
 
 reg [1:0]rom_rdclk;
 always@(posedge sys_clk)
 begin
	if (rom_rdclk[1] == 0 && rom_rdclk[0] == 1)
	begin
		;
	end
	rom_rdclk[1] <= rom_rdclk[0];
 end
 

endmodule
