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
		GPIO_0
		);
	
	input CLK;
	input	[3:0]	KEY;
	input	[17:0]	SW;
	output	[8:0]	LEDG;					
    output	[17:0]	LEDR;
    

	/* some audio pins */
	output AUD_BCLK;
	output AUD_DACLRCK;
	output AUD_DACDAT;
	
	
	output [35:0]GPIO_0;
//    wire clk_div;

	reg [17:0] LEDS;
	
	assign LEDR = LEDS;
	
	//assign LEDR = KEY[1] ?  SW : 18'h3FFFF;
    wire rst;
	assign rst = KEY[0];
	



/*************************************************************/


	
	//wire sqr_data;
	reg [23:0] sqr_data;
	gen_square sqr
	(
		.clock(CLK),
		.clock_freq(50_000_000),
		.out_freq(500),
		.out(sqr_data)
	);

	
	audio_codec audio_out
	(
		.daclrc(AUD_DACLRCK),
		.bclk(AUD_BCLK),
		.dacdat(AUD_DACDAT),
		// data
		.data_left(sqr_data),
		.data_right(sqr_data),

		// system clock
		.sys_clk(CLK),
		.sys_clk_freq(50_000_000)
	);

	
	/*
	audio_codec audio_test
	(
		.daclrc(LEDS[0]),
		.bclk(LEDS[1]),
		.dacdat(LEDS[2]),

		.data_left(sqr_data),
		.data_right(sqr_data),

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
 

 
 /* test I2C */
 
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
	.data(16'h5A),
	.write(i2c_write),
	.cmd_done(i2c_done),
	.cmd_status(i2c_status),
	.sys_clk(i2c_clk)
 );
 
 
 /* test it */
 reg [7:0] state = 0;
 reg phase_done = 0;
 always@(posedge CLK)
 begin
 
	/* send start bit */
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
