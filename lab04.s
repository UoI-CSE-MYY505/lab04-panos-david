    .globl str_ge, recCheck

    .data

    maria:    .string "Maria"
    markos:   .string "Markos"
    marios:   .string "Marios"
    marianna: .string "Marianna"

    .align 4  # Ensure the string arrays are word-aligned

    # String arrays
    arraySorted:    .word maria, marianna, marios, markos
    arrayNotSorted: .word marianna, markos, maria

    .text

    # Main program (you can adjust the array and size for testing)
    main:
            la   a0, arrayNotSorted  # Load address of the array
            li   a1, 3               # Set the size of the array
            jal  recCheck            # Call recCheck

            # Exit the program
            li   a7, 10
            ecall

    # ----------------------------------------------------------------------------
    # str_ge: Compare two strings lexicographically
    # Inputs:
    #   a0 - Address of the first string (s1)
    #   a1 - Address of the second string (s2)
    # Output:
    #   a0 - Returns 1 if s1 >= s2, else 0
    # ----------------------------------------------------------------------------

    str_ge:
            addi sp, sp, -16        # Allocate stack space and maintain 16-byte alignment
            sw   ra, 12(sp)         # Save return address

            mv   t2, a0             # Copy s1 address to t2
            mv   t3, a1             # Copy s2 address to t3

    str_ge_loop:
            lb   t0, 0(t2)          # Load byte from s1
            lb   t1, 0(t3)          # Load byte from s2

            beq  t0, t1, str_ge_equal     # If characters are equal, continue
            beq  t0, zero, str_ge_s1_end  # If s1 ends
            beq  t1, zero, str_ge_s2_end  # If s2 ends
            blt  t0, t1, str_ge_return_0  # If s1 < s2, return 0

            # s1 > s2
            li   a0, 1
            j    str_ge_end

    str_ge_equal:
            beq  t0, zero, str_ge_both_end  # If both strings end
            addi t2, t2, 1                  # Move to next character in s1
            addi t3, t3, 1                  # Move to next character in s2
            j    str_ge_loop

    str_ge_s1_end:
            li   a0, 0                      # s1 ends before s2
            j    str_ge_end

    str_ge_s2_end:
            li   a0, 1                      # s2 ends before s1
            j    str_ge_end

    str_ge_both_end:
            li   a0, 1                      # Both strings are equal
            j    str_ge_end

    str_ge_return_0:
            li   a0, 0                      # s1 < s2
            j    str_ge_end

    str_ge_end:
            lw   ra, 12(sp)          # Restore return address
            addi sp, sp, 16          # Deallocate stack space
            jr   ra                  # Return

    # ----------------------------------------------------------------------------
    # recCheck: Recursively check if an array of strings is sorted
    # Inputs:
    #   a0 - Address of the array of strings
    #   a1 - Size of the array
    # Output:
    #   a0 - Returns 1 if array is sorted, else 0
    # ----------------------------------------------------------------------------

    recCheck:
            addi sp, sp, -16         # Allocate stack space
            sw   ra, 12(sp)          # Save return address
            sw   s0, 8(sp)           # Save s0
            sw   s1, 4(sp)           # Save s1

            mv   s0, a0              # s0 = array address
            mv   s1, a1              # s1 = size

            # Base case: if size == 0 or size == 1
            li   t0, 1
            beq  s1, zero, recCheck_base_case
            beq  s1, t0, recCheck_base_case

            # Load table[0] and table[1]
            lw   t2, 0(s0)           # t2 = table[0]
            lw   t3, 4(s0)           # t3 = table[1]

            # Call str_ge with table[1] and table[0]
            mv   a0, t3              # a0 = address of table[1]
            mv   a1, t2              # a1 = address of table[0]
            jal  str_ge

            beq  a0, zero, recCheck_not_sorted  # If str_ge returns 0, array is not sorted

            # Recursive call: recCheck(&(table[1]), size - 1)
            addi a0, s0, 4           # a0 = address of table[1]
            addi a1, s1, -1          # a1 = size - 1
            jal  recCheck

            j    recCheck_end        # Jump to end

    recCheck_base_case:
            li   a0, 1               # Array is sorted
            j    recCheck_end

    recCheck_not_sorted:
            li   a0, 0               # Array is not sorted

    recCheck_end:
            lw   s1, 4(sp)           # Restore s1
            lw   s0, 8(sp)           # Restore s0
            lw   ra, 12(sp)          # Restore return address
            addi sp, sp, 16          # Deallocate stack space
            jr   ra                  # Return
