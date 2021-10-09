.text
.align 2
.globl main
main:
    addi    $sp, $sp, -32
    sw      $ra, 0($sp)
    sw      $s0, 4($sp)
    sw      $s1, 8($sp)
    sw      $s3, 12($sp)
    sw      $s4, 16($sp)
    s.s     $f20, 20($sp)
    s.s     $f21, 24($sp)
    s.s     $f22, 28($sp)

    li      $s3, 0       #s3 is the head
    #registers in use - s3, s0, s1, f20, f21, f22, s4, a0
_main_while_loop:
    #getting the pizza name
    la      $a0, namePrompt
    li      $v0, 4
    syscall
    li      $v0, 8
    la      $a0, name
    li      $a1, 64
    syscall
    move    $s0, $a0        #$s0 is the pizza name

    #check if name == DONE
    la      $a0, done
    move    $a1, $s0
    jal     strcmp
    move    $s1, $v0
    beqz    $s1, _done_get_pizza

    la      $a0, dPrompt
    li      $v0, 4
    syscall
    li      $v0, 6
    syscall
    mov.s   $f20, $f0        #$f20 is the pizza diameter

    la      $a0, cPrompt
    li      $v0, 4
    syscall
    li      $v0, 6
    syscall
    mov.s   $f21, $f0        #$f21 is the pizza cost

    #calculate ppd
    mov.s   $f12, $f20
    mov.s   $f13, $f21
    jal     calc_ppd
    mov.s   $f22, $f0       #$f22 is the ppd

    #malloc space for new struct
    li      $v0, 9
    li      $a0, 72
    syscall
    #put pizza struct in linked list
    move    $s4, $v0        #s4 is temp reg
    move    $a0, $s0        #put name
    move    $a1, $s4
    jal     strcpy
    move    $s4, $v0
    s.s     $f22, 64($s4)   #put ppd
    sw      $s3, 68($s4)    #put next
    move    $s3, $s4

    j       _main_while_loop
_done_get_pizza:
    move    $a0, $s3
    jal     sort
    move    $a0, $v0
    jal     print_list

    lw      $ra, 0($sp)
    lw      $s0, 4($sp)
    lw      $s1, 8($sp)
    lw      $s3, 12($sp)
    lw      $s4, 16($sp)
    l.s     $f20, 20($sp)
    l.s     $f21, 24($sp)
    l.s     $f22, 28($sp)
    addi    $sp, $sp, 32
    jr      $ra


calc_ppd:
    addi    $sp, $sp, -24
    sw      $ra, 0($sp)
    s.s     $f4, 4($sp)
    s.s     $f5, 8($sp)
    s.s     $f6, 12($sp)
    s.s     $f7, 16($sp)
    s.s     $f8, 20($sp)

    mov.s   $f4, $f12       #4 = diameter  (12)
    mov.s   $f5, $f13       #5 = cost      (13)
    mtc1    $zero, $f6      #6 = zero

    #check if either are = 0. If so, go to 0
    c.eq.s  $f5, $f6
    bc1t    _zero

    c.eq.s  $f4, $f6
    bc1t    _zero

    mul.s   $f0, $f4, $f4
    l.s     $f7, PI         #7 = pi
    l.s     $f8, fourth     #8 = 1/4
    mul.s   $f0, $f0, $f7
    mul.s   $f0, $f0, $f8
    div.s   $f0, $f0, $f5
    b       _end_ppd
_zero:
    mov.s   $f0, $f6
    b       _end_ppd
_end_ppd:
    sw      $ra, 0($sp)
    s.s     $f4, 4($sp)
    s.s     $f5, 8($sp)
    s.s     $f6, 12($sp)
    s.s     $f7, 16($sp)
    s.s     $f8, 20($sp)
    addi    $sp, $sp, 24
    jr      $ra


strcmp:
    #a0 is string 1, a1 is string2
    #returns <0 if str1<sr2, >0 if s1>s2, 0 if equal
    addi    $sp, $sp, -4
    sw      $ra, 0($sp)
    la      $t2, nln        #t2 is \n
    lb      $t2, 0($t2)
_strcmp_loop:
    li      $v0, 0
    lb      $t0, 0($a0)     #t0 is the curr byte of string 1
    lb      $t1, 0($a1)     #t1 is the curr byte of string 2
    blt     $t0, $t1, _str1_sm
    bgt     $t0, $t1, _str1_lg
    beq     $t0, $t2, _end_strcmp
    addi    $a0, $a0, 1
    addi    $a1, $a1, 1
    j       _strcmp_loop
_str1_sm:
    li      $v0, -1
    j       _end_strcmp
_str1_lg:
    li      $v0, 1
    j       _end_strcmp
_end_strcmp:
    lw      $ra, 0($sp)
    addi    $sp, $sp, 4
    jr      $ra


strcpy:
    #a0 is string to copy
    #a1 is the struct we're copying into
    #return the struct
    addi    $sp, $sp, -4
    sw      $ra, 0($sp)

    li      $t1, 0
    la      $t2, nln
    lb      $t2, 0($t2)

    move    $t3, $a1
_strcpy_loop:
    lb      $t0, 0($a0)
    beq     $t0, $t2, _end_strcpy
    beq     $t0, $t1, _end_strcpy
    sb      $t0, 0($a1)
    addi    $a0, $a0, 1
    addi    $a1, $a1, 1
    j       _strcpy_loop
