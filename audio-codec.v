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
	sys_clk_freq,
	
	/* I2C pins */
	i2c_sda,
	i2c_scl,
	
	/* reset */
	reset
 );
 
output	xck;	reg	xck;
input	bclk;
input daclrc;
output dacdat;	reg dacdat;

input	[23:0]	data_left;	// signed
input	[23:0]	data_right;	// signed


input	[31:0]	sys_clk_freq;
input			sys_clk;
input			reset; 

output			i2c_sda;
inout			i2c_scl;
 
 
 
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
 );
 

 /* generate crystal signal */
 
 always@(negedge sc)
 begin
	xck <= ~xck;
 end
  
  reg old_daclrc;
  always@(negedge bclk)
  begin
	if (old_daclrc != daclrc)
		counter <= 0;
	else if (counter < 24)
	begin
		if (daclrc)
			dacdat <= data_right[24-counter];
		else
			dacdat <= data_left[24-counter];		
		counter <= counter + 1'b1;
	end
	else
		dacdat <= 0;
	
	
	old_daclrc <= daclrc;
  end

/////////////////////////////////////////////
///////////////////// Memory ////////////////
/////////////////////////////////////////////
 
/*
 reg [7:0] addr;
 reg [7:0] rom_out;
 reg rom_clk;
 
 config_rom rom
 (
	.address(addr),
	.clock(rom_clk),
	.q(rom_out)
 );
 
 rom2i2c r2i
 (
	.rom_addr(addr),
	.rom_clk(rom_clk),
	.rom_out(rom_out),
	
	.i2c_sda(i2c_sda),
	.i2c_scl(i2c_scl)
 );
 
 
 
 */
 
 /////////////////////
 // Setup the Codec //
 /////////////////////
 


 reg write_codec;
 reg done_codec;
 
 reg [7:0] config_data;
 reg [7:0] config_reg;
 
 i2c_write i2c_codec
 (
	.sda(i2c_sda),
	.scl(i2c_scl),

	.addr(8'h34),		// Codec's address
	.register(config_reg),
	.data(config_data),
	
	.sys_clk(sys_clk),
	.sys_freq(sys_clk_freq),
	.i2c_freq(4*10_000),
	.write(write_codec),
	.done(done_codec)
 );
 

 /***********************************/
 /*	Power on && Reset configuration	*/
 /***********************************/
 
 
 
 reg [7:0] config_phase = 0;
 reg config_working;
 always@(posedge sys_clk)
 begin
	// device reset
	// (wait for an event)
	if (config_phase == 0)
	begin
		config_phase <= 10;
	end
 
 
	// Reset
	if (config_phase == 10)
	begin
		if (config_working == 0 && done_codec == 0)
		begin
			config_data <= 8'b00000000;	// Reset
			config_reg <=  8'b00011110;	// Reset register
			config_working <= 1;
			write_codec <= 1;
		end
		
		if (config_working == 1 && done_codec == 1)
		begin
			write_codec <= 0;
			config_working <= 0;
			config_phase <= 20;
		end
	
	end

	
	// Power ON
	if(config_phase == 20)
	begin
		if (config_working == 0 && done_codec == 0)
		begin
			config_data <=8'b00000000;		
			config_reg <= 8'b00001100;
			config_working <= 1;
			write_codec <= 1;
		end
	
		if (config_working == 1 && done_codec == 1)
		begin
			write_codec <= 0;
			config_working <= 0;
			config_phase <= 30;
		end
	end


	// Turn soft mute off 
	if (config_phase == 30)
	begin
		if (config_working == 0 && done_codec == 0)
		begin
			config_data <= 8'b00000110;		// /DACMU
			config_reg <=  8'b00001010;		// 
			config_working <= 1;
			write_codec <= 1;
		end
		
		if (config_working == 1 && done_codec == 1)
		begin
			write_codec <= 0;
			config_working <= 0;
			config_phase <= 40;			
		end
	
	end

	// Enable DAC output
	if(config_phase == 40)
	begin
		if (config_working == 0 && done_codec == 0)
		begin
			config_data <=8'b00111000;		// DACSEL + MUTEMIC 
			config_reg <= 8'b00001000;		// analog audio path control
			config_working <= 1;
			write_codec <= 1;
		end
	
		if (config_working == 1 && done_codec == 1)
		begin
			write_codec <= 0;
			config_working <= 0;
			config_phase <= 50;
		end
	end

	// Master mode
	if (config_phase == 50)
	begin
		if (config_working == 0 && done_codec == 0)
		begin
			config_data <= 8'b01001010;	// default | master
			config_reg <=  8'b00001110;	// R7 - Digital audio interface format
			config_working <= 1;
			write_codec <= 1;
		end
		
		if (config_working == 1 && done_codec == 1)
		begin
			write_codec <= 0;
			config_working <= 0;
			config_phase <= 60;
		end
	
	end

	// Set it active
	if(config_phase == 60)
	begin
		if (config_working == 0 && done_codec == 0)
		begin
			config_data <=8'b00000001;		
			config_reg <= 8'b00010010;
			config_working <= 1;
			write_codec <= 1;
		end
	
		if (config_working == 1 && done_codec == 1)
		begin
			write_codec <= 0;
			config_working <= 0;
			config_phase <= 100;
		end
	end

	/***
		RESET feature is OFF
							***/
	/* reset on 'reset' posedge signal */
	if (config_phase == 100)
	begin
	/*
		if (reset == 1)
			config_phase <= 0;
	*/
	end
	
 
 end
 
 
 
 endmodule
 