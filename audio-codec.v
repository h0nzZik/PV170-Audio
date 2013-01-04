/*
 * Cast ovladace k tomu audio chipu
 */
 
 module audio_codec (
	/* Audio chip connections */
	daclrc,
	bclk,
	adcdat,
	
	/* sound source connection */
	data_left,
	data_right,
 );
 
 input bclrc;
 input daclk;
 output adcdat;
 
 input [15:0] data_left;
 input [15:0] data_right;
 output data_request;
 
 reg bit_counter;
 
 /* clear bit counter */
 always@(posedge adclrc)
 begin

	bit_counter <= 0;
 
 end
 
 always@(negedge bclk)
 begin
	/* transfer only 2*16 bits */
	if (bit_counter < 2*16)
	begin
		/* left channel */
		if (bit_counter < 16)
		begin
			adcdat <= (data_left >> bit_counter) & 1;
		end
		/* right channel */
		else
		begin
			adcdat <= (data_right >> (bit_counter - 16)) & 1;
		end
		/* increment counter */
		bit_counter <= bit_counter + 1;	
	end 
 end
 
 
 
 endmodule