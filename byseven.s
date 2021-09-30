.text
.align 2
.globl main
main:
    addi    $sp, $sp, -4
    sw      $ra, 0($sp)

    #print the prompt
    la      $a0, prompt     
    li      $v0, 4
    syscall

    li      $v0, 5
    syscall
    move    $t0, $v0    #$t0 holds the num of loops

    li      $t1, 0      #$t1 is the counter
    li      $t2, 0      #t2 is the multiples of 7

#start the loop
_loop:
    slt     $t3, $t1, $t0   #t3 = 0 if i == num
    beqz    $t3, _endloop   #skip if done
    addi    $t2, $t2, 7     #add 7

    #print the result and newline
    move    $a0, $t2
    li      $v0, 1
    syscall
    la    $a0, nln
    li      $v0, 4
    syscall

    #increment counter & restart loop
    addi    $t1, $t1, 1
    j       _loop
    
_endloop:
    lw      $ra, 0($sp)
    addi    $sp, $sp, 4
    jr      $ra
    


.data
prompt:     .asciiz "Enter the number you'd like to see:"
nln:        .asciiz "\n"