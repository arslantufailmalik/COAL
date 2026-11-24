# ============================================================
# Electricity Bill Calculator in MIPS Assembly
# Project: Computer Organization & Assembly Language
# Students: Arslan Tufail (39) & Muhammad Saad uz Zaman Khan (65)
# Runs on QtSpim
# ============================================================

.data
    # ========== Menus & Messages ==========
    welcome:        .asciiz "\n===== ELECTRICITY BILL CALCULATOR =====\n"
    menu:           .asciiz "Select Consumer Type:\n1. Domestic\n2. Commercial\n3. Exit\nEnter choice: "
    
    prompt_units:   .asciiz "Enter Units Consumed: "
    
    bill_header:    .asciiz "\n---------- BILL SUMMARY ----------\n"
    label_type:     .asciiz "Consumer Type      : "
    type_dom:       .asciiz "Domestic\n"
    type_com:       .asciiz "Commercial\n"
    
    label_units:    .asciiz "Units Consumed     : "
    
    label_slab1:    .asciiz "Slab 0-100         : Rs. "
    label_slab2:    .asciiz "Slab 101-200       : Rs. "
    label_slab3:    .asciiz "Slab 201-300       : Rs. "
    label_slab4:    .asciiz "Slab Above 300     : Rs. "
    
    label_energy:   .asciiz "Energy Charges     : Rs. "
    label_gst:      .asciiz "GST (17%)          : Rs. "
    label_fixed:    .asciiz "Fixed Charges      : Rs. "
    separator:      .asciiz "----------------------------------\n"
    label_total:    .asciiz "TOTAL PAYABLE      : Rs. "
    
    newline:        .asciiz "\n"
    continue_msg:   .asciiz "\n1. Calculate Another Bill   2. Exit\nEnter choice: "
    invalid_msg:    .asciiz "Invalid choice! Please try again.\n"
    invalid_units:  .asciiz "Units cannot be negative! Try again.\n"
    
    # ========== Rates (in paisa to avoid floating point) ==========
    # We will work with integers. Final display will show whole rupees.
    # Domestic rates
    dom_rate1:      .word 8          # 0-100
    dom_rate2:      .word 12         # 101-200
    dom_rate3:      .word 16         # 201-300
    dom_rate4:      .word 20         # above 300
    
    # Commercial rates
    com_rate1:      .word 15
    com_rate2:      .word 18
    com_rate3:      .word 22
    com_rate4:      .word 28
    
    fixed_charges:  .word 150
    gst_percent:    .word 17

.text
.globl main
main:
    # Print welcome
    li $v0, 4
    la $a0, welcome
    syscall

menu_loop:
    # Print menu
    li $v0, 4
    la $a0, menu
    syscall
    
    # Read choice
    li $v0, 5
    syscall
    move $t0, $v0               # $t0 = choice
    
    beq $t0, 1, domestic
    beq $t0, 2, commercial
    beq $t0, 3, exit_program
    
    # Invalid choice
    li $v0, 4
    la $a0, invalid_msg
    syscall
    j menu_loop

# ============================================================
# DOMESTIC CONSUMER
# ============================================================
domestic:
    li $s7, 1                   # flag: 1 = Domestic
    j get_units

# ============================================================
# COMMERCIAL CONSUMER
# ============================================================
commercial:
    li $s7, 2                   # flag: 2 = Commercial
    j get_units

# ============================================================
# Get Units from user
# ============================================================
get_units:
    li $v0, 4
    la $a0, prompt_units
    syscall
    
    li $v0, 5                   # read integer
    syscall
    move $s0, $v0               # $s0 = units consumed
    
    # Check for negative units
    bltz $s0, units_error
    j calculate_bill

units_error:
    li $v0, 4
    la $a0, invalid_units
    syscall
    j get_units

# ============================================================
# Calculate Bill according to slabs
# ============================================================
calculate_bill:
    # Initialize slab amounts to 0
    li $s1, 0                   # slab1 amount
    li $s2, 0                   # slab2 amount
    li $s3, 0                   # slab3 amount
    li $s4, 0                   # slab4 amount
    li $s5, 0                   # total energy charges
    
    # Load rates based on consumer type
    beq $s7, 1, load_domestic_rates
    # else commercial
    lw $t1, com_rate1
    lw $t2, com_rate2
    lw $t3, com_rate3
    lw $t4, com_rate4
    j start_slabs

