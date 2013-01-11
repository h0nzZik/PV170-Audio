/**
 *  nios_DE2_demo -- demo design for Altera DE2 kit
 *    * Key0 act as reset
 *    * Key1 bliks red LED's
 *
 */

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
		
		
		/* GPIO pins */
		GPIO_0,
		
		// I2C pins
		I2C_SCLK,
		I2C_SDAT
		);
	
	input CLK;
	input	[3:0]	KEY;
	input	[17:0]	SW;
	output	[8:0]	LEDG;					
    output	[17:0]	LEDR;
    

	output I2C_SCLK;
	output I2C_SDAT;
	
	/* some audio pins */
	//output AUD_BCLK;
	//output AUD_DACLRCK;
	output AUD_DACDAT;
	input AUD_BCLK;
	input AUD_DACLRCK;
	
	output [35:0]GPIO_0;
//    wire clk_div;

	reg [17:0] LEDS;
	
	assign LEDR = LEDS;
	
	//assign LEDR = KEY[1] ?  SW : 18'h3FFFF;
    wire rst;
	assign rst = KEY[0];
	



/*************************************************************/


	/*
	//wire sqr_data;
	reg [23:0] sqr_data;
	gen_square sqr
	(
		.clock(CLK),
		.clock_freq(50_000_000),
		.out_freq(500),
		.out(sqr_data)
	);
*/
	
	audio_codec audio_out
	(
		.daclrc(AUD_DACLRCK),
		.bclk(AUD_BCLK),
		.dacdat(AUD_DACDAT),
		// data
		.data_left(i2c_data << 16),
		.data_right(i2c_data << 16),

//		.data_left(sqr_data),
//		.data_right(sqr_data),
		
		// system clock
		.sys_clk(CLK),
		.sys_clk_freq(50_000_000)
	);

	always@(*)
	begin
		GPIO_0[6] = AUD_DACLRCK;
		GPIO_0[7] = AUD_BCLK;
	end
	
	/*
	audio_codec audio_test
	(
		.daclrc(GPIO_0[6]),
		.bclk(GPIO_0[7]),
		.dacdat(GPIO_0[8]),

		.data_left(0),
		.data_right(0),

		.sys_clk(CLK),
		.sys_clk_freq(50_000_000)
	);

	*/



