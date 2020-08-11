`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   11:55:10 07/10/2020
// Design Name:   MIO_BUS
// Module Name:   C:/Users/Ulysses/Desktop/_ComOrg/Org2048/MIO_BUS_test.v
// Project Name:  Org2048
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: MIO_BUS
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module MIO_BUS_test;

    // Inputs
    reg clk;
    reg rst;
    reg [3:0] BTN;
    reg [15:0] SW;
    reg [9:0] ps2kb_key;
    reg mem_w;
    reg [31:0] Cpu_data2bus;
    reg [31:0] addr_bus;
    reg [31:0] ram_data_out;
    reg [15:0] led_out;
    reg [31:0] counter_out;
    reg counter0_out;
    reg counter1_out;
    reg counter2_out;
    reg [3:0] BlockID;

    // Outputs
    wire [3:0] BlockType;
    wire [31:0] Cpu_data4bus;
    wire [31:0] ram_data_in;
    wire [9:0] ram_addr;
    wire data_ram_we;
    wire GPIOf0000000_we;
    wire GPIOe0000000_we;
    wire counter_we;
    wire [31:0] Peripheral_in;

    // Instantiate the Unit Under Test (UUT)
    MIO_BUS uut (
        .clk(clk), 
        .rst(rst), 
        .BTN(BTN), 
        .SW(SW), 
        .ps2kb_key(ps2kb_key), 
        .mem_w(mem_w), 
        .Cpu_data2bus(Cpu_data2bus), 
        .addr_bus(addr_bus), 
        .ram_data_out(ram_data_out), 
        .led_out(led_out), 
        .BlockID(BlockID), 
        .BlockType(BlockType), 
        .Cpu_data4bus(Cpu_data4bus), 
        .ram_data_in(ram_data_in), 
        .ram_addr(ram_addr), 
        .data_ram_we(data_ram_we), 
        .GPIOf0000000_we(GPIOf0000000_we), 
        .GPIOe0000000_we(GPIOe0000000_we), 
        .counter_we(counter_we), 
        .Peripheral_in(Peripheral_in)
    );

    integer i = 0;
    initial begin
        // Initialize Inputs
        clk = 0;
        rst = 1;
        BTN = 0;
        SW = 0;
        ps2kb_key = 0;
        mem_w = 0;
        Cpu_data2bus = 0;
        addr_bus = 0;
        ram_data_out = 0;
        led_out = 0;
        counter_out = 0;
        counter0_out = 0;
        counter1_out = 0;
        counter2_out = 0;
        BlockID = 0;

        #1;
        rst = 0;
        #1;
        
        addr_bus = 32'hC0000000;
        mem_w = 0;
        #10;
        mem_w = 1;
        #10;
        mem_w = 0;
        #10;
        mem_w = 1;
        #10;
        mem_w = 0;
        #10;
        mem_w = 1;
        #10;
        mem_w = 0;
        #10;
        mem_w = 1;
        #10;
        mem_w = 0;
        #10;
        mem_w = 1;
        #10;
        
        mem_w = 0;
        addr_bus = 32'hD0000000;
        ps2kb_key = 32'h21;
        #100;
        
        mem_w = 1'b1;
        addr_bus = 32'hE0000000;
        Cpu_data2bus = 32'h666;
        #100;
        
        
        #5;
        
        BlockID = 3;



    end
    always @*
        for(;1;)
            #5 clk = ~clk;
      
endmodule

