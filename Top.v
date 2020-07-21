`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    10:20:44 03/21/2020
// Design Name:
// Module Name:    Top
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
module Top(input clk_100mhz,
           input RSTN,
           input [3:0] K_COL,
           input [15:0] SW,
           input PS2_clk,
           input PS2_data,
           output CR,
           output LEDCLK,
           output LEDCLR,
           output LEDDT,
           output LEDEN,
           output RDY,
           output readn,
           output SEGCLK,
           output SEGCLR,
           output SEGDT,
           output SEGEN,
           output [3:0] AN,
           output [4:0] K_ROW,
           output [7:0] LED,
           output [7:0] SEGMENT,
           output [3:0] VGA_R,
           output [3:0] VGA_G,
           output [3:0] VGA_B,
           output VGA_hs,
           output VGA_vs);
    
    wire clk_CPU, clk_IO, Co, counter_we, counter0_out, counter1_out, counter2_out, GPIOEN, GPIOF0, G0, mem_w, ram_we, rst, PS2_ready;
    wire [1:0] counter_ch;
    wire [3:0] BTN_OK, Pulse, BlockID, BlockType;
    wire [4:0] Key_out, State;
    wire [7:0] blink, blink_out, point_out;
    wire [9:0] ram_addr, PS2_key;
    wire [15:0] LED_out, SW_OK;
    wire [31:0] Addr_out, Ai, Bi, counter_out, CPU2IO, Data_in, Data_out, Disp_num, Div, inst, PC, ram_din, ram_dout;
    reg [31:0] score_hex;
    wire [31:0] score_bcd;
    
    assign clk_IO = ~clk_CPU;
    
    SEnter_2_32 se232 (.BTN(BTN_OK[2:0]), .clk(clk_100mhz), .Ctrl({SW_OK[7:5], SW_OK[15], SW_OK[0]}),
    .Din(Key_out[4:0]), .D_ready(RDY), .Ai(Ai[31:0]), .Bi(Bi[31:0]), .blink(blink[7:0]), .readn(readn));
    
    SSeg7_Dev ss7d (.clk(clk_100mhz), .flash(Div[25]), .Hexs(Disp_num[31:0]), .LES(blink_out[7:0]),
    .point(point_out[7:0]), .rst(rst), .Start(Div[20]), .SW0(SW_OK[0]), .seg_clk(SEGCLK), .seg_clrn(SEGCLR),
    .SEG_PEN(SEGEN), .seg_sout(SEGDT));
    
    SAnti_jitter saj (.clk(clk_100mhz), .Key_y(K_COL[3:0]), .readn(readn), .RSTN(RSTN), .SW(SW[15:0]),
    .BTN_OK(BTN_OK[3:0]), .CR(CR), .Key_out(Key_out[4:0]), .Key_ready(RDY), .Key_x(K_ROW[4:0]),
    .pulse_out(Pulse[3:0]), .rst(rst), .SW_OK(SW_OK[15:0]));
    
    Seg7_Dev s7d (.flash(Div[25]), .Hexs(Disp_num[31:0]), .LES(blink_out[7:0]), .point(point_out[7:0]),
    .Scan({SW_OK[1], Div[19:18]}), .SW0(SW_OK[0]), .AN(AN[3:0]), .SEGMENT(SEGMENT[7:0]));
    
    PIO pio (.clk(clk_IO), .EN(GPIOF0), .PData_in(CPU2IO[31:0]), .rst(rst), .GPIOf0(), .LED_out(LED[7:0]),
    .counter_set());
    
    SPIO spio (.clk(clk_IO), .EN(GPIOF0), .P_Data(CPU2IO[31:0]), .rst(rst), .Start(Div[20]),
    .counter_set(counter_ch[1:0]), .GPIOf0(), .led_clk(LEDCLK), .led_clrn(LEDCLR), .LED_out(LED_out[15:0]),
    .LED_PEN(LEDEN), .led_sout(LEDDT));
    
    Counter_x counter (.clk(clk_IO), .clk0(Div[8]), .clk1(Div[9]), .clk2(Div[11]), .counter_ch(counter_ch[1:0]),
    .counter_val(CPU2IO[31:0]), .counter_we(counter_we), .rst(rst), .counter_out(counter_out[31:0]),
    .counter0_OUT(counter0_out), .counter1_OUT(counter1_out), .counter2_OUT(counter2_out));
    
    /* ---------------- */
    always @(CPU2IO)
        // if (CPU2IO != 32'hFFFFFFFF)
        //     score_hex = CPU2IO;
        score_hex = CPU2IO[31:28] != 4'hF ? CPU2IO : score_hex;
    Hex2BCD bcd(.Hex(score_hex), .BCD(score_bcd));

    Multi_8CH32 m8ch32 (.clk(clk_IO), .rst(rst), .EN(GPIOEN), .Test(SW_OK[7:5]), .LES(64'b0),
    .point_in({Div[31:0], Div[31:13], State[4:0], 8'b0}), .Disp_num(Disp_num[31:0]), .point_out(point_out[7:0]), .LE_out(blink_out[7:0]),
    .Data0((CPU2IO == -1 && Div[27]) ? 32'hdeaddead : score_bcd),
    .data1({2'b0, PC[31:2]}),
    .data2({22'h0, ram_addr}),
    .data3(Data_in[31:0]),
    .data4(Addr_out[31:0]),
    .data5(Data_out[31:0]),
    .data6({22'b0, S2_key}),
    .data7(ram_dout[31:0]));
    
    MCPU cpu (
    .clk(clk_CPU), .reset(rst), .inst_out(inst[31:0]), .INT(counter0_out), .Data_in(Data_in[31:0]), .MIO_ready(1'b1), .PC_out(PC[31:0]),
    .mem_w(mem_w), .Addr_out(Addr_out[31:0]), .Data_out(Data_out[31:0]), .state(State[4:0]), .CPU_MIO()
    );
    
    MIO_BUS miobus (
    .clk(clk_100mhz), .rst(rst), .BTN(BTN_OK[3:0]), .SW(SW_OK[15:0]), .ps2kb_key(PS2_key), .mem_w(mem_w), .Cpu_data2bus(Data_out[31:0]), .addr_bus(Addr_out[31:0]), .ram_data_out(ram_dout[31:0]), .led_out(LED_out[15:0]), .BlockID(BlockID),
    .BlockType(BlockType), .Cpu_data4bus(Data_in[31:0]), .ram_data_in(ram_din[31:0]), .data_ram_we(ram_we), .ram_addr(ram_addr), .Peripheral_in(CPU2IO[31:0]), .GPIOe0000000_we(GPIOEN), .GPIOf0000000_we(GPIOF0), .counter_we(counter_we)
    );

    // For Port B, PS2 only write, Display only read
    RAM_B ram_b (.addra(ram_addr), .wea(ram_we), .dina(ram_din), .clka(clk_100mhz), .douta(ram_dout));
    
    clk_div clkd (.clk(clk_100mhz), .rst(rst), .SW2(SW_OK[2]), .SW_Pause(SW_OK[15]), .clkdiv(Div[31:0]), .Clk_CPU(clk_CPU));
    
    Display disp(.rst(rst), .clk_VGA(Div[1]), .SW_OK(SW_OK[15:0]), .BlockType(BlockType), .VGA_R(VGA_R),
    .VGA_G(VGA_G), .VGA_B(VGA_B), .VGA_hs(VGA_hs), .VGA_vs(VGA_vs), .BlockID(BlockID));
    
    PS2 ps2(.clk(clk_100mhz), .ready(PS2_ready), .rst(rst), .ps2_clk(PS2_clk), .ps2_data(PS2_data), .data_out(PS2_key));
    
endmodule