_end_strcpy:
    sb      $zero, 0($a1)
    move    $v0, $t3
    lw      $ra, 0($sp)
    addi    $sp, $sp, 4
    jr      $ra 


print_list:
    addi    $sp, $sp, -4
    sw      $ra, 0($sp)

    move    $t0, $a0        #t0 is the head
    beq     $t0, $zero, _end_print_list
_while_print_list:
    beq     $zero, $t0, _end_print_list

    la      $a0, 0($t0)     #print name
    li      $v0, 4
    syscall
    la      $a0, space
    li      $v0, 4
    syscall
    l.s      $f12, 64($t0)  #print ppd
    li		$v0, 2
    syscall
    la      $a0, nln
    li      $v0, 4
    syscall

    lw    $t0, 68($t0)

    j       _while_print_list
_end_print_list:
    lw      $ra, 0($sp)
    addi    $sp, $sp, 4
    jr      $ra 

swap:
    addi    $sp, $sp, -4
    sw      $ra, 0($sp)

    move    $t0, $a0    #t0 is node1
    move    $t1, $a1    #t1 is node2
    #move    $t3, $a2    #t3 is prev
    lw      $t2, 68($t1)    #t2 is node2->next

    #bne     $t4, $zero, _set_prev
    sw      $t0, 68($t1)    #put node1 into node2->next
    sw      $t2, 68($t0)    #put node2->next into node1->next

    move    $v0, $t1

    lw      $ra, 0($sp)
    addi    $sp, $sp, 4
    jr      $ra

# _set_prev:
#     sw      $t1, 68($t3)

sort:
    addi    $sp, $sp, -32
    sw      $ra, 0($sp)

    move    $t7, $a0
    move    $t0, $a0        #t0 is the head
    
    beq     $t0, $zero, _end_sort
_while_outer_sort:
    li      $t8, 0          #the counter
    li      $t4, 0          #t4 is prev
_while_sort:
    # move    $a0, $t7
    # sw      $t0, 4($sp)
    # sw      $t1, 8($sp)
    # sw      $t2, 12($sp)
    # sw      $t3, 16($sp)
    # sw      $t4, 20($sp)
    # sw      $t5, 24($sp)
    # sw      $t8, 28($sp)
    # jal     print_list
    # lw      $t0, 4($sp)
    # lw      $t1, 8($sp)
    # lw      $t2, 12($sp)
    # lw      $t3, 16($sp)
    # lw      $t4, 20($sp)
    # lw      $t5, 24($sp)
    # lw      $t8, 28($sp)

    lw      $t1, 68($t0)    #t1 is the next node
    beq     $zero, $t1, _end_sort
    
    lw      $t2, 64($t0)    #t2 is curr->ppd
    lw      $t3, 64($t1)    #t3 is next->ppd

    blt     $t2, $t3, _sort_swap_nodes
    beq     $t2, $t3, _sort_cmp_names

    move    $t4, $t0
    move    $t0, $t1

    j       _while_sort
_sort_swap_nodes:
    addi    $t8, $t8, 1

    move    $a0, $t0
    move    $a1, $t1
    #move    $a2, $t4

    sw      $t0, 4($sp)
    sw      $t1, 8($sp)
    sw      $t2, 12($sp)
    sw      $t3, 16($sp)
    sw      $t4, 20($sp)
    sw      $t5, 24($sp)
    sw      $t8, 28($sp)
    jal     swap
    lw      $t0, 4($sp)
    lw      $t1, 8($sp)
    lw      $t2, 12($sp)
    lw      $t3, 16($sp)
    lw      $t4, 20($sp)
    lw      $t5, 24($sp)
    lw      $t8, 28($sp)

    beq     $t0, $t7, _movehead

_end_end_1:
    move    $t0, $v0
    bne     $t4, $zero, _set_prev
_end_end_2:
    move    $t4, $t0
    j       _while_sort  
_set_prev:
    sw      $t0, 68($t4)
    j       _end_end_2
_movehead:
    move    $t7, $v0
    j       _end_end_1

_sort_cmp_names:
    la      $a0, 0($t0)
    la      $a1, 0($t1)

    sw      $t0, 4($sp)
    sw      $t1, 8($sp)
    sw      $t2, 12($sp)
    sw      $t3, 16($sp)
    jal     strcmp
    lw      $t0, 4($sp)
    lw      $t1, 8($sp)
    lw      $t2, 12($sp)
    lw      $t3, 16($sp)

    bgt     $v0, $zero, _sort_swap_nodes
    move    $t4, $t0
    move    $t0, $t1
    j       _while_sort
_end_sort:
    beqz    $t8, _end_entire_sort
    move    $t0, $t7
    j       _while_outer_sort
_end_entire_sort:
    move    $v0, $t7
    lw      $ra, 0($sp)
    addi    $sp, $sp, 32
    jr      $ra 

.data
PI:             .float 3.14159265358979323846 
zero:           .float 0.0
fourth:         .float 0.25
name:           .space 64
namePrompt:     .asciiz "Pizza name:"
dPrompt:        .asciiz "Pizza diameter:"
cPrompt:        .asciiz "Pizza cost:"
done:           .asciiz "DONE\n"
nln:            .asciiz "\n"
space:          .asciiz " "

#The struct: name-64 bytes, ppd-4 bytes, next-pointer to next struct (4 bytes)
    #struct size: 64+4+4 = 72 bytes
