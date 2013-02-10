/**
 * Audio -- simple audio application
 */
 include <SystemVerilog>;
 
module audio (
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
input 		CLK;		//
input	[3:0]	KEY;
input	[17:0]	SW;
input	[35:0]	GPIO_0;

output	[8:0]	LEDG;					
output	[17:0]	LEDR;
/* I2C IO */
output		I2C_SCLK;
inout		I2C_SDAT;
/* some audio pins */
output		AUD_XCK;
output		AUD_DACDAT;
inout		AUD_BCLK;
inout		AUD_DACLRCK;

/* Internals */

reg	[17:0]	LEDS = 0;
wire		rst;
wire		enc_a;
wire		enc_b;


assign LEDR = LEDS;
assign rst = KEY[0];

assign enc_a = GPIO_0[0];
assign enc_b = GPIO_0[1];


/* rotary encoder test */
/*
assign LEDS[11] = enc_a;
assign LEDS[12] = enc_b;

reg	[31:0]	rot_data;

rotary_32b	rot0
(
	.A(enc_a),
	.B(enc_b),
	.data(rot_data),
	.bound_upper(255),
	.bound_lower(0),
	.sys_clk(CLK),
	.sys_clk_freq(50_000_000),
	.udelay(50_000)
);


assign LEDS[9:2] = rot_data[7:0];
*/


/* memory test */

reg		mem_in;
reg		mem_out;
reg		c_16Hz;
reg		c_ram;
reg	[3:0]	mem_addr;	// 16B memory
reg	[1:0]	mem_phase;
reg		wren;
reg		q;


/* need some clock */
gen_clock clock_16Hz
(
	.clock_in	(CLK),
	.in_freq	(50_000_000),
	.out_freq	(16),
	.clock_out	(c_16Hz)
);

/* need some clock for RAM */
gen_clock clock_ram
(
	.clock_in	(CLK),
	.in_freq	(50_000_000),
	.out_freq	(10_000),
	.clock_out	(c_ram)
);

/* and also need some RAM */
ram ram1
(
	.address	(mem_addr),
	.clock		(c_ram),
	.q		(mem_out),
	.wren		(wren),
	.data		(mem_in)
);

/* Memory control block (stupid, FIXME) */
always@(posedge c_16Hz)
begin
	/* setup it for read */
	if (mem_phase == 0)
	begin
		wren <= 0;
	end
	else
	/* read it */
	if (mem_phase == 1)
	begin
		q <= mem_out;
	end
	else
	/* setup for write */
	if (mem_phase == 2)
	begin
		wren <= 1;
		mem_in <= (q || ~KEY[2]) && KEY[3];
	end
	else
	if (mem_phase == 3)
	begin
		wren <= 0;
		mem_addr <= mem_addr + 1;
	end

	mem_phase <= mem_phase + 1;
end

assign LEDS[17:2] = 1 << (15 - mem_addr);

assign LEDG[1] = q;

/*************************/
/* Let's play some music */

reg 	[7:0]	incm;
reg	[7:0]	state;
reg	[31:0]	f;

/* Use monostable circuit */
monostable m0
(
	.usec		(2_000_000),
	.sys_clk	(CLK),
	.sys_clk_freq	(50_000_000),
	.incomplete	(incm),
	.start		(~KEY[1])
);

/* play-a-chord demo */
always@(posedge KEY[1])
begin
	if (state == 0) begin
			f <= 700;
			state <= state + 1;
	end else if (state == 1) begin
			f <= 882;
			state <= state + 1;
	end else begin
			f <= 1049;
			state <= 0;
	end
end


/* Triangular data with simple color control */
reg	[23:0]	tr_data;
wire	[7:0]	duty_0;
wire	[23+8:0]mtr;
wire	[23+8:0]mtr_data;

assign mtr = tr_data * incm;
assign mtr_data = mtr / 255;
assign duty_0 = (SW[15:8] == 0)? 8'd1 : SW[15:8];
// One day there will be rotary encoder instead of switches
//assign duty_0 = (rot_data == 0)? 8'd1 : rot_data;

/* Need some signal */
gen_triangle t0
(
	.out		(tr_data),
	.freq		(f),
	.sys_clk	(CLK),
	.sys_clk_freq	(50_000_000),
	.duty		(duty_0)
);


/* Simple output volume control */
always@( * )
begin
	data_left  = mtr_data / (5'd16 - SW[3:0]);
	data_right = mtr_data / (5'd16 - SW[7:4]);
end

reg signed [23:0] data_left;
reg signed [23:0] data_right;

/* Audio output */
audio_codec audio_out
(
	/* audio pins */
	.daclrc		(AUD_DACLRCK),
	.bclk		(AUD_BCLK),
	.dacdat		(AUD_DACDAT),
	.xck		(AUD_XCK),
	/* data pins */
	.data_left	(data_left),
	.data_right	(data_right),
	/* system pins */
	.sys_clk	(CLK),
	.sys_clk_freq	(50_000_000),
	.reset		(rst),
	/* I2C pins */
	.i2c_scl	(I2C_SCLK),
	.i2c_sda	(I2C_SDAT)
);


/* Blink with some LED */
gen_clock some_test
(
	.clock_in	(CLK),
	.in_freq	(50_000_000),
	.clock_out	(LEDG[8]),
	.out_freq	(1) 
);
 
endmodule
