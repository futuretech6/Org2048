`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   23:50:37 07/13/2020
// Design Name:   Hex2BCD
// Module Name:   C:/Users/Ulysses/Desktop/_ComOrg/Org2048/Hex2BCD_test.v
// Project Name:  Org2048
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Hex2BCD
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module Hex2BCD_test;

	// Inputs
	reg [31:0] Hex;

	// Outputs
	wire [31:0] BCD;

	// Instantiate the Unit Under Test (UUT)
	Hex2BCD uut (
		.Hex(Hex), 
		.BCD(BCD)
	);

	initial begin
		// Initialize Inputs
		Hex = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
        Hex = 32'd00000012;

	end
      
endmodule

