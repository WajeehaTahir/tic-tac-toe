`timescale 1ns / 1ps

module test;

	// Inputs
	reg clk;
	reg IO_BTN_C;
	reg [3:0] IO_SWITCH;
	reg btn;

	// Outputs
	wire VGA_Hsync;
	wire VGA_Vsync;
	wire [2:0] VGA_Red;
	wire [2:0] VGA_Green;
	wire [1:0] VGA_Blue;
	wire [2:0] led;

	// Instantiate the Unit Under Test (UUT)
	top uut (
		.clk(clk), 
		.IO_BTN_C(IO_BTN_C), 
		.IO_SWITCH(IO_SWITCH), 
		.VGA_Hsync(VGA_Hsync), 
		.VGA_Vsync(VGA_Vsync), 
		.btn(btn), 
		.VGA_Red(VGA_Red), 
		.VGA_Green(VGA_Green), 
		.VGA_Blue(VGA_Blue), 
		.led(led)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		IO_BTN_C = 0;
		IO_SWITCH = 0;
		btn = 0;
		// Wait 100 ns for global reset to finish
		#100; IO_BTN_C = 1;
		#100; IO_BTN_C = 0;
		
		// Add stimulus here
		#1000;IO_SWITCH = 0;#10;btn = 1;#10;btn = 0;
		#1000;IO_SWITCH = 5;#10;btn = 1;#10;btn = 0;
		//#1000;IO_SWITCH = 3;#10;btn = 1;#10;btn = 0;
		//#1000;IO_SWITCH = 5;#10;btn = 1;#10;btn = 0;
	end
      always #1 clk= ~clk;
endmodule

