/*
 * Cast ovladace k tomu audio chipu
 */
 
 module audio_codec (
	/* Audio chip connections */
	daclrc,
	bclk,
	dacdat,
	
	/* sound source connection */
	data_left,
	data_right,
	test_counter
 );
 
 input bclk;
 input daclrc;
 output dacdat; reg dacdat;
 
 input [15:0] data_left;
 input [15:0] data_right;
 
 reg [31:0]bit_counter;

  
 reg [31:0]test_counter;
 output test_counter;
 always@(negedge bclk)
 begin
	test_counter <= test_counter +1;
	/* reset it? */
	if (daclrc)
		bit_counter <= 0;	

	/* falling edge */
	else
	begin
		/* send bit? */
		if (bit_counter < 2*16)
		begin
			/* left channel */
			if (bit_counter < 16)
			begin
				dacdat <= (data_left >> (15 - bit_counter)) & 1;
			end
			/* right channel */
			else
			begin
				dacdat <= (data_right >> (31 - bit_counter)) & 1;
			end
			/* increment counter */
			bit_counter <= bit_counter + 1;	
		end // send bit?
	
	end
 
	/* transfer only 2*16 bits */

 end
 
 
 
 endmodule