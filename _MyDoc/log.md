* 本实验显示模块的难度其实还不如我数逻的大作业
* 主要的难度在于汇编程序的设计和MIO_Bus的设计
* PC到底是怎么在MCPU和RAM之间传递的: RAM.ram_addra <-- MIOB.addr_bus <-- MCPU.Addr_out <-- `IorD ? ALUout[31:0] : PC_Current[31:0];`
* PS2通信的，问题，需要在MIO bus中单独加入一个能给
* 0x2048寄存器
  * s1: the info of current key pressed
  * s3: const 0xF0: 断码
  * s4: const 0x04
  * s5: const 0x0, rand
* my2048寄存器
  * s0: const 0xC000, Rand
  * s1: const 0xD000, PS2
  * s2: the info of current key pressed
  * s3: const 0xF0
  * s4: const 0d1008=0x3F0
  * t9: Global rand ptr
  * **GroupCompression:**
    * s5: First elem
    * s6: Dir Mark for next block in group
    * s7: Dir Mark for changing group
    * t7: For keeping cur block's PHY ADDR
    * s8: For $ra preserved
  * **ThingsAfterMove:**
    * NonEmpty count: s5
    * Score count: s6


Debug:

* 一开始为了保险先用了老师提供的MCPU的核，后来有个bug半天弄不明白，最后发现是因为老师的核没有做sll指令
* 有时候会卡住不执行指令，回到单步模式才行，这是因为CPU_clk太快了