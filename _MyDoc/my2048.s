Init:
    sll $zero, $zero, 0  # Score
    sll $zero, $zero, 0  # isDead
    # Set const
    lui $s1, 0xD000  # Addr for PS2
    addi $s3, $zero, 0xF0
    xor $s4, $s4, $s4
    lui $s4, 0xF000
    addi $sp, $zero, 0x400
    jal RandGen

MainLoop:
    lw $s2, 0($s1)
    beq $s2, $zero, MainLoop
    beq $s2, $s3, MainLoop

    # FindDir
    addi $t0, $zero, 0x1D
    beq $s2, $t0, isUp
    addi $t0, $zero, 0x1B
    beq $s2, $t0, isDown
    addi $t0, $zero, 0x1C
    beq $s2, $t0, isLeft
    addi $t0, $zero, 0x23
    beq $s2, $t0, isRight
    j MainLoop  # N Found Match

    # 12 13 14 15
    # 08 09 10 11
    # 04 05 06 07
    # 00 01 02 03
    # Warning: mention Byte and Word's diff
    isUp:
        addi $s5, $zero, 0
        addi $s6, $zero, 16
        addi $s7, $zero, 4
        j PressedWSAD

    isDown:
        addi $s5, $zero, 48
        addi $s6, $zero, -16
        addi $s7, $zero, 4
        j PressedWSAD

    isLeft:
        addi $s5, $zero, 12
        addi $s6, $zero, -4
        addi $s7, $zero, 16
        j PressedWSAD

    isRight:
        addi $s5, $zero, 0
        addi $s6, $zero, 4
        addi $s7, $zero, 16
        j PressedWSAD
    
    PressedWSAD:
    jal GroupsCompr
    jal ThingsAfterMove
    j MainLoop
# MainLoop ends here

GroupsCompr:
    sw $ra, 0($sp)
    addi $sp, $sp, 4

    add $t0, $s4, $s5  # t0: cur group's 1st elem PHY ADDR
    jal ComprOneGroup
    add $t0, $t0, $s7
    jal ComprOneGroup
    add $t0, $t0, $s7
    jal ComprOneGroup
    add $t0, $t0, $s7
    jal ComprOneGroup

    addi $sp, $sp, -4
    lw $ra, 0($sp)
    jr $ra
# GroupsCompr ends here

ComprOneGroup:  # t0: cur group's 1st elem PHY ADDR
    sw $ra, 0($sp)
    addi $sp, $sp, 4

    # Load 4 blocks' data to a0~a3
    and $t2, $t0, $t0  # t2: cur block's PHY ADDR
    lw $a0, 0($t2)
    add $t2, $t2, $s6
    lw $a1, 0($t2)
    add $t2, $t2, $s6
    lw $a2, 0($t2)
    add $t2, $t2, $s6
    lw $a3, 0($t2)

    jal PushOneGroup  # t1: cur group's Block Num

    Choose_BlockNum:
        beq $t1, $zero, Case_0Block
        addi $t1, $t1, -1
        beq $t1, $zero, Case_1Block
        addi $t1, $t1, -1
        beq $t1, $zero, Case_2Blocks
        addi $t1, $t1, -1
        beq $t1, $zero, Case_3Blocks
        addi $t1, $t1, -1
        beq $t1, $zero, Case_4Blocks

    Case_0Block:
        j Done_COG

    Case_1Block:
        j Done_COG

    Case_2Blocks:
        bne $a2, $a3, Done_COG
        xor $a2, $a2, $a2
        addi $a3, $a3, 1
        j Case_1Block

    Case_3Blocks:
        bne $a2, $a3, C3_2ne3
            xor $a2, $a2, $a2
            addi $a3, $a3, 1
            jal PushOneGroup
            j Case_2Blocks
        C3_2ne3:

        bne $a1, $a2, C3_1ne2
            xor $a1, $a1, $a1
            addi $a2, $a2, 1
            jal PushOneGroup
            j Case_2Blocks
        C3_1ne2:

        j Done_COG

    Case_4Blocks:
        bne $a2, $a3, C4_2ne3
            xor $a2, $a2, $a2
            addi $a3, $a3, 1
            jal PushOneGroup
            j Case_3Blocks
        C4_2ne3:

        bne $a1, $a2, C4_1ne2
            xor $a1, $a1, $a1
            addi $a2, $a2, 1
            jal PushOneGroup
            j Case_3Blocks
        C4_1ne2:

        bne $a0, $a1, C4_0ne1
            xor $a0, $a0, $a0
            addi $a1, $a1, 1
            jal PushOneGroup
            j Case_3Blocks
        C4_0ne1:

        j Done_COG

    Done_COG:

    # Save 4 blocks' data from a3~a0 to miobus
    sw $a3, 0($t2)
    sub $t2, $t2, $s6
    sw $a2, 0($t2)
    sub $t2, $t2, $s6
    sw $a1, 0($t2)
    sub $t2, $t2, $s6
    sw $a0, 0($t2)

    addi $sp, $sp, -4
    lw $ra, 0($sp)
    jr $ra
