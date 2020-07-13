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
               input [31:0] counter_out,
               input counter0_out,
               input counter1_out,
               input counter2_out,
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
    reg [3:0] BlockType2CPU = 0;
    assign BlockType = {28'b0, BlockInfo[BlockID]};
    initial begin
        randCnt = 0;
        ps2kb_on = 0;
    end
    // Block Info
    integer i;
    always @(posedge clk) begin
        if(rst)
            for (i = 0; i < 16; i = i + 1)
                BlockInfo[i] <= 4'b0;
        else if (addr_bus[31:28] == 4'hF) begin  // CPU IO
            if(mem_w)
                BlockInfo[addr_bus[5:2]] <= Cpu_data2bus;   // CPU w
            else
                BlockType2CPU = BlockInfo[addr_bus[5:2]];  // CPU r
        end
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
                // ps2kb_on = 0;
            end
            4'hC: begin  // get random.randint(0, 15)
                rand_rd = ~mem_w;
                // ps2kb_on = 0;
            end
            4'hD: begin  // keyborad
                // if(ps2kb_on == 1'b0 && mem_w == 0)
                ps2kb_rd = ~mem_w;
                // ps2kb_on = ~mem_w;
            end
            4'hF: begin  // BlockInfo
                // block_we = mem_w;
                block_rd = ~mem_w;
                // ps2kb_on = 0;
            end
            // default: begin
            //     ps2kb_on = 0;
            // end
            // 4'hE: begin
            //     GPIOe0000000_we = mem_w;
            //     Peripheral_in   = Cpu_data2bus;
            //     GPIOe0000000_rd = ~mem_w;
            // end
            // 4'hF: begin
            //     if (addr_bus[2]) begin
            //         counter_we    = mem_w;
            //         Peripheral_in = Cpu_data2bus;
            //         counter_rd    = ~mem_w;
            //     end
            //     else begin
            //         GPIOf0000000_we = mem_w;
            //         Peripheral_in   = Cpu_data2bus;
            //         GPIOf0000000_rd = ~mem_w;
            //     end
            // end
        endcase
    end
    // CPU read
    always @(posedge clk) begin
        casex({data_ram_rd, GPIOe0000000_rd, counter_rd, GPIOf0000000_rd, ps2kb_rd, rand_rd, block_rd})  /* Procedure */
            7'b1xxxxxx: Cpu_data4bus = ram_data_out;
            7'bx1xxxxx: Cpu_data4bus = counter_out;
            7'bxx1xxxx: Cpu_data4bus = counter_out;
            7'bxxx1xxx: Cpu_data4bus = {counter0_out,counter1_out,counter2_out,17'b0,BTN[3:0],SW[7:0]};
            7'bxxxx1xx: Cpu_data4bus = {22'b0, ps2kb_key};
            7'bxxxxx1x: Cpu_data4bus = {28'b0, myRand};
            7'bxxxxxx1: Cpu_data4bus = {28'b0, BlockType2CPU};
            default: Cpu_data4bus   = 32'h0;
        endcase
    end
endmodule
