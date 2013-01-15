/* TODO: check lock */

include <SystemVerilog>;

module i2c_write (
	sda,
	scl,
	
	addr,
	register,
	data,
	
	sys_clk,
	sys_freq,
	i2c_freq,
	write,
	done
);


input [31:0] sys_freq;
input [31:0] i2c_freq;
input sys_clk;
input write;

input [6:0] addr;		// 7b address
input [7:0] register;
input [7:0] data;

inout sda;
output scl;

output done; reg done;

 reg i2c_clk;
 
 gen_clock i2c_sys_clock
 (
	.clock_in(sys_clk),
	.in_freq(sys_freq),
	.clock_out(i2c_clk),
	.out_freq(i2c_freq)
 
 );
 
 reg i2c_start;
 reg i2c_stop;
 reg i2c_write;
 reg i2c_done;
 reg i2c_status;
 
 
 reg [7:0]i2c_data;
 reg [7:0]i2c_addr;
 reg [7:0]i2c_reg;
 
 reg [7:0]data_being_sent;
 
 i2c my_bus
 (
	.sda(sda),
	.scl(scl),
	.start(i2c_start),
	.stop(i2c_stop),
	.data(data_being_sent),
	.write(i2c_write),
	.cmd_done(i2c_done),
	.cmd_status(i2c_status),
	.sys_clk(i2c_clk)
 );
 



 /* test it */
 reg [7:0] state = 0;
 reg phase_done = 0;
 always@(posedge sys_clk)
 begin
 
	/* can we start transmittion? */
	if (state == 0)
	begin

		if (done)
			done <= 0;

		else if (write == 1)
		begin
			state <= 1;
			i2c_data <= data;
			i2c_addr <= addr;
			i2c_reg  <= register;
		end
		

	end
 
 
	/* Start bit */
	if (state == 1)
	begin
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
			state <= 2;
		
		end
	
	end
	
	// Address
	if (state == 2)
	begin
		// do once: send data
		if (i2c_done == 0 && phase_done == 0)
		begin
			data_being_sent <= i2c_addr;
			i2c_write <= 1;
			phase_done <= 1;
		end
		// clear request bit
		if (i2c_done == 1 && phase_done == 1)
		begin
			i2c_write <= 0;
			phase_done <= 0;
		
			state <= 3;
			/*
			if (i2c_status == 1)
					state <= 3;
				else
					state <= 20;	//some error
			*/
		end
	end
	
	// Register
	
	if (state == 3)
	begin
		if (i2c_done == 0 && phase_done == 0)
		begin
			data_being_sent <= i2c_reg;
			i2c_write <= 1;
			phase_done <= 1;		
		end
		
		if (i2c_done == 1 && phase_done == 1)
		begin
			i2c_write <= 0;
			phase_done <= 0;
			state <= 4;		
		end
	end
	
	// Data
	if (state == 4)
	begin
		if (i2c_done == 0 && phase_done == 0)
		begin
			data_being_sent <= i2c_data;
			i2c_write <= 1;
			phase_done <= 1;		
		end
		
		if (i2c_done == 1 && phase_done == 1)
		begin
			i2c_write <= 0;
			phase_done <= 0;
			state <= 5;		
		end
	end
	
	
	// send stop bit
	if (state == 5)
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
			done <= 1;
		end
	
	end
 
 
 end
 
 endmodule
 