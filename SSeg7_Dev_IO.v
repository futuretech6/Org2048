`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:28:50 12/29/2015 
// Design Name: 
// Module Name:    SSeg7_Dev_IO 
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
module  SSeg7_Dev(input clk,			//	ʱ��
                  input rst,			//��λ
                  input Start,		//����ɨ������
                  input SW0,			//�ı�(16����)/ͼ��(����)�л�
                  input flash,		//�߶�����˸Ƶ��
                  input[31:0]Hexs,	//32λ����ʾ��������
                  input[7:0]point,	//�߶���С���㣺8��
                  input[7:0]LES,		//�߶���ʹ�ܣ�=1ʱ��˸
                  output seg_clk,	//������λʱ��
                  output seg_sout,	//�߶���ʾ����(�������)
                  output SEG_PEN,	//�߶�����ʾˢ��ʹ��
                  output seg_clrn	//�߶�����ʾ����
                  );

endmodule
