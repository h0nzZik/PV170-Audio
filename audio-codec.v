/*
 * Cast ovladace k tomu audio chipu
 */
 
 module audio_codec (
	/* Audio chip connections */
	daclrc,
	bclk,
	dacdat,
	xck,
	
	/* sound source connection */
	data_left,
	data_right,
	
	/* system clock */
	sys_clk,
	sys_clk_freq
 );
 /*
 output bclk; reg bclk;
 output daclrc; reg daclrc;
 */
 /*
 input bclk;
 input daclrc;
 */
 output xck;
 
 input bclk;
 //output bclk;
 input daclrc;
 //output daclrc;
 
 output dacdat; reg dacdat;
 
 input [23:0] data_left;
 input [23:0] data_right;
 
 input sys_clk;
 input [31:0] sys_clk_freq;
 
 reg [31:0]bit_counter;

  
 
 /* 'I2C Mode' block */
 
 /* generate BCLK and DACLRC signal */
 
 reg sc;		// synchronization
 reg [7:0] counter;
 gen_clock sync
 (
	.clock_in(sys_clk),
	.in_freq(sys_clk_freq),
	.clock_out(sc),
	.out_freq(48_000 * 256 * 2)
//	.out_freq(48_000 * 50 * 2)
// 	.out_freq(1)
 );
 

 always@(negedge sc)
 begin
	xck <= ~xck;
  end
  
  reg old_daclrc;
  always@(negedge bclk)
  begin
  /*
	if (counter >= 1 && counter <= 24)
		dacdat <= data_left[24-counter];
	else if (counter >= 129 && counter <= 152)
			dacdat <= data_right[152 - counter];
	else
		dacdat <= 0;

	if (old_dacdat == 1 && dacdat == 0)
		counter <= 1;
	else
		counter <= counter + 1;
	*/
	if (old_daclrc != daclrc)
		counter <= 0;
	else if (counter < 24)
	begin
		if (daclrc)
			dacdat <= data_right[24-counter];
		else
			dacdat <= data_left[24-counter];		
		counter <= counter + 1;
	end
	else
		dacdat <= 0;
	
	
	old_daclrc <= daclrc;
  end
/* 
 always@(negedge sc)
 begin
	// bclk will go down
	if (bclk == 1)
	begin
	
		// left channel
//		if (counter == 0)
//			daclrc <= 0;
		//else
		if (counter >= 1 && counter <= 24)
			dacdat <= data_left[24-counter];
		//	dacdat <= 1;

		// right channel
//		else if (counter == 128)
//			daclrc <= 1;
		else if (counter >= 129 && counter <= 152)
			dacdat <= data_right[152 - counter];
//			dacdat <= 1;
		else
			dacdat <= 0;

	
		// increment counter 
		counter <= counter + 8'b1;
	end
 
//	bclk <= ~bclk;
	
end
*/
 endmodule
 