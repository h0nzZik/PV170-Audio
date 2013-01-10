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
    

	/* some audio pins */
	output AUD_BCLK;
	output AUD_DACLRCK;
	output AUD_DACDAT;
	
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
		/* */
		.data_left(sqr_data),
		.data_right(sqr_data),

		/* system clock */
		.sys_clk(CLK),
		.sys_clk_freq(50_000_000)
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
