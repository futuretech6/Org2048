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
  * s4: const 0xF000000
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
* 双口RAM的读写冲突问题
  * 改在MIOBUS内用寄存器存储方块信息，这也既方便读写，也方便reset的时候清空数据

一个神奇的bug，写成

```verilog
case({block_we, block_rd})  // Write first
    2'b1x: begin
        i = addr_bus[5:2];
        BlockInfo[i] = Cpu_data2bus;   // CPU w
    end
    2'b01: BlockType2CPU = {28'b0, BlockInfo[addr_bus[7:0] >> 2]};  // CPU r
    2'b00: BlockType = {28'b0, BlockInfo[BlockID]};  // CPU no IO, for Display
endcase
```

根本没法向寄存器写东西，但是换成

```verilog
if (block_we) begin
    BlockInfo[addr_bus[5:2]] = Cpu_data2bus;   // CPU w
end
else begin
    if (block_rd) begin
        BlockType2CPU = {28'b0, BlockInfo[addr_bus[7:0] >> 2]};  // CPU r
    end
    else
        BlockType = {28'b0, BlockInfo[BlockID]};  // CPU no IO, for Display
end
```

就正常了，合理怀疑是因为ISE为了防止出现读写锁存把他优化掉了

另外，写的时候不能`if (block_we) begin`，因为可能已经不是对方块进行的IO了而block_we还没反应过来，这样一次会有好多个块的信息一起被修改成同一个信息（因为addr_bus此时已跳转）。改成`if (block_we && addr_bus[31:28] == 4'hF) begin`就好了