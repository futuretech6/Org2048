`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:22:10 11/03/2014 
// Design Name: 
// Module Name:    Input_2_32bit 
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
module   SEnter_2_32(input clk,
                     input[2:0] BTN,				//��ӦSAnti_jitter�а���
                     input [4:0] Ctrl,				//{SW[7:5],SW[15],SW[0]}
                     input D_ready,					//��ӦSAnti_jitterɨ������Ч
                     input [4:0]Din,
                     output reg readn, 			//=0��ɨ����
                     output reg[31:0]Ai=32'h87654321,	//���32λ��һ��Ai
                     output reg[31:0]Bi=32'h12345678,	//���32λ������Bi
                     output reg [7:0 ]blink				//��������ָʾ
                     );
                     
   
endmodule
