`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    11:37:09 07/07/2020
// Design Name:
// Module Name:    Display
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
module Display(input rst,
               input clk_VGA,
               input [15:0] SW_OK,
               input [3:0] BlockType,
               output [3:0] BlockID,   // From LeftBottom to RightTop
               output [3:0] VGA_R,
               output [3:0] VGA_G,
               output [3:0] VGA_B,
               output VGA_hs,
               output VGA_vs);
    
    parameter SCREEN_HEIGHT = 480;
    parameter SCREEN_WIDTH  = 640;
    parameter BLOCK_WIDTH   = 100;
    parameter SLOT_WIDTH    = 16;
    
    // parameter RGB_SLOT = 32'hB9ADA1;
    // parameter RGB_B0   = 32'hCAC1B5;
    // parameter RGB_BG   = 32'hFAF8F0;
    parameter RGB_SLOT    = 32'hCBA;
    parameter RGB_B0      = 32'hDCB;
    parameter RGB_BG      = 32'hEED;
    
    /* Basic */
    wire [11:0] BGR_Land;
    wire [9:0] X_Addr;
    wire [8:0] Y_Addr;
    reg [11:0] RGB;

    
    /* Game Logic */
    wire inBlock;
    reg [1:0] X_BlockID, Y_BlockID;
    wire [11:0] X_Len, Y_Len, BlockOffset;  // [0, 50x50), LpipeftUp to RightBottom
    
    assign inBlock = (SLOT_WIDTH * (X_BlockID + 1) + BLOCK_WIDTH * X_BlockID) <= X_Addr && X_Addr < (SLOT_WIDTH + BLOCK_WIDTH) * (X_BlockID + 1) && (SLOT_WIDTH * (Y_BlockID + 1) + BLOCK_WIDTH * Y_BlockID) <= Y_Addr && Y_Addr < ((SLOT_WIDTH + BLOCK_WIDTH) * (Y_BlockID + 1));
    
    assign BlockID     = 4 * Y_BlockID + X_BlockID;
    assign Y_Len       = BLOCK_WIDTH - 1 - (Y_Addr - SLOT_WIDTH * (Y_BlockID + 1) - BLOCK_WIDTH * Y_BlockID);
    assign X_Len       = X_Addr - SLOT_WIDTH * (X_BlockID + 1) - BLOCK_WIDTH * X_BlockID;
    assign BlockOffset = (Y_Len / 2) * BLOCK_WIDTH / 2 + X_Len / 2;  // 100x100 to 50x50
    
    integer i;
    always @(posedge clk_VGA) begin
        for (i = 0; i < 4; i = i + 1) begin
            if (SLOT_WIDTH * (i + 1) + BLOCK_WIDTH * i <= X_Addr && X_Addr < (SLOT_WIDTH + BLOCK_WIDTH) * (i + 1))
                X_BlockID <= i;
            
            if (SLOT_WIDTH * (i + 1) + BLOCK_WIDTH * i <= Y_Addr && Y_Addr < (SLOT_WIDTH + BLOCK_WIDTH) * (i + 1))
                Y_BlockID <= i;
            
        end
    end
    
    /* Show */
    wire [11:0] dout2, dout4, dout8, dout16, dout32, dout64, dout128, dout256, dout512, dout1024;
    
    B2 b2 (.a(BlockOffset), .spo(dout2));
    B4 b4 (.a(BlockOffset), .spo(dout4));
    B8 b8 (.a(BlockOffset), .spo(dout8));
    B16 b16 (.a(BlockOffset), .spo(dout16));
    B32 b32 (.a(BlockOffset), .spo(dout32));
    B64 b64 (.a(BlockOffset), .spo(dout64));
    B128 b128 (.a(BlockOffset), .spo(dout128));
    B256 b256 (.a(BlockOffset), .spo(dout256));
    B512 b512 (.a(BlockOffset), .spo(dout512));
    B1024 b1024 (.a(BlockOffset), .spo(dout1024));
    
    always @(posedge clk_VGA) begin
        if (X_Addr > SCREEN_HEIGHT)
            RGB <= RGB_BG;
        else if (~inBlock)
            RGB <= RGB_SLOT;
        else
            case (BlockType)
                0: RGB       <= RGB_B0;
                1: RGB       <= dout2;
                2: RGB       <= dout4;
                3: RGB       <= dout8;
                4: RGB       <= dout16;
                5: RGB       <= dout32;
                6: RGB       <= dout64;
                7: RGB       <= dout128;
                8: RGB       <= dout256;
                9: RGB       <= dout512;
                10: RGB      <= dout1024;
                default: RGB <= 12'hxxx;
            endcase
    end
    
    vgac vga_ctrl(.vga_clk(clk_VGA), .clrn(rst), .d_in_BGR({RGB[3:0],RGB[7:4],RGB[11:8]}),
    .Y_Addr(Y_Addr), .X_Addr(X_Addr), .r(VGA_R), .g(VGA_G), .b(VGA_B), .hs(VGA_hs), .vs(VGA_vs));
    
endmodule
