`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    11:28:19 07/07/2020
// Design Name:
// Module Name:    vgac
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
module vgac(input vga_clk,           // 25MHz
            input clrn,              // Clear the screen
            input [11:0] d_in_BGR,   // bbbb_gggg_rrrr, pixel
            output read,             // read pixel RAM (active_high)
            output reg [8:0] Y_Addr, // pixel ram Y address, 480 (512) lines
            output reg [9:0] X_Addr, // pixel ram X address, 640 (1024) pixels
            output reg [3:0] r,
            output reg [3:0] g,
            output reg [3:0] b,      // red, green, blue colors
            output reg hs,
            output reg vs);          // horizontal and vertical synchronization
    
    // X_count: VGA horizontal counter (0-799)
    reg [9:0] X_count;           // VGA horizontal counter (0-799): pixels
    always @ (posedge vga_clk) begin
        if (clrn) begin
            X_count <= 10'h0;
            end else if (X_count == 10'd799) begin
            X_count <= 10'h0;
            end else begin
            X_count <= X_count + 10'h1;
        end
    end
    
    // Y_count: VGA vertical counter (0-524)
    reg [8:0] Y_count; // VGA vertical   counter (0-524): lines
    always @ (posedge vga_clk/* or negedge clrn*/) begin
        if (clrn) begin
            Y_count <= 10'h0;
            end else if (X_count == 10'd799) begin
            if (Y_count == 10'd524) begin
                Y_count <= 10'h0;
                end else begin
                Y_count <= Y_count + 10'h1;
            end
        end
    end
    
    // signals, will be latched for outputs
    wire  [8:0]  Y_tmp  = Y_count - 10'd35;     // pixel ram Y addr
    wire  [9:0]  X_tmp  = X_count - 10'd143;    // pixel ram X addr
    wire         X_sync = (X_count > 10'd95);    //  96 -> 799
    wire         Y_sync = (Y_count > 10'd1);     //   2 -> 524
    assign       read = (X_count > 10'd142) && // 143 -> 782
    (X_count < 10'd783) && //        640 pixels
    (Y_count > 10'd34)  && //  35 -> 514
    (Y_count < 10'd515);   //        480 lines
    // vga signals
    always @ (posedge vga_clk) begin
        Y_Addr <= 479 - Y_tmp;        // pixel ram Y address
        X_Addr <= X_tmp;        // pixel ram X address
        // rdn <= ~read;         // read pixel (active low)
        hs     <= X_sync;       // horizontal synchronization
        vs     <= Y_sync;       // vertical   synchronization
        r      <= read ? d_in_BGR[3:0]  : 4'b0;  // 4-bit red
        g      <= read ? d_in_BGR[7:4]  : 4'b0;  // 4-bit green
        b      <= read ? d_in_BGR[11:8] : 4'b0;  // 4-bit blue
    end
endmodule