# ComprOneGroup ends here

PushOneGroup:  # Jusr push(form 0 to 3), no compression
# @param: t0: cur group's 1st elem PHY ADDR
# @ret: t1: cur group's block num
    sw $ra, 0($sp)
    addi $sp, $sp, 4

    addi $v0, $zero, 3  # max 3 pushes: 0->1->2->3
    loop1_POG:  # if Bi is empty, push B(i-1) to Bi
        beq $a3, $zero, Push2_POG
        Done2_POG:
        beq $a2, $zero, Push1_POG
        Done1_POG:
        beq $a1, $zero, Push0_POG
        Done0_POG:

        addi $v0, $v0, -1
        bne $v0, $zero, loop1_POG
        j loop1Done_POG

        Push2_POG:
            and $a3, $a2, $a2
            xor $a2, $a2, $a2
            j Done2_POG
        Push1_POG:
            and $a2, $a1, $a1
            xor $a1, $a1, $a1
            j Done1_POG
        Push0_POG:
            and $a1, $a0, $a0
            xor $a0, $a0, $a0
            j Done0_POG
    loop1Done_POG:
    # Count Block Num
    xor $t1, $t1, $t1
    slt $t7, $zero, $a0
    add $t1, $zero, $t7
    slt $t7, $zero, $a1
    add $t1, $t1, $t7
    slt $t7, $zero, $a2
    add $t1, $t1, $t7
    slt $t7, $zero, $a3
    add $t1, $t1, $t7

    addi $sp, $sp, -4
    lw $ra, 0($sp)
    jr $ra
# PushOneGroup ends here

ThingsAfterMove:
    # get score and isDead
    sw $ra, 0($sp)
    addi $sp, $sp, 4

    xor $s5, $s5, $s5  # NonEmpty
    xor $s6, $s6, $s6  # Score
    addi $v0, $zero, 16
    and $t0, $s4, $s4  # t0: cur block's PHY ADDR
    loop1_TAM:
        lw $t1, 0($t0) # t1: cur block's data
        slt $t7, $zero, $t1
        add $s5, $s5, $t7

        jal GetScore
        add $s6, $s6, $v1

        addi $v0, $v0, -1
        addi $t0, $t0, 4
        bne $v0, $zero, loop1_TAM

    sw $s6, 0($zero) # Store score

    addi $s5, $s5, -16
    beq $s5, $zero, DeadLoop  # 16 blocks after compr

    jal RandGen

    addi $sp, $sp, -4
    lw $ra, 0($sp)
    jr $ra
# ThingsAfterMove ends here

GetScore:
    # @ret: v1 = pow(2, t1), but 2^0 = 0(0 score for empty block)
    sw $ra, 0($sp)
    sw $v0, 4($sp)
    addi $sp, $sp, 8

    xor $v1, $v1, $v1   # score = 0
    beq $t1, $zero, Done_GS

    and $v0, $t1, $t1
    addi $v1, $zero, 1

    beq $v0, $zero, Done_GS
        sll $v1, $v1, 1
    Done_GS:

    addi $sp, $sp, -8
    lw $v0, 4($sp)
    lw $ra, 0($sp)
    jr $ra
# GetScore ends here

RandGen:
    sw $ra, 0($sp)
    addi $sp, $sp, 4

    while_RG:
        lui $t0, 0xC000    # Get Rand from MIO_BUS
        lw $t0, 0($t0)
        sll $t0, $t0, 2    # Byte -> Word
        add $t0, $t0, $s4  # t0: wanted addr
        lw $t2, 0($t0)     # t2: data in block
        bne $t2, $zero, while_RG

    addi $t1, $zero, 1
    sw $t1, 0($t0)

    addi $sp, $sp, -4
    lw $ra, 0($sp)
    jr $ra
# RandGen ends here

DeadLoop:
    sw $s4, 4($zero)
    j DeadLoop
