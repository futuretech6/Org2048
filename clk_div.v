`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    17:19:38 07/17/2012
// Design Name:
// Module Name:    clk_div
// Project Name:
// Target Devices:
// Tool versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module clk_div(input clk,
               input rst,
               input SW2,
               input SW_Pause,
               output reg[31:0]clkdiv,
               output Clk_CPU);
    
    always @ (posedge clk or posedge rst) begin
        if (rst)
            clkdiv <= 0;
        else
            clkdiv <= clkdiv + 1'b1;
    end
    
    assign Clk_CPU = SW_Pause ? 0 : (SW2 ? clkdiv[23] : clkdiv[3]);
    
endmodule
