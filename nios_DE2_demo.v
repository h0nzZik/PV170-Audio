/**
 *  nios_DE2_demo -- demo design for Altera DE2 kit
 *    * Key0 act as reset
 *    * Key1 bliks red LED's
 *
 */

 include <SystemVerilog>;
 
module nios_DE2_demo (
		CLK,
		KEY,
		SW,
		LEDG,
		LEDR,
		/* some audio pins */
		AUD_DACLRCK,
		AUD_DACDAT,
		AUD_BCLK,
		AUD_XCK,
		/* GPIO pins */
		GPIO_0,
		/* I2C pins */
		I2C_SCLK,
		I2C_SDAT
);
	
/* general IOs	*/
input 			CLK;
input	[3:0]	KEY;
input	[17:0]	SW;
output	[8:0]	LEDG;					
output	[17:0]	LEDR;
/* I2C IO */
output			I2C_SCLK;
inout			I2C_SDAT;
/* some audio pins */
output			AUD_XCK;
output			AUD_DACDAT;
inout			AUD_BCLK;
inout			AUD_DACLRCK;
output	[35:0]	GPIO_0;
reg		[17:0]	LEDS;


assign LEDR = LEDS;
wire rst;
assign rst = KEY[0];
	



/*************************************************************/

reg signed [4:0] test;

 // generate audio data
reg signed [23:0] my_data;
/*
always@(posedge CLK)
begin
	test <= test + 1;
	if (my_data + 37 > my_data)
		my_data <= my_data + 37;
	else
		my_data <= 0;
end
*/

gen_saw saw0
(
	.out(my_data),
	.freq(700),
	.sys_clk(CLK),
	.sys_clk_freq(50_000_000),
	.debug_out(tmp)
);

reg [31:0] tmp;

assign LEDS[17:7] = tmp[10:0];

// volume ctrl
always@( * )
begin
	data_left = my_data / (17 - SW[3:0]);
	if (my_data > 0)
		data_right = 24'h7fffff;
	else
		data_right = 0;
//	data_right = my_data / (16 - SW[7:4]);
	LEDS[3:0] = SW[3:0];
end

reg signed [23:0] data_left;
reg signed [23:0] data_right;


audio_codec audio_out
(
	/* audio pins */
	.daclrc			(AUD_DACLRCK),
	.bclk			(AUD_BCLK),
	.dacdat			(AUD_DACDAT),
	.xck			(AUD_XCK),
	/* data pins */
	.data_left		(data_left),
	.data_right		(data_right),
	/* system pins */
	.sys_clk		(CLK),
	.sys_clk_freq	(50_000_000),
	.reset			(rst),
	/* I2C pins */
	.i2c_scl		(I2C_SCLK),
	.i2c_sda		(I2C_SDAT)
);

/*
// audio communication sniffing
 
 always@(posedge CLK)
 begin
 
	if (AUD_DACLRCK == 1)
		GPIO_0[4] <= 1;
	else
		GPIO_0[4] <= 0;
	
	if (AUD_BCLK == 1)
		GPIO_0[5] <= 1;
	else
		GPIO_0[5] <= 0;
		
	if (AUD_DACDAT == 1)
		GPIO_0[6] <= 1;
	else
		GPIO_0[6] <= 0;
 
 end

// i2c communication sniffing
 
 always@(posedge CLK)
 begin
 
	if (I2C_SDAT == 1)
		GPIO_0[2] <= 1;
	else
		GPIO_0[2] <= 0;
	
	if (I2C_SCLK == 1)
		GPIO_0[3] <= 1;
	else
		GPIO_0[3] <= 0;
 
 end
*/
// led blinking
gen_clock some_test
 (
	.clock_in(CLK),
	.in_freq(50_000_000),
	.clock_out(LEDS[5]),
	.out_freq(4)
 
 );
 
gen_clock gpio_test
(
	.clock_in(CLK),
	.in_freq(50_000_000),
	.clock_out(GPIO_0[0]),
	.out_freq(500000)
);
 
 
 
endmodule