gen_clock some_test
 (
	.clock_in(CLK),
	.in_freq(50_000_000),
	.clock_out(LEDS[5]),
	.out_freq(4)
 
 );
 /*
gen_clock gpio_test
(
	.clock_in(CLK),
	.in_freq(50_000_000),
	.clock_out(GPIO_0[0]),
	.out_freq(500000)
);
 */
 
 /*
  // data to send
 reg [7:0] i2c_data;
 
 always@(posedge KEY[3])
 begin
	i2c_data <= SW[7:0];
 
 end
 
 
 reg write;
 reg done;
 i2c_write writer
 (
	.sda(GPIO_0[1]),
	.scl(GPIO_0[2]),

	.addr(8'h35),
	.register(8'h04),
	.data(i2c_data),
	
	.sys_clk(CLK),
	.sys_freq(50_000_000),
	.i2c_freq(10_000),
	.write(write),
	.done(done)
 );
 
 reg [7:0] phase;
 reg working;
 always@(posedge CLK)
 begin
	// Send it all
	if (phase == 0)
	begin
		if (working == 0 && done == 0)
		begin
			working <= 1;
			write <= 1;
		end
		if (working == 1 && done == 1)
		begin
			write <= 0;
			working <= 0;
			phase <= 0;		// there is only one phase ;)
		end
	end
	
	if (phase == 1)
	begin
		// never happens
	end
 end
 */
 // Send 8'b00010000 to register 8'b00000101
 
 
 
 i2c_write i2c_codec
 (
	.sda(I2C_SDAT),
	.scl(I2C_SCLK),

	.addr(8'h35),
	.register(config_reg),
	.data(config_data),
	
	.sys_clk(CLK),
	.sys_freq(50_000_000),
	.i2c_freq(10_000),
	.write(write_codec),
	.done(done_codec)
 );

 reg [7:0] config_data, config_reg;
 
 reg [7:0]config_phase = 0;
 reg config_working;
 always@(posedge CLK)
 begin
	// Master mode
	if (config_phase == 0)
	begin
		LEDS[0] <= 1;
		if (config_working == 0 && done_codec == 0)
		begin
			config_data <= 8'b01001010;	// default | master
			config_reg <= 8'b00000111;
			config_working <= 1;
			write_codec <= 1;
		end
		
		if (config_working == 1 && done_codec == 1)
		begin
			write_codec <= 0;
			config_working <= 0;
			config_phase <= 1;			
		end
	
	end
 
	// Turn it up
	if(config_phase == 1)
	begin
		LEDS[1] <= 1;
		if (config_working == 0 && done_codec == 0)
		begin
			config_data <=8'b00010000;	// turn on
			config_reg <= 8'h05;
			config_working <= 1;
			write_codec <= 1;
		end
	
		if (config_working == 1 && done_codec == 1)
		begin
			write_codec <= 0;
			config_working <= 0;
			config_phase <= 2;
		end
	end
	
	if (config_phase == 2)
	begin
		LEDS[2] <= 1;
	end
 
 end
 
 
 /* test I2C */
 /*
 reg i2c_clk;
 
 gen_clock i2c_sys_clock
 (
	.clock_in(CLK),
	.in_freq(50_000_000),
	.clock_out(i2c_clk),
	.out_freq(10_000)
 
 );
 
 reg i2c_start;
 reg i2c_stop;
 reg i2c_write;
 reg i2c_done;
 reg i2c_status;
 
 i2c my_bus
 (
	.sda(GPIO_0[1]),
	.scl(GPIO_0[2]),
	.start(i2c_start),
	.stop(i2c_stop),
	.data(i2c_data),
	.write(i2c_write),
	.cmd_done(i2c_done),
	.cmd_status(i2c_status),
	.sys_clk(i2c_clk)
 );
 
 

 
 
 
 
 reg [7:0] state = 0;
 reg phase_done = 0;
 always@(posedge CLK)
 begin
 
	// send start bit
	if (state == 0)
	begin
		// transition to state=0
		if (i2c_done == 1 && phase_done == 0)
			;	// do_nothing
		// do once: send start bit
		if (i2c_done == 0 && phase_done == 0)
		begin
			i2c_start <= 1;
			phase_done <= 1;
		end
		if (i2c_done == 1 && phase_done == 1 )
		// clear request bit
		begin
			i2c_start <= 0;
			phase_done <= 0;
			state <= 1;
		
		end
	
	end
	
	// send data
	if (state == 1)
	begin
		// transition from state=0 to state=1
		if (i2c_done == 1 && phase_done == 0)
			; //do nothing
		// do once: send data
		if (i2c_done == 0 && phase_done == 0)
		begin
			i2c_write <= 1;
			phase_done <= 1;
		end
		// clear request bit
		if (i2c_done == 1 && phase_done == 1)
		begin
			i2c_write <= 0;
			phase_done <= 0;
			state <= 2;
		end
	end
	
	// send stop bit
	
	if (state == 2)
	begin
		if (i2c_done == 0 && phase_done == 0)
		begin
			i2c_stop <= 1;
			phase_done <= 1;
		end
		
		if (i2c_done == 1 && phase_done == 1)
		begin
			i2c_stop <= 0;
			phase_done <= 0;
			state <= 0;		
		end
	
	end
 
 
 end
 
 */
 
 
/**************************************************************	
	clk_div divider1
(
	.CLK(CLK) ,	// input  CLK_sig
	.RST(rst) ,	// input  RST_sig
	.CLK_DIV(clk_div) 	// output  CLK_DIV_sig
);
    defparam divider1.divider = 25_000_000;

	always@(posedge CLK)
	begin
	
	if(!rst) 
		LEDS <= 8'b0;
	else if(clk_div)
		begin
		
			LEDS <= LEDS * 2 + (LEDS[17] ? 1'b0 : 1'b1) ;
		
		end
	end
********************************************************************/	
endmodule
