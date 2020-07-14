`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    12:09:28 06/21/2016
// Design Name:
// Module Name:    MIO_BUS
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
module MIO_BUS(input clk,
               input rst,
               input [3:0] BTN,
               input [15:0] SW,
               input [9:0] ps2kb_key,
               input mem_w,
               input [31:0] Cpu_data2bus,
               input [31:0] addr_bus,
               input [31:0] ram_data_out,
               input [15:0] led_out,
               input [3:0] BlockID,
               output [3:0] BlockType,
               output reg [31:0] Cpu_data4bus,
               output reg [31:0] ram_data_in,
               output reg [9:0] ram_addr,
               output reg data_ram_we,
               output reg GPIOf0000000_we,
               output reg GPIOe0000000_we,
               output reg counter_we,
               output reg [31:0] Peripheral_in);
    reg data_ram_rd,GPIOf0000000_rd,GPIOe0000000_rd,counter_rd,ps2kb_rd,ps2kb_on,rand_rd, block_rd;
    reg [3:0] BlockInfo[0:15];// = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    assign BlockType = {28'b0, BlockInfo[BlockID]};
    initial begin
        randCnt = 0;
        ps2kb_on = 0;
    end
    // Block Info
    integer i;
    always @(*) begin
        if(rst)
            for (i = 0; i < 16; i = i + 1)
                BlockInfo[i] <= 4'b0;
        else if(mem_w && addr_bus[31:28] == 4'hD)
            BlockInfo[addr_bus[5:2]] <= Cpu_data2bus;
    end
    reg [3:0] randCnt = 0;
    // Rand
    reg [3:0] myRand = 0;
    always @(*) begin
        if(~rand_rd) begin  // Won't change while assigning
            case(randCnt)
                0: myRand  = 4'd13;
                1: myRand  = 4'd7;
                2: myRand  = 4'd11;
                3: myRand  = 4'd6;
                4: myRand  = 4'd4;
                5: myRand  = 4'd0;
                6: myRand  = 4'd9;
                7: myRand  = 4'd10;
                8: myRand  = 4'd12;
                9: myRand  = 4'd15;
                10: myRand = 4'd14;
                11: myRand = 4'd1;
                12: myRand = 4'd3;
                13: myRand = 4'd2;
                14: myRand = 4'd8;
                15: myRand = 4'd5;
                default: myRand = 4'hx;
            endcase
            randCnt = randCnt == 15 ? 0 : randCnt + 1;
        end
    end
    // IO ctrl
    always @(*) begin
        data_ram_we     = 0;
        data_ram_rd     = 0;
        counter_we      = 0;
        GPIOf0000000_we = 0;
        GPIOf0000000_rd = 0;
        GPIOe0000000_we = 0;
        GPIOe0000000_rd = 0;
        counter_rd      = 0;
        ram_addr        = 10'h0;
        ram_data_in     = 32'h0;
        Peripheral_in   = 32'h0;
        // if(mem_w == 1'b0 || mem_w == 1'b1 && ps2kb_rd == 1'b1)
        ps2kb_rd        = 0; // Keyborad
        rand_rd         = 0; // Rand
        // block_we = 0;
        block_rd = 0;
        /* Use the highest bit to indicates type */
        case(addr_bus[31:28])
            4'h0: begin  // Normal mem I/O
                data_ram_we = mem_w;
                ram_addr    = addr_bus[11:2];
                ram_data_in = Cpu_data2bus;
                data_ram_rd = ~mem_w;
            end
            4'hC: begin  // get random.randint(0, 15)
                rand_rd = ~mem_w;
            end
            4'hD: begin  // keyborad
                ps2kb_rd = ~mem_w;
            end
            4'hE: begin  // 7Seg
                GPIOe0000000_we = mem_w;
                Peripheral_in   = Cpu_data2bus;
                GPIOe0000000_rd = ~mem_w;
            end
            4'hF: begin  // BlockInfo
                block_rd = ~mem_w;
            end
        endcase
    end
    // CPU read
    always @(posedge clk) begin
        casex({data_ram_rd, ps2kb_rd, rand_rd, block_rd})  /* Procedure */
            4'b1xxx: Cpu_data4bus = ram_data_out;
            4'bx1xx: Cpu_data4bus = {22'b0, ps2kb_key};
            4'bxx1x: Cpu_data4bus = {28'b0, myRand};
            4'bxxx1: Cpu_data4bus = {28'b0, BlockInfo[addr_bus[5:2]]};
            default: Cpu_data4bus   = 32'h0;
        endcase
    end
endmodule
