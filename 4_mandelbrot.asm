##################################
#CESP Exercise 4: Mandelbrot     #
##################################
.globl main

.data
.eqv DISPLAY_BASE_ADDRESS 0x10010000
.eqv Q_INTEGER 24
.eqv Q_FRACTION 8
.eqv MAX_ITERATIONS 50  #    int max_iterations = 50;
.eqv LIMIT2 0x400 # limit*limit = 2*2

.eqv IMAGE_WIDTH 512 #int w = h = 128
.eqv IMAGE_HEIGHT 512
.eqv WIDTH_LOG2 7 # You can use these constants for the division by image_width in line 19 (use a shift right there)
.eqv HEIGHT_LOG2 7

.eqv X_START -0x180 #
.eqv Y_START -0x100
.eqv X_STRETCH 0x200
.eqv Y_STRETCH 0x200
    
.text

main:
    # a1 to a4 are initialized with X_START to Y_STRETCH 
    li a1, X_START
    li a2, Y_START
    li a3, X_STRETCH
    li a4, Y_STRETCH
    
    jal ra, mandelbrot

    li a0, 0
    li a7, 93
    ecall

    
mandelbrot:
# Input:
#   a1: x_start
#   a2: y_start
#   a3: x_stretch
#   a4: y_stretch
# Output: None

	#store on stack
	addi sp, sp, -40
	sw ra, 40(sp)
	sw s0, 36(sp)
	sw s1, 32(sp)
	sw s2, 28(sp)
	sw s3, 24(sp)
	sw s4, 20(sp)
	sw s5, 16(sp)
	sw s6, 12(sp)
	sw s7, 8(sp)
	sw s8, 4(sp)
	
	li t0, 0x200 #two
    
    
	li t1, IMAGE_HEIGHT
	li t2, IMAGE_WIDTH
	li t4, LIMIT2
	li t5, MAX_ITERATIONS
	li s5, 0 # y = 0
	y_start:
		beq s5, t1, y_end # y < IMAGE HEIGHT
    	
    		li s4, 0 # x = 0
    		x_start:
    			beq s4, t2, x_end # x < IMAGE_WIDTH
    			
    			li s0, 0 #Zr = Zi = Tr = Ti = 0.0
    			li s1, 0
    			li s2, 0
    			li s3, 0
    		
    			mul s7, a3, s4 # Cr = X_STRETCH * x
    			#slli s7,s7,2 # Cr *= 4
    			div s7, s7, t2 # Cr /= IMAGE_WIDTH
    			#srai s7, s7, 8 # Cr >> 8 
    			add s7, s7, a1 # Cr+= x_start
    			
    			mul s8, a4, s5 # Ci = Y_STRETCH * y
    			#slli s8,s8,2 # Ci *= 4
    			div s8, s8, t1 # Ci /= IMAGE_HEGIHT
    			#srai s8, s8, 8 # Cr >> 8 
    			add s8, s8, a2 # Ci += y_start
    			
    			li s6, 0 # i = 0
    			i_start:
    				add t3, s2, s3 #t3 = Tr + Ti
    				beq  s6, t5, i_end  # i < MAX_ITERTAIONS
    				bgt t3, t4, i_end #Tr + Ti <= limit*limit
    				
    				mul s1, s1, s0 # Zi *=  Zr
    				srai s1, s1, 8 # shift right 
    				slli s1,s1,1 #  Zi *= 2
    				add s1, s1, s8 #Zi += Ci
    				
    				sub s0, s2, s3 #Zr = Tr - Ti 
    				add s0, s0, s7 #Zr += Cr
    				
    				mul s2, s0, s0 # Tr = Zr * Zr
    				srai s2, s2, 8 
    				
    				mul s3, s1, s1 # Ti = Zi * Zi
    				srai s3, s3, 8
    				
    				addi s6, s6, 1 # ++i
    				beq zero, zero, i_start
    			i_end:
    		
    			mv a5, s6 # iterations = i
    			mv a6, s4 # x= x
    			mv a7, s5 # y = y
    			jal ra, plot
    	
    			addi s4, s4, 1 #++x
    			beq zero, zero, x_start
		x_end:
		addi s5, s5, 1 #++y
    		beq zero, zero, y_start
	y_end:
	
	#restore from stack        
	lw ra, 40(sp)
	lw s0, 36(sp)
	lw s1, 32(sp)
	lw s2, 28(sp)
	lw s3, 24(sp)
	lw s4, 20(sp)
	lw s5, 16(sp)
	lw s6, 12(sp)
	lw s7, 8(sp)
	lw s8, 4(sp)
	addi sp, sp, 40

   	jalr zero,ra,0


plot:
# Creates colored pixel at position (x,y)  
# Inputs
#    a5: iterations
#    a6: x
#    a7: y
# Outputs: None

	addi sp, sp, -16
	sw t0, 16(sp)
	sw t1, 12(sp)
	sw t2, 8(sp)
	sw t3, 4(sp)
	
	li t0, DISPLAY_BASE_ADDRESS
	li t1, IMAGE_WIDTH
	mul t2, a7, t1 #address = IMAGE_WIDTH* Y
	slli t2, t2, 2 #address *= 4
	slli a6, a6, 2 # x*4
	add t2, t2, a6 #addres += x (x*4)
	add t2, t2, t0 #address += base_adress
	li t3, 0xFFF
	slli a5, a5, 2 # iterations * 4
	sub t3, t3, a5 # color - iterations*8
	
	sw t3, 0(t2)
	
	lw t0, 16(sp)
	lw t1, 12(sp)
	lw t2, 8(sp)
	lw t3, 4(sp)
	addi sp, sp, 16
	
	jalr zero, ra, 0
	
	
	
	
	
	
	
	
