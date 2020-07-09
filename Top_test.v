`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:41:05 07/09/2020
// Design Name:   Top
// Module Name:   C:/Users/Ulysses/Desktop/_ComOrg/Org2048/Top_test.v
// Project Name:  Org2048
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module Top_test;

	// Inputs
	reg clk_100mhz;
	reg RSTN;
	reg [3:0] K_COL;
	reg [15:0] SW;
	reg PS2_clk;
	reg PS2_data;

	// Outputs
	wire CR;
	wire LEDCLK;
	wire LEDCLR;
	wire LEDDT;
	wire LEDEN;
	wire RDY;
	wire readn;
	wire SEGCLK;
	wire SEGCLR;
	wire SEGDT;
	wire SEGEN;
	wire [3:0] AN;
	wire [4:0] K_ROW;
	wire [7:0] LED;
	wire [7:0] SEGMENT;
	wire [3:0] VGA_R;
	wire [3:0] VGA_G;
	wire [3:0] VGA_B;
	wire VGA_hs;
	wire VGA_vs;

	// Instantiate the Unit Under Test (UUT)
	Top uut (
		.clk_100mhz(clk_100mhz), 
		.RSTN(RSTN), 
		.K_COL(K_COL), 
		.SW(SW), 
		.PS2_clk(PS2_clk), 
		.PS2_data(PS2_data), 
		.CR(CR), 
		.LEDCLK(LEDCLK), 
		.LEDCLR(LEDCLR), 
		.LEDDT(LEDDT), 
		.LEDEN(LEDEN), 
		.RDY(RDY), 
		.readn(readn), 
		.SEGCLK(SEGCLK), 
		.SEGCLR(SEGCLR), 
		.SEGDT(SEGDT), 
		.SEGEN(SEGEN), 
		.AN(AN), 
		.K_ROW(K_ROW), 
		.LED(LED), 
		.SEGMENT(SEGMENT), 
		.VGA_R(VGA_R), 
		.VGA_G(VGA_G), 
		.VGA_B(VGA_B), 
		.VGA_hs(VGA_hs), 
		.VGA_vs(VGA_vs)
	);

	initial begin
		// Initialize Inputs
		clk_100mhz = 0;
		RSTN = 1;
		K_COL = 0;
		SW = 0;
		PS2_clk = 0;
		PS2_data = 0;

		// Wait 100 ns for global reset to finish
		#50;
        RSTN = 0;
        
		// Add stimulus here

	end
    always @* begin
        for(;1;)
            #3 clk_100mhz = ~clk_100mhz;
    end
      
endmodule