load_domestic_rates:
    lw $t1, dom_rate1
    lw $t2, dom_rate2
    lw $t3, dom_rate3
    lw $t4, dom_rate4

start_slabs:
    move $t0, $s0               # remaining units = total units
    
    # ----- Slab 1: 0-100 -----
    ble $t0, 100, only_slab1
    
    # Full 100 units in slab 1
    mul $s1, $t1, 100
    sub $t0, $t0, 100
    j slab2

only_slab1:
    mul $s1, $t1, $t0           # rate * units
    j energy_done

slab2:
    # ----- Slab 2: 101-200 -----
    ble $t0, 100, only_slab2
    
    mul $s2, $t2, 100
    sub $t0, $t0, 100
    j slab3

only_slab2:
    mul $s2, $t2, $t0
    j energy_done

slab3:
    # ----- Slab 3: 201-300 -----
    ble $t0, 100, only_slab3
    
    mul $s3, $t3, 100
    sub $t0, $t0, 100
    j slab4

only_slab3:
    mul $s3, $t3, $t0
    j energy_done

slab4:
    # ----- Slab 4: Above 300 -----
    mul $s4, $t4, $t0

energy_done:
    # Total Energy Charges
    add $s5, $s1, $s2
    add $s5, $s5, $s3
    add $s5, $s5, $s4
    
    # Calculate GST = Energy * 17 / 100
    lw $t5, gst_percent
    mul $t6, $s5, $t5
    li $t7, 100
    div $t6, $t7
    mflo $s6                    # $s6 = GST amount
    
    # Fixed Charges
    lw $t8, fixed_charges
    
    # Total Payable = Energy + GST + Fixed
    add $t9, $s5, $s6
    add $t9, $t9, $t8           # $t9 = TOTAL PAYABLE
    
    # Now print the bill
    jal print_bill
    j ask_continue

# ============================================================
# Print the complete bill
# ============================================================
print_bill:
    # Header
    li $v0, 4
    la $a0, bill_header
    syscall
    
    # Consumer Type
    li $v0, 4
    la $a0, label_type
    syscall
    beq $s7, 1, print_dom
    li $v0, 4
    la $a0, type_com
    syscall
    j print_units
print_dom:
    li $v0, 4
    la $a0, type_dom
    syscall

print_units:
    # Units
    li $v0, 4
    la $a0, label_units
    syscall
    li $v0, 1
    move $a0, $s0
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    
    # Slab 1
    li $v0, 4
    la $a0, label_slab1
    syscall
    li $v0, 1
    move $a0, $s1
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    
    # Slab 2
    li $v0, 4
    la $a0, label_slab2
    syscall
    li $v0, 1
    move $a0, $s2
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    
    # Slab 3
    li $v0, 4
    la $a0, label_slab3
    syscall
    li $v0, 1
    move $a0, $s3
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    
    # Slab 4
    li $v0, 4
    la $a0, label_slab4
    syscall
    li $v0, 1
    move $a0, $s4
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    
    # Energy Charges
    li $v0, 4
    la $a0, label_energy
    syscall
    li $v0, 1
    move $a0, $s5
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    
    # GST
    li $v0, 4
    la $a0, label_gst
    syscall
    li $v0, 1
    move $a0, $s6
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    
    # Fixed Charges
    li $v0, 4
    la $a0, label_fixed
    syscall
    li $v0, 1
    move $a0, $t8
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    
    # Separator
    li $v0, 4
    la $a0, separator
    syscall
    
    # TOTAL
    li $v0, 4
    la $a0, label_total
    syscall
    li $v0, 1
    move $a0, $t9
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    
    jr $ra

# ============================================================
# Ask to continue
# ============================================================
ask_continue:
    li $v0, 4
    la $a0, continue_msg
    syscall
    
    li $v0, 5
    syscall
    
    beq $v0, 1, menu_loop
    # else exit

exit_program:
    li $v0, 10
    syscall
