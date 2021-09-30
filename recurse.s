.text
.align 2
.globl main
main:
    addi    $sp, $sp, -8
    sw      $ra, 0($sp)
    sw      $s0, 4($sp)

    #print the prompt
    la      $a0, prompt     
    li      $v0, 4
    syscall

    li      $v0, 5
    syscall
    move    $s0, $v0    #$s0 holds the num of loops

    move    $a0, $s0

    jal     calc_f

    move    $a0, $v0
    li      $v0, 1
    syscall

    lw      $ra, 0($sp)
    lw      $s0, 4($sp)
    addi    $sp, $sp, 8
    jr      $ra


calc_f:
    addi    $sp, $sp, -20
    sw      $ra, 0($sp)

    move    $t0, $a0    #$t0 stores the number of recursion
    bnez    $t0, _recurse
    # li      $t1, 0
    # seq     $t2, $t0, $t1    #bnez    $t0, _recurse
    # bnez    $t2, _recurse
    li      $v0, 2
    j       _endloop

_recurse:
    li      $t3, 3
    addi    $t0, $t0, -1
    move    $a0, $t0
    mul     $t0, $t0, $t3
    addi    $t0, $t0, 1

    sw      $t0, 4($sp)
    sw      $t1, 8($sp)
    sw      $t2, 12($sp)
    sw      $t3, 16($sp)

    jal     calc_f

    lw      $t0, 4($sp)
    lw      $t1, 8($sp)
    lw      $t2, 12($sp)
    lw      $t3, 16($sp)

    move    $t4, $v0
    add     $t0, $t0, $t4
    move    $v0, $t0
    j       _endloop


_endloop:
    lw      $ra, 0($sp)
    addi    $sp, $sp, 20
    jr      $ra


.data
prompt:     .asciiz "Enter the value of n:"