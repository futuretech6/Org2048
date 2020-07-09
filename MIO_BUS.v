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
               output reg [31:0] Cpu_data4bus,
               output reg [31:0] ram_data_in,
               output reg [9:0] ram_addr,
               output reg data_ram_we,
               output reg GPIOf0000000_we,
               output reg GPIOe0000000_we,
               output reg counter_we,
               output reg [31:0] Peripheral_in);
    
    reg data_ram_rd,GPIOf0000000_rd,GPIOe0000000_rd,counter_rd,ps2kb_rd,rand_rd;
    
    reg [31:0] myRand;
    reg [3:0] randCnt;
    initial begin
        randCnt = 0;
    end
    
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
        ps2kb_rd        = 0; // Keyborad
        rand_rd         = 0; // Rand
        /* Use the highest bit to indicates type */
        case(addr_bus[31:28])
            4'h0: begin
                data_ram_we = mem_w;
                ram_addr    = addr_bus[11:2];
                ram_data_in = Cpu_data2bus;
                data_ram_rd = ~mem_w;
            end
            4'hC: begin
                rand_rd = ~mem_w;
            end
            4'hD: begin // keyborad
                ps2kb_rd = ~mem_w;
            end
            4'hE: begin
                GPIOe0000000_we = mem_w;
                Peripheral_in   = Cpu_data2bus;
                GPIOe0000000_rd = ~mem_w;
            end
            4'hF: begin
                if (addr_bus[2]) begin
                    counter_we    = mem_w;
                    Peripheral_in = Cpu_data2bus;
                    counter_rd    = ~mem_w;
                end
                else begin
                    GPIOf0000000_we = mem_w;
                    Peripheral_in   = Cpu_data2bus;
                    GPIOf0000000_rd = ~mem_w;
                end
            end
        endcase
    end

    always @(*) begin
        if(~rand_rd) begin  // Won't change while assigning
            case(randCnt)
                0: myRand  = 32'd13;
                1: myRand  = 32'd7;
                2: myRand  = 32'd11;
                3: myRand  = 32'd6;
                4: myRand  = 32'd4;
                5: myRand  = 32'd0;
                6: myRand  = 32'd9;
                7: myRand  = 32'd10;
                8: myRand  = 32'd12;
                9: myRand  = 32'd15;
                10: myRand = 32'd14;
                11: myRand = 32'd1;
                12: myRand = 32'd3;
                13: myRand = 32'd2;
                14: myRand = 32'd8;
                15: myRand = 32'd5;
            endcase
            randCnt = randCnt == 15 ? 0 : randCnt + 1;
        end
    end
    
    always @(posedge clk) begin
        casex({data_ram_rd,GPIOe0000000_rd,counter_rd,GPIOf0000000_rd,ps2kb_rd,rand_rd})  /* Procedure */
            6'b1xxxxx: Cpu_data4bus = ram_data_out;
            6'bx1xxxx: Cpu_data4bus = counter_out;
            6'bxx1xxx: Cpu_data4bus = counter_out;
            6'bxxx1xx: Cpu_data4bus = {counter0_out,counter1_out,counter2_out,17'b0,BTN[3:0],SW[7:0]};
            6'bxxxx1x: Cpu_data4bus = {22'd0, ps2kb_key};
            6'bxxxxx1: Cpu_data4bus = myRand;
            default: Cpu_data4bus   = 32'h0;
        endcase
    end
endmodule
