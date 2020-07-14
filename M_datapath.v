`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:35:06 05/20/2020 
// Design Name: 
// Module Name:    M_datapath 
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
module M_datapath(input clk,
                  input reset,
                 
                  input MIO_ready,
                  input IorD,
                  input IRWrite,
                  input [1:0] RegDst,
                  input RegWrite,
                  input [1:0] MemtoReg,
                  input ALUSrcA,
                 
                  input[1:0]ALUSrcB,
                  input[1:0]PCSource,
                  input PCWrite,
                  input PCWriteCond,
                  input Branch,
                  input[3:0]ALU_operation,
                 
                  output[31:0]PC_Current,
                  input[31:0]data2CPU,
                  output[31:0]Inst,
                  output[31:0]data_out,
                  output[31:0]M_addr,
                 
                  output zero,
                  output overflow);

    wire [31:0] ALUout;
    wire [31:0] Imm32;
    wire [31:0] res;
    wire [4:0]  Wt_addr;
    wire [31:0] MD;
    wire [31:0] Wt_data;
    wire [31:0] data_B;
    wire [31:0] rdata_A;
    wire [31:0] data_A;
    wire [31:0] PC_out;

    wire [31:0] lui;
    wire [4:0] ra;

    assign ra = 5'd31;

    assign Imm32 = {Inst[15] ? 16'hFFFF : 16'h0, Inst[15:0]};
    assign data_A = ALUSrcA ? rdata_A[31:0] : PC_Current[31:0];
    assign M_addr = IorD ? ALUout[31:0] : PC_Current[31:0];
    assign lui = {Inst[15:0], data_out[15:0]};

    ALU  U1 (.A(data_A[31:0]),
             .ALU_operation(ALU_operation),
             .B(data_B[31:0]),
             .shamt(Inst[10:6]),
             .overflow(overflow),
             .res(res[31:0]),
             .zero(zero));

    Regs U2 (.clk(clk),
             .we(RegWrite),
             .rst(reset),
             .R_addr_A(Inst[25:21]),
             .R_addr_B(Inst[20:16]),
             .Wt_addr(Wt_addr[4:0]),
             .Wt_data(Wt_data[31:0]),
             .rdata_A(rdata_A[31:0]),
             .rdata_B(data_out[31:0]));

    REG32 IR (.CE(IRWrite),
              .clk(clk),
              .D(data2CPU[31:0]),
              .rst(reset),
              .Q(Inst[31:0]));

    REG32 MDR (.CE(1'b1),
               .clk(clk),
               .D(data2CPU[31:0]),
               .rst(1'b0),
               .Q(MD[31:0]));

    REG32 PC_Reg (.CE(((~(zero ^ Branch) & PCWriteCond) | PCWrite) & MIO_ready),
                  .clk(clk),
                  .D(PC_out[31:0]),
                  .rst(reset),
                  .Q(PC_Current[31:0]));

    REG32 ALU_Out_Reg (.CE(1'b1),
                       .clk(clk),
                       .D(res[31:0]),
                       .rst(1'b0),
                       .Q(ALUout[31:0]));

    MUX4T1_32 WtData_4t1 (.I0(ALUout[31:0]),
                          .I1(MD[31:0]),
                          .I2(lui[31:0]),
                          .I3(PC_Current[31:0]),
                          .s(MemtoReg[1:0]),
                          .o(Wt_data[31:0]));

    MUX4T1_32 ALUB_2t1 (.I0(data_out[31:0]),
                        .I1(32'h4),
                        .I2(Imm32[31:0]),
                        .I3({Imm32[29:0], 1'b0, 1'b0}),
                        .s(ALUSrcB[1:0]),
                        .o(data_B[31:0]));

    MUX4T1_32 PC_4t1 (.I0(res[31:0]),
                      .I1(ALUout[31:0]),
                      .I2({PC_Current[31:28], Inst[25:0], 2'b00}),
                      .I3(ALUout[31:0]),
                      .s(PCSource[1:0]),
                      .o(PC_out[31:0]));

    MUX4T1_5 WtAddr_4t1 (.I0(Inst[20:16]),
                         .I1(Inst[15:11]),
                         .I2(ra[4:0]),
                         .I3(5'b0),
                         .s(RegDst[1:0]),
                         .o(Wt_addr[4:0]));

endmodule

module REG32(
           input clk,
           input rst,
           input CE,
           input [31:0] D,
           output reg [31:0] Q);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
                Q <= 0;
            end else if (CE) begin
                Q <= D;
            end
    end
endmodule

module ALU(input [31:0] A, B,
           input [3:0] ALU_operation,
           input [4:0] shamt,
           output reg [31:0] res,
           output zero,
           output reg overflow);
    wire [31:0] res_and, res_or, res_add, res_sub, res_nor, res_slt, res_srl, res_sll, res_xor;

    assign res_and = A & B;
    assign res_or  = A | B;
    assign res_add = A + B;
    assign res_sub = A - B;
    assign res_slt =(A < B) ? 32'h1 : 32'h0;
    assign res_srl = B >> shamt;
    assign res_sll = B << shamt;
    assign res_xor = A ^ B;
    assign zero = (res == 0)? 1: 0;


    //always @ (A or B or ALU_operation)
    always @*
        if(ALU_operation[3] == 1'b0) begin
            case (ALU_operation[2:0])
                3'b000: begin
                    res = res_and;
                    overflow = 1'b0;
                end
                3'b001: begin
                    res = res_or;
                    overflow = 1'b0;
                end
                3'b010: begin
                    res = res_add;
                    overflow = A[31] & ~res[31] | A[31] & B [31] | B[31] & ~res[31];
                end
                3'b110: begin
                    res = res_sub;
                    overflow = ~A[31] & res[31] | ~A[31] & B [31] | B[31] & res[31];
                end
                3'b111: begin
                    res = res_slt;
                    overflow = 1'b0;
                end
                3'b100: begin
                    res = ~res_or;
                    overflow = 1'b0;
                end
                3'b101: begin
                    res = res_srl;
                    overflow = 1'b0;
                end
                3'b011: begin
                    res = res_xor;
                    overflow = 1'b0;
                end
                default: res = 32'hx;
            endcase
        end
        else begin
            case(ALU_operation)
                4'b1000: begin 
                    res = res_sll;
                    overflow = 1'b0;
                end
                default: res = 32'hx;
            endcase
        end
endmodule

module Regs(input clk, rst, we,
            input [4:0] R_addr_A, R_addr_B, Wt_addr,
            input [31:0] Wt_data,
            output [31:0] rdata_A, rdata_B);

    reg [31:0] register [1:31];
    integer i;

	assign rdata_A = (R_addr_A == 0) ? 32'h0 : register[R_addr_A];
	assign rdata_B = (R_addr_B == 0) ? 32'h0 : register[R_addr_B];

	always @(posedge clk or posedge rst) begin
        if (rst == 1)
            for(i = 1; i < 32; i = i + 1)
                register[i] <= 32'h0;
        else if (Wt_addr != 0 && we == 1)
            register[Wt_addr] <= Wt_data;
    end

endmodule

module MUX4T1_5(input [4:0] I0, I1, I2, I3,
                input [1:0] s,
                output [4:0] o);
    assign o = s[1] ? (s[0] ? I3 :I2) : (s[0] ? I1 : I0);
endmodule

module MUX4T1_32(input [31:0] I0, I1, I2, I3,
                 input [1:0] s,
                 output [31:0] o);
    assign o = s[1] ? (s[0] ? I3 :I2) : (s[0] ? I1 : I0);
endmodule