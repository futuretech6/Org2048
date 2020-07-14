Init:
    sll $zero, $zero, 0  # Score
    sll $zero, $zero, 0  # isDead
    # Set const
    lui $s1, 0xD000  # Addr for PS2
    # addi $s3, $zero, 0xF0
    xor $s3, $s3, $s3
    lui $t7, 0xE000  # 0xE0000000: Per_in
    sw $s3, 0($t7)   # Store score
    xor $s4, $s4, $s4
    lui $s4, 0xF000
    addi $sp, $zero, 0x400
    jal RandGen

MainLoop:
    lw $s2, 0($s1)
    beq $s2, $zero, MainLoop
    # beq $s2, $s3, MainLoop  # is duan_ma

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

    WSAD_Wait:
        lw $t7, 0($s1)
        beq $s2, $t7, WSAD_Wait  # Same BTN
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

    xor $t3, $t3, $t3  # t3: the num that has been compressed yet
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
        j Done_C1G

    Case_1Block:
        j Done_C1G

    Case_2Blocks:
        bne $a2, $a3, Done_C1G
            beq $a2, $t3, Done_C1G  # Compr yet
            addi $a3, $a3, 1
            and $t1, $a3, $a3
            jal GetScore
            add $s3, $s3, $v1
            xor $a2, $a2, $a2
            j Case_1Block

    Case_3Blocks:
        bne $a2, $a3, C3_2ne3
            beq $a2, $t3, Done_C1G  # Compr yet
            addi $a3, $a3, 1
            and $t3, $a3, $a3
            and $t1, $a3, $a3
            jal GetScore
            add $s3, $s3, $v1
            and $a2, $a1, $a1,
            xor $a1, $a1, $a1
            j Case_2Blocks
        C3_2ne3:

        bne $a1, $a2, C3_1ne2
            beq $a1, $t3, Done_C1G  # Compr yet
            addi $a2, $a2, 1
            and $t3, $a2, $a2
            and $t1, $a2, $a2
            jal GetScore
            add $s3, $s3, $v1
            xor $a1, $a1, $a1
            j Case_2Blocks
        C3_1ne2:

        j Done_C1G

    Case_4Blocks:
        bne $a2, $a3, C4_2ne3
            addi $a3, $a3, 1
            and $t3, $a3, $a3
            and $t1, $a3, $a3
            jal GetScore
            add $s3, $s3, $v1
            and $a2, $a1, $a1
            and $a1, $a0, $a0
            xor $a0, $a0, $a0
            j Case_3Blocks
        C4_2ne3:

        bne $a1, $a2, C4_1ne2
            addi $a2, $a2, 1
            and $t3, $a2, $a2
            and $t1, $a2, $a2
            jal GetScore
            add $s3, $s3, $v1
            and $a1, $a0, $a0
            xor $a0, $a0, $a0
            j Case_3Blocks
        C4_1ne2:

        bne $a0, $a1, C4_0ne1
            addi $a1, $a1, 1
            and $t3, $a1, $a1
            and $t1, $a1, $a1
            jal GetScore
            add $s3, $s3, $v1
            xor $a0, $a0, $a0
            j Case_3Blocks
        C4_0ne1:

        j Done_C1G

    Done_C1G:

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
    loop_P1G:  # if Bi is empty, push B(i-1) to Bi
        beq $a3, $zero, Push2_P1G
        Done2_P1G:
        beq $a2, $zero, Push1_P1G
        Done1_P1G:
        beq $a1, $zero, Push0_P1G
        Done0_P1G:

        addi $v0, $v0, -1
        bne $v0, $zero, loop_P1G
        j loopDone_P1G

        Push2_P1G:
            and $a3, $a2, $a2
            xor $a2, $a2, $a2
            j Done2_P1G
        Push1_P1G:
            and $a2, $a1, $a1
            xor $a1, $a1, $a1
            j Done1_P1G
        Push0_P1G:
            and $a1, $a0, $a0
            xor $a0, $a0, $a0
            j Done0_P1G
    loopDone_P1G:
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

        # jal GetScore
        # add $s6, $s6, $v1

        addi $v0, $v0, -1
        addi $t0, $t0, 4
        bne $v0, $zero, loop1_TAM

    lui $t7, 0xE000  # 0xE0000000: Per_in
    # sw $s6, 0($t7)   # Store score
    sw $s3, 0($t7)   # Store score

    addi $s5, $s5, -16
    beq $s5, $zero, DeadLoop  # 16 blocks after compr

    jal RandGen

    addi $sp, $sp, -4
    lw $ra, 0($sp)
    jr $ra
# ThingsAfterMove ends here

GetScore:  # no sllv implementation given
    # @ret: v1 = pow(2, t1), but 2^0 = 0(0 score for empty block)
    sw $ra, 0($sp)
    sw $v0, 4($sp)
    addi $sp, $sp, 8

    xor $v1, $v1, $v1   # score = 0
    beq $t1, $zero, Done_GS

    and $v0, $t1, $t1
    addi $v1, $zero, 1

    Loop_GS:
        sll $v1, $v1, 1
        addi $v0, $v0, -1
        bne $v0, $zero, Loop_GS

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
    lui $t7, 0xE000  # 0xE0000000: Per_in
    addi $s3, $zero, -1
    sw $s3, 0($t7)   # Store score
    j DeadLoop
