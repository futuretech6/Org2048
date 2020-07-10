`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   19:31:26 07/09/2020
// Design Name:   MCPU
// Module Name:   C:/Users/Ulysses/Desktop/_ComOrg/Org2048/MCPU_test.v
// Project Name:  Org2048
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: MCPU
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module MCPU_test;

	// Inputs
	reg INT;
	reg clk;
	reg reset;
	reg MIO_ready;
	reg [31:0] Data_in;

	// Outputs
	wire mem_w;
	wire [31:0] PC_out;
	wire [31:0] inst_out;
	wire [31:0] Data_out;
	wire [31:0] Addr_out;
	wire CPU_MIO;
	wire [4:0] state;

	// Instantiate the Unit Under Test (UUT)
	MCPU uut (
		.INT(INT), 
		.clk(clk), 
		.reset(reset), 
		.MIO_ready(MIO_ready), 
		.Data_in(Data_in), 
		.mem_w(mem_w), 
		.PC_out(PC_out), 
		.inst_out(inst_out), 
		.Data_out(Data_out), 
		.Addr_out(Addr_out), 
		.CPU_MIO(CPU_MIO), 
		.state(state)
	);

	initial begin
		// Initialize Inputs
		INT = 0;
		clk = 0;
		reset = 1;
		MIO_ready = 1;
		Data_in = 0;

		// Wait 100 ns for global reset to finish
		#50;
        reset = 0;
        #50;
        
		// Add stimulus here
        Data_in = 32'h200803E0;
        #100;
        
        Data_in = 32'h20090001;
        #100;

        Data_in = 32'had090000;
        #100;
        
        
        
        
	end
    always @*
        for(;1;)
            #3 clk = ~clk;
      
endmodule

