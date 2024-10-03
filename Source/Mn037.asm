#Chuong trinh: nhan 2 so nguyen 32 bit
#Data segment
.data

    space:          .asciiz " "
    result:         .asciiz "The product, using my program is: "
    endLine:        .asciiz "\n"
    .align 2
    dulieu1: .space 4
    .align 2
    dulieu2: .space 4
    tenfile: .asciiz "INT2.BIN"
    fdescr: .word 0
    str_dl1: .asciiz "Du lieu 1 = "
    str_dl2: .asciiz "Du lieu 2 = "
    str_loi: .asciiz "Mo file bi loi."
    str_newline: .asciiz "\n"
    .align 3
    double_1: .double 4294967296.0
    double_2: .double 2.0
    double_3: .double 1.0
    double_4: .double -1.0
    buffer_product: .space 8 
#Code segment    
.text
main:
 # Nhap (syscall)
    # Xu ly
    # mo file doc
    la $a0, tenfile
    addi $a1, $zero, 0 # a1=0 (read only)
    addi $v0, $zero, 13
    syscall
    bgez $v0, tiep
# Cac chuong trinh con khac
    
baoloi:
    li $v0, 4
    la $a0, str_loi
    syscall
    j Kthuc
tiep:
    sw $v0, fdescr # luu file descriptor
    # doc file
    # 4 byte dau (kieu word)
    lw $a0, fdescr
    la $a1, dulieu1
    addi $a2, $zero, 4
    addi $v0, $zero, 14
    syscall
    # 4 byte sau (kieu word)
    la $a1, dulieu2
    addi $a2, $zero, 4
    addi $v0, $zero, 14
    syscall
    # dong file
    lw $a0, fdescr
    addi $v0, $zero, 16
    syscall
# Xuat ket qua (syscall)   
    #"welcome" screen                # print the prompt
    li  $v0, 4             # code for print_string
    la  $a0, endLine       # point $a0 to prompt string
    syscall

    lw $s0, dulieu1      # T?i giá tr? dulieu1 vào $s0
    # set multiplier to 2
    lw $s1,dulieu2
Diemtrave:
    bltz $s0, is_negative_s0  # Branch if s0 < 0 to label is_negative
    bltz $s1, is_negative_s1  # Branch if s1 < 0 to label is_negative
    j tieptuc
is_negative_s0:
    addi $t0, $zero, -1
    mul $s0, $s0, $t0
    li $s6,-1 # xét âm d??ng
    j Diemtrave
is_negative_s1:        
    addi $t0, $zero, -1
    mul $s1, $s1, $t0
    li $s7,-1 # xét âm d??ng
    j Diemtrave    
tieptuc:
    jal MyMult
    j   jump

MyMult:
    move $s3, $0        # lw product
    move $s4, $0        # hw product
    beq $s1, $0, done
    beq $s0, $0, done
    move $s2, $0        # extend multiplicand to 64 bits
loop:
    andi $t0, $s0, 1    # LSB(multiplier)
    beq $t0, $0, next   # skip if zero
    addu $s3, $s3, $s1  # lw(product) += lw(multiplicand)
    sltu $t0, $s3, $s1  # catch carry-out(0 or 1)
    addu $s4, $s4, $t0  # hw(product) += carry
    addu $s4, $s4, $s2  # hw(product) += hw(multiplicand)
next:
    # shift multiplicand left
    srl $t0, $s1, 31    # copy bit from lw to hw
    sll $s1, $s1, 1
    sll $s2, $s2, 1
    addu $s2, $s2, $t0

    srl $s0, $s0, 1     # shift multiplier right
    bne $s0, $0, loop
done:
    jr $ra
jump: # hàm này lay ket qua dulieu1 va dulieu tu file INT.BIN
# Xuat ket qua (syscall)
    # in du lieu 1
    li $v0, 4
    la $a0, str_dl1
    syscall
    lw $a0, dulieu1
    li $v0, 1
    syscall
    la $a0, str_newline
    li $v0, 4
    syscall
    # in du lieu 2
    li $v0, 4
    la $a0, str_dl2
    syscall
    lw $a0, dulieu2
    li $v0, 1
    syscall
    la $a0, str_newline
    li $v0, 4
    syscall
jump_1:   # tao gia gia cho 2 thanh ghi
    li $t0, 0    
    li $t3,1
loop_1:   #vòng lap lap qua 32 bit cua s3
    beq $t0, 32, jump_2   
    andi $t1, $s3, 1   
    beq $t1,1,nhan
    j tiep_1
nhan: # moi vong lap thuc hien chuyen 32 bit thành he double va cong don giá tri vao  $f6
    sllv $t4,$t3,$t0
    mtc1 $t4, $f0  
    cvt.d.w $f0,$f0  
    add.d $f6,$f6,$f0
    j tiep_1
tiep_1:  # dich sang phai 1 bit cho thanh ghi s3 va tiep tuc vong lap        
    srl $s3, $s3, 1    
    addi $t0, $t0, 1
    j loop_1   
jump_2: # lay cac giá tri ra dung
    s.d $f6,buffer_product
    l.d $f6,buffer_product
    li $t5, 0   
    l.d $f2,double_1 #thay doi_0
    l.d $f8,double_2#2
    l.d $f0,double_3#1
    l.d $f14,double_4
loop_2: ##vòng lap qua 32 bit cua s4
    beq $t5,32,print_2   
    andi $t6, $s4, 1   
    beq $t6,1,nhan_2
    j tiep_2
nhan_2:# moi vong lap thuc hien chuyen 32 bit trong thanh ghi s4 thành he double va cong don giá tri vao  $f6 f6 lay tu gia tri cu
    mul.d $f4,$f0,$f2
    add.d $f6,$f6,$f4
    j tiep_2
tiep_2:  # dich sang phai 1 bit cho thanh ghi s4 de tiep tuc vong lap          
     srl $s4, $s4, 1    
    addi $t5, $t5, 1
    mul.d $f2,$f2,$f8
    j loop_2   
print_2: #in ra ket qua trong truong hop 2 so duong 
    add $s0,$s6,$s7 
   bltz $s0, print_out  # Branch if s1 < 0 to label is_negative
   mov.d $f12,$f6
   li $v0,3
   syscall
   j Kthuc
print_out:# kiem tra xem co phai 2 so am neu khong phai jump tiep_print_ou
   beq $s0, -2, is_less_than_neg2 
   j tiep_print_out 
is_less_than_neg2:# truong hop 2 so deu am
   mov.d $f12,$f6
   li $v0,3
   syscall
   j Kthuc 
tiep_print_out:  # truong hop 1 so am Luu y: ket qua in ra dang double     
   mul.d $f12,$f6,$f14
   li $v0,3
   syscall
   j Kthuc         
# Ket thuc chuong trinh (syscall)
Kthuc:
    addiu $v0, $zero, 10
    syscall

#-----------------------------------
