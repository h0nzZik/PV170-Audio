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
		AUD_BCLK
		);
	
	input CLK;
	input	[3:0]	KEY;
	input	[17:0]	SW;
	output	[8:0]	LEDG;					
    output	[17:0]	LEDR;
    
	
    wire clk_div;
    wire rst;
	reg [17:0] LEDS;
	
	assign LEDR = LEDS;
	
	//assign LEDR = KEY[1] ?  SW : 18'h3FFFF;
	assign rst = KEY[0];
	



/*************************************************************/

	input AUD_BCLK;
	input AUD_DACLRCK;
	output AUD_DACDAT;
	
	//wire sqr_data;
	reg [15:0] sqr_data;
	gen_square sqr
	(
		.clock(CLK),
		.clock_freq(40_000_000),
		.out_freq(500),
		.out(sqr_data),
	);
/*
	always@(sqr_data)
	begin
		LEDS <= sqr_data;
		if (sqr_data > 32768)
			LEDG[5] <= 1;
		else
			LEDG[5] <= 0;
	end
	*/


	reg [31:0] test;
	always@(test)
	begin
		LEDG[1] <= 1;
		LEDG[2] <= ~LEDG[2];
		LEDS <= test;
	end
	
	
	always@(posedge AUD_BCLK)
	begin
		LEDG[3] <= ~LEDG[3];
		
	end

	always@(negedge AUD_BCLK)
	begin
		LEDG[4] <= ~LEDG[4];
	end

	always@(AUD_BCLK)
	begin
		LEDG[5] <= ~LEDG[5];
		
	end


	
	audio_codec audio_out
	(
		.daclrc(AUD_DACLRCK),
		.bclk(AUD_BCLK),
		.dacdat(AUD_DACDAT),
		/* */
		.data_left(sqr_data),
		.data_right(sqr_data),
		.test_counter(test),
	
	);

	
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
