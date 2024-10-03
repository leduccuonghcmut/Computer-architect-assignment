# Chuong trinh: Tao file du lieu
#-----------------------------------

# Data segment
.data

# Cac dinh nghia bien
dulieu1: .word 5
dulieu2: .word 0
tenfile: .asciiz "INT2.BIN"
fdescr: .word 0

# Cac cau nhac nhap/xuat du lieu
str_tc: .asciiz "Thanh cong."
str_loi: .asciiz "Mo file bi loi."

#-----------------------------------

# Code segment
.text

#-----------------------------------

# Chuong trinh chinh
#-----------------------------------
main:
    # Nhap (syscall)
    # Xu ly
    la $a0, tenfile
    addi $a1, $zero, 1 # open with a1=1 (write-only)
    addi $v0, $zero, 13
    syscall
    bgez $v0, tiep
    li $v0, 4
    la $a0, str_loi
    syscall

    # ghi file
tiep:
    sw $v0, fdescr #luu file descriptor

    # 4 byte dau (du lieu kieu word)
    lw $a0, fdescr # file descriptor
    la $a1, dulieu1
    addi $a2, $zero, 4 #ghi 4 byte so nguyen
    addi $v0, $zero, 15
    syscall

    # 4 byte sau (du lieu kieu word)
    la $a1, dulieu2
    addi $a2, $zero, 4 #ghi 4 byte so nguyen
    addi $v0, $zero, 15
    syscall

    # dong file
    lw $a0, fdescr
    addi $v0, $zero, 16
    syscall

# Xuat ket qua (syscall)
    li $v0, 4
    la $a0, str_tc
    syscall

# Ket thuc chuong trinh (syscall)
    addi $v0, $zero, 10
    syscall
#-----------------------------------
