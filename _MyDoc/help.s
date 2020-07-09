# init:
#     # 假设我前面预留512条指令的位置，那么我的数据起始地址就是4*512.
#     addi $s6, $zero, 0x3F0        # s6:存放16个格子数据的起始地址.
#     addi $t0, $zero, 0x1;
#     sw $t0, 0($s6);
#     sw $t0, 4($s6);
#     addi $s5, $zero, 0x440        # 存放伪随机数列的起始地址
#     addi $s4, $zero, 0x04;        # 比较常量4
#     # addi $a3, $zero, 0xFFFFD000;
#     lui $a3, 0xD000;    # 存放按键信息的地址
#     # slo $a3;
#     # slo $a3;
#     # slo $a3;
#     # slo $a3;
#     # slo $a3;
#     addi $t9, $zero, 0x444;        # 存放当前操作的伪随机数
#     add $s7, $zero, $zero;
#     add $s2, $zero, $zero;
#     addi $s3, $zero, 0xF0;
# begin:
#     lw $s1, 0($a3);
#     beq $s1, $s3, begin;
#     beq $s1, $s2, begin;
#     sw $s1, 0($s1)
#     sw $s1, 0($s1)
#     sw $s1, 0($s1)
#     j begin

start:
lui $s0, 0xC000
lw $t0, 0($s0)
sw $t0, 0($s0)
j start