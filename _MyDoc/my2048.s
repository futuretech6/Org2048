Init:
    sll $r0, $r0, 0  # Score
    sll $r0, $r0, 0  # isDead
    # Set const
    lui $s1, 0xD000  # Addr for PS2
    addi $s3, $zero, 0xF0
    addi $s4, $zero, 0x3C0  # 64B = 16W
    addi $sp, $zero, 0x300
    jal RandGen

MainLoop:
    lw $s2, 0($s1)
    beq $s2, $zero, MainLoop
    beq $s2, $zero, MainLoop

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
        jal GroupsCompr

    isDown:
        addi $s5, $zero, 48
        addi $s6, $zero, -16
        addi $s7, $zero, 4
        jal GroupsCompr

    isLeft:
        addi $s5, $zero, 12
        addi $s6, $zero, -4
        addi $s7, $zero, 16
        jal GroupsCompr

    isRight:
        addi $s5, $zero, 0
        addi $s6, $zero, 4
        addi $s7, $zero, 16
        jal GroupsCompr

    jal ThingsAfterMove
    j MainLoop
# MainLoop ends here

GroupsCompr:
    sw $ra, 0($sp)
    addi $sp, $sp, 4

    add $t0, $s5, $s4  # t0: cur group's 1st elem PHY ADDR
    jal OneGroupCompr
    add $t0, $t0, $s7
    jal OneGroupCompr
    add $t0, $t0, $s7
    jal OneGroupCompr
    add $t0, $t0, $s7
    jal OneGroupCompr

    addi $sp, $sp, -4
    lw $ra, 0($sp)
    jr $ra
# GroupsCompr ends here


OneGroupCompr:  # t0: cur group's 1st elem PHY ADDR
    sw $ra, 0($sp)
    addi $sp, $sp, 4
    xor $t1, $t1, $t1  # t1: cur group's Block Num
    and $t2, $t0, $t0  # t2: cur block's PHY ADDR
    # Load 4 blocks' data to a0~a3
    lw $a0, 0($t2)
    add $t2, $t2, $s6
    lw $a1, 0($t2)
    add $t2, $t2, $s6
    lw $a2, 0($t2)
    add $t2, $t2, $s6
    lw $a3, 0($t2)

    jal PushOneGroup

    Choose_BlockNum:
        beq $t1, $zero, Case_0Block
        addi $t1, $t1, -1
        beq $t1, $zero, Case_1Block
        addi $t1, $t1, -1
        beq $t1, $zero, Case_2Block
        addi $t1, $t1, -1
        beq $t1, $zero, Case_3Block
        addi $t1, $t1, -1
        beq $t1, $zero, Case_4Block

    Case_0Block:
        j Done_OGC

    Case_1Block:
        j Done_OGC
        
    Case_2Block:
        bne $a2, $a3, Done_OGC
        xor $a2, $a2, $a2
        addi $a3, $a3, 1
        j Case_1Block
        
    Case_3Block:
        bne $a1, $a2, C3_1ne2
            xor $a1, $a1, $a1
            addi $a2, $a2, 1
        C3_1ne2:
        
        bne $a2, $a3, C3_2ne3
            xor $a2, $a2, $a2
            addi $a3, $a3, 1
        C3_2ne3:

        jal PushOneGroup
        j Choose_BlockNum

    Case_4Block:
        bne $a0, $a1, C4_0ne1
            xor $a0, $a0, $a0
            addi $a1, $a1, 1
        C4_0ne1:

        bne $a1, $a2, C4_1ne2
            xor $a1, $a1, $a1
            addi $a2, $a2, 1
        C4_1ne2:
        
        bne $a2, $a3, C4_2ne3
            xor $a2, $a2, $a2
            addi $a3, $a3, 1
        C4_2ne3:

        jal PushOneGroup
        j Choose_BlockNum

    Done_OGC:
    sw $a3, 0($t2)
    sub $t2, $t2, $s6
    sw $a2, 0($t2)
    add $t2, $t2, $s6
    sw $a1, 0($t2)
    add $t2, $t2, $s6
    sw $a0, 0($t2)

    addi $sp, $sp, -4
    lw $ra, 0($sp)
    jr $ra
# OneGroupCompr ends here

PushOneGroup:  # Jusr push(form 0 to 3), no compression
# @param: t0: cur group's 1st elem PHY ADDR
# @ret: t1: cur group's block num
    sw $ra, 0($sp)
    addi $sp, $sp, 4

    addi $v0, $zero, 4
    loop1_POG:
        bne $a3, $zero, Push2_POG
        Done2_POG:
        bne $a2, $zero, Push1_POG
        Done1_POG:
        bne $a1, $zero, Push0_POG
        Done0_POG:
        addi $v0, $v0, -1
        bne $v0, $zero, loop1_POG
        j loop1Done_POG

        Push2_POG:
            and $a3, $a2, $a2
        Push1_POG:
            and $a2, $a1, $a1
        Push0_POG:
            and $a2, $a1, $a1
    loop1Done_POG:
    # Count Block Num
    xor $t1, $t1, $t1
    slt $t7, $zero, $a0
    add $t1, $t1, $t7
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
    # get score an isDead
    sw $ra, 0($sp)
    addi $sp, $sp, 4

    xor $s5, $s5, $s5  # NonEmpty
    xor $s6, $s6, $s6  # Score
    addi $v0, $zero, 16
    and $t0, $s4, $s4  # t0: cur block's PHY ADDR
    loop1_TAM:  # 0x89
        lw $t1, 0($t0) # t1: cur block's data
        slt $t7, $zero, $t1
        add $s5, $s5, $t7

        jal GetScore
        add $s6, $s6, $v1

        addi $v0, $v0, -1
        bne $v0, $zero, loop1_TAM
    
    sw $s6, 0($zero) # Store score

    addi $s5, $s5, -16
    beq $s5, $zero, DeadLoop
    DeadLoop:
        sw $s4, 4($zero)
        j DeadLoop

    jal RandGen

    addi $sp, $sp, -4
    lw $ra, 0($sp)
    jr $ra
# ThingsAfterMove ends here

GetScore:
    # @ret: v1 = pow(2, t1), but 2^0 = 0(0 score for empty block)
    sw $ra, 0($sp)  # 0x99
    sw $v0, 4($sp)

    xor $v1, $v1, $v1
    beq $t1, $zero, Done_GS
    addi $sp, $sp, 8

    and $v0, $t1, $t1
    addi $v1, $zero, 1

    beq $v0, $zero, Done_GS
        sll $v1, $v1, 1 # 0x9f
    Done_GS:

    addi $sp, $sp, -8
    lw $v0, 4($sp)
    lw $ra, 0($sp)
    jr $ra  # 0xa3
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