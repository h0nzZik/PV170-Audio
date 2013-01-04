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
		LEDR
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
	
endmodule
