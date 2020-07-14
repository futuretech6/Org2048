`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    23:43:38 07/13/2020
// Design Name:
// Module Name:    Hex2BCD
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
module Hex2BCD(input [31:0] Hex,
               output reg [31:0] BCD);
reg [31:0] tmp;
always @* begin
    tmp        = Hex;
    BCD[3:0]   = tmp % 10;
    tmp        = (tmp - BCD[3:0]) / 10;
    BCD[7:4]   = tmp % 10;
    tmp        = (tmp - BCD[7:4]) / 10;
    BCD[11:8]  = tmp % 10;
    tmp        = (tmp - BCD[11:8]) / 10;
    BCD[15:12] = tmp % 10;
    tmp        = (tmp - BCD[15:12]) / 10;
    BCD[19:16] = tmp % 10;
    tmp        = (tmp - BCD[19:16]) / 10;
    BCD[23:20] = tmp % 10;
    tmp        = (tmp - BCD[23:20]) / 10;
    BCD[27:24] = tmp % 10;
    tmp        = (tmp - BCD[27:24]) / 10;
    BCD[31:28] = tmp % 10;
    tmp        = (tmp - BCD[31:28]) / 10;
end

endmodule
