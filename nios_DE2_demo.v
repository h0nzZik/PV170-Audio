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

/* duty */
/*
reg [7:0] duty_0;


always@( * )
begin
	if (SW[15:8] == 0)
		duty_0 = 8'b1;
	else
		duty_0 = SW[15:8];
end
*/

wire [7:0] duty_0;
assign duty_0 = (SW[15:8] == 0)? 8'd1 : SW[15:8];
reg [23:0] tr_data;
gen_triangle t0
(
	.out(tr_data),
	.freq(700),
	.sys_clk(CLK),
	.sys_clk_freq(50_000_000),
	.duty(duty_0),
	.debug_out(tmp),
	.debug_led(LEDS[0])
);


gen_saw saw0
(
	.out(my_data),
	.freq(700),
	.sys_clk(CLK),
	.sys_clk_freq(50_000_000)
);

reg [31:0] tmp;

//assign LEDS[17:4] = tmp[13:0];

// volume ctrl
always@( * )
begin
	data_left = my_data / (5'd16 - SW[3:0]);
	data_right = tr_data /(5'd16 - SW[7:4]);
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


// led blinking
gen_clock some_test
 (
	.clock_in(CLK),
	.in_freq(50_000_000),
	.clock_out(LEDS[1]),
	.out_freq(1)
 
 );
 
gen_clock gpio_test
(
	.clock_in(CLK),
	.in_freq(50_000_000),
	.clock_out(GPIO_0[0]),
	.out_freq(500000)
);
 
 
 
endmodule
