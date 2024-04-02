#####################################################################
#
# CSCB58 Winter 2024 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Andy Ma, 1009407410, maandy3, andyz.ma@mail.utoronto.ca
#
# Bitmap Display Configuration:
# - Unit width in pixels: 4 (update this as needed)
# - Unit height in pixels: 4 (update this as needed)
# - Display width in pixels: 256 (update this as needed)
# - Display height in pixels: 256 (update this as needed)
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestoneshave been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3/4 (choose the one the applies)
# - Answer; I have reached four.
# Which approved features have been implemented for milestone 3?
# (See the assignment handout for the list of additional features)
# I have implemented health/score, fail condition and win condition, as desired.
#
# Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it!
#
# Are you OK with us sharing the video with people outside course staff?
# - yes / no / yes, and please share this project github link as well!
# - Answer: Yeah sure. Warning, it sucks. You should use it as a very basic example, if at all.
# - Github Link:
# Any additional information that the TA needs to know:
# - I made it a feature that you can only jump when not moving. The laser is supposed to speed up during that time. It is a feature, not a bug.
#
#####################################################################
 

.eqv BASE_ADDRESS 0x10008000
.text

# draw the initial location
li $t0, BASE_ADDRESS 
li $t1, 0xff0000 # red
li $t2, 0x00ff00 # green
li $t6, 0x964B00 # brown
li $t7, 0xefb6d4 # pink
li $t8, 0xFFFFFF # white 
li $t9, 0x000000 # black

# load register for key press event
li $s0, 0xffff0000

# preset initial player coordinate
li $s3, 13944 # bottom left of pink guy

# load register for holding jump counter
li $t3, 0

# load register for enemy laser movement
li $t5, 0

# load register for player iframes counter
li $s4, 0

# load register for falling counter
li $s5, 0

# load register for enemy laser location (top right of laser for lasers coming from left, and vice versa)
li $s6, 0

# load register for number of lives 
li $s7, 3

# prepush the value 0 into the stack, for point incrementation
li $t4, 0
addi $sp, $sp, -4
sw $t4, 0($sp)

# draw danger symbol
.macro drawExclamationMark 
	sw $t1, 0($t0)
	sw $t1, 256($t0)
	sw $t1, 512($t0)
	sw $t1, 1024($t0)
	li $v0, 32
   	li $a0, 1000
    	syscall 
    	sw $t9, 0($t0)
	sw $t9, 256($t0)
	sw $t9, 512($t0)
	sw $t9, 1024($t0)
.end_macro

# draw heart
.macro drawHeart
	sw $t1, ($t0)
	sw $t1, 4($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 256($t0)
	sw $t1, 260($t0)
	sw $t1, 264($t0)
	sw $t1, 268($t0)
	sw $t1, 272($t0)
	sw $t1, 516($t0)
	sw $t1, 520($t0)
	sw $t1, 524($t0)
	sw $t1, 776($t0)
.end_macro

# remove heart
.macro removeHeart
	sw $t9, ($t0)
	sw $t9, 4($t0)
	sw $t9, 12($t0)
	sw $t9, 16($t0)
	sw $t9, 256($t0)
	sw $t9, 260($t0)
	sw $t9, 264($t0)
	sw $t9, 268($t0)
	sw $t9, 272($t0)
	sw $t9, 516($t0)
	sw $t9, 520($t0)
	sw $t9, 524($t0)
	sw $t9, 776($t0)
.end_macro

# clear top right for drawing points
.macro clearTopRight
	li $t0, BASE_ADDRESS
	addi $t0, $t0, 484
	li $t4, 0
blackOutNumber:
	beq $t4, 7, doneBlackingOutNumber
	sw $t9, ($t0)
	sw $t9, 4($t0)
	sw $t9, 8($t0)
	sw $t9, 12($t0)
	sw $t9, 16($t0)
	sw $t9, 20($t0)
	addi $t0, $t0, 256
	addi $t4, $t4, 1
	j blackOutNumber
doneBlackingOutNumber:
.end_macro

# draw 1 in top right
.macro drawNumberOne
	li $t0, BASE_ADDRESS
	addi $t0, $t0, 496
	li $t4, 0
	# draw rest of one before the stem
	sw $t8, 252($t0)
	sw $t8, 1276($t0)
	sw $t8, 1284($t0)
drawOneStem:
	beq $t4, 6, doneDrawingOne
	sw $t8, ($t0)
	addi $t0, $t0, 256
	addi $t4, $t4, 1
	j drawOneStem
doneDrawingOne:
.end_macro

# draw 2 in top right
.macro drawNumberTwo
	li $t0, BASE_ADDRESS
	addi $t0, $t0, 496
	li $t4, 0
	# cant really loop this one
	sw $t8, -4($t0)
	sw $t8, ($t0)
	sw $t8, 4($t0)
	sw $t8, 248($t0)
	sw $t8, 264($t0)
	sw $t8, 520($t0)
	sw $t8, 772($t0)
	sw $t8, 1024($t0)
	sw $t8, 1276($t0)
	sw $t8, 1528($t0)
	sw $t8, 1532($t0)
	sw $t8, 1536($t0)
	sw $t8, 1540($t0)
	sw $t8, 1544($t0)
.end_macro

# draw 3 in top right
.macro drawNumberThree
	li $t0, BASE_ADDRESS
	addi $t0, $t0, 496
	li $t4, 0
	# cant loop this one either
	sw $t8, -4($t0)
	sw $t8, ($t0)
	sw $t8, 4($t0)
	sw $t8, 248($t0)
	sw $t8, 264($t0)
	sw $t8, 520($t0)
	sw $t8, 768($t0)
	sw $t8, 772($t0)
	sw $t8, 1032($t0)
	sw $t8, 1272($t0)
	sw $t8, 1288($t0)
	sw $t8, 1532($t0)
	sw $t8, 1536($t0)
	sw $t8, 1540($t0)
.end_macro

.macro deleteScreen
	li $t4, 0
	li $t0, BASE_ADDRESS
clearScreen:
	beq $t4, 4096, doneClearingScreen
	sw $t9, ($t0)
	addi $t0, $t0, 4
	addi $t4, $t4, 1
	j clearScreen
doneClearingScreen:
.end_macro
# game over screen
.macro gameOverScreen
deleteScreen
drawGameOver:
	li $t8, 0xFFFFFF # white 
	li $t0, BASE_ADDRESS
	addi $t0, $t0, 5980
	# draw "game" text
	sw $t8, ($t0) # row 1
	sw $t8, 4($t0)
	sw $t8, 8($t0)
	sw $t8, 20($t0)
	sw $t8, 24($t0)
	sw $t8, 36($t0)
	sw $t8, 52($t0)
	sw $t8, 60($t0)
	sw $t8, 64($t0)
	sw $t8, 68($t0)
	sw $t8, 72($t0)
	sw $t8, 252($t0) # row 2
	sw $t8, 272($t0)
	sw $t8, 284($t0)
	sw $t8, 292($t0)
	sw $t8, 296($t0)
	sw $t8, 304($t0)
	sw $t8, 308($t0)
	sw $t8, 316($t0)
	sw $t8, 508($t0) # row 3
	sw $t8, 516($t0)
	sw $t8, 520($t0)
	sw $t8, 528($t0)
	sw $t8, 532($t0)
	sw $t8, 536($t0)
	sw $t8, 540($t0)
	sw $t8, 548($t0)
	sw $t8, 556($t0)
	sw $t8, 564($t0)
	sw $t8, 572($t0)
	sw $t8, 576($t0)
	sw $t8, 580($t0)
	sw $t8, 764($t0) # row 4
	sw $t8, 776($t0)
	sw $t8, 784($t0)
	sw $t8, 796($t0)
	sw $t8, 804($t0)
	sw $t8, 820($t0)
	sw $t8, 828($t0)
	sw $t8, 1024($t0) # row 5
	sw $t8, 1028($t0)
	sw $t8, 1032($t0)
	sw $t8, 1040($t0)
	sw $t8, 1052($t0)
	sw $t8, 1060($t0)
	sw $t8, 1076($t0)
	sw $t8, 1084($t0)
	sw $t8, 1088($t0)
	sw $t8, 1092($t0)
	sw $t8, 1096($t0)
# draw "over" text
	addi $t0, $t0, 1536
	sw $t8, ($t0) # row 1
	sw $t8, 4($t0)
	sw $t8, 16($t0)
	sw $t8, 32($t0)
	sw $t8, 40($t0)
	sw $t8, 44($t0)
	sw $t8, 48($t0)
	sw $t8, 52($t0)
	sw $t8, 60($t0)
	sw $t8, 64($t0)
	sw $t8, 68($t0)
	sw $t8, 252($t0) # row 2
	sw $t8, 264($t0)
	sw $t8, 272($t0)
	sw $t8, 288($t0)
	sw $t8, 296($t0)
	sw $t8, 316($t0)
	sw $t8, 328($t0)
	sw $t8, 508($t0) # row 3
	sw $t8, 520($t0)
	sw $t8, 528($t0)
	sw $t8, 544($t0)
	sw $t8, 552($t0)
	sw $t8, 556($t0)
	sw $t8, 560($t0)
	sw $t8, 572($t0)
	sw $t8, 576($t0)
	sw $t8, 580($t0)
	sw $t8, 584($t0)
	sw $t8, 764($t0) # row 4
	sw $t8, 776($t0)
	sw $t8, 788($t0)
	sw $t8, 796($t0)
	sw $t8, 808($t0)
	sw $t8, 828($t0)
	sw $t8, 836($t0)
	sw $t8, 1024($t0) # row 5
	sw $t8, 1028($t0)
	sw $t8, 1048($t0)
	sw $t8, 1064($t0)
	sw $t8, 1068($t0)
	sw $t8, 1072($t0)
	sw $t8, 1076($t0)
	sw $t8, 1084($t0)
	sw $t8, 1096($t0)
.end_macro

# draw victory screen
.macro victoryScreen
deleteScreen
drawVictory:
	li $t0, BASE_ADDRESS
	addi $t0, $t0, 5960
	li $t8, 0xFFFFFF # white 
	# sorry about this code.
	sw $t8, -8($t0) # row 1
	sw $t8, 8($t0)
	sw $t8, 20($t0)
	sw $t8, 24($t0)
	sw $t8, 36($t0)
	sw $t8, 48($t0)
	sw $t8, 64($t0)
	sw $t8, 80($t0)
	sw $t8, 88($t0)
	sw $t8, 92($t0)
	sw $t8, 96($t0)
	sw $t8, 104($t0)
	sw $t8, 120($t0)
	sw $t8, 248($t0) # row 2
	sw $t8, 264($t0)
	sw $t8, 272($t0)
	sw $t8, 284($t0)
	sw $t8, 292($t0)
	sw $t8, 304($t0)
	sw $t8, 320($t0)
	sw $t8, 336($t0)
	sw $t8, 348($t0)
	sw $t8, 360($t0)
	sw $t8, 364($t0)
	sw $t8, 376($t0)
	sw $t8, 508($t0) # row 3
	sw $t8, 516($t0)
	sw $t8, 528($t0)
	sw $t8, 540($t0)
	sw $t8, 548($t0)
	sw $t8, 560($t0)
	sw $t8, 576($t0)
	sw $t8, 584($t0)
	sw $t8, 592($t0)
	sw $t8, 604($t0)
	sw $t8, 616($t0)
	sw $t8, 624($t0)
	sw $t8, 632($t0)
	sw $t8, 768($t0) # row 4
	sw $t8, 784($t0)
	sw $t8, 796($t0)
	sw $t8, 804($t0)
	sw $t8, 816($t0)
	sw $t8, 832($t0)
	sw $t8, 836($t0)
	sw $t8, 844($t0)
	sw $t8, 848($t0)
	sw $t8, 860($t0)
	sw $t8, 872($t0)
	sw $t8, 884($t0)
	sw $t8, 888($t0)
	sw $t8, 1024($t0) # row 5
	sw $t8, 1044($t0)
	sw $t8, 1048($t0)
	sw $t8, 1064($t0)
	sw $t8, 1068($t0)
	sw $t8, 1088($t0)
	sw $t8, 1104($t0)
	sw $t8, 1112($t0)
	sw $t8, 1116($t0)
	sw $t8, 1120($t0)
	sw $t8, 1128($t0)
	sw $t8, 1144($t0)
# draw an extra exclamation mark at the end
	addi $t0, $t0, 140
.end_macro

# check collision
.macro checkLeftLaserCollision
 	beq $s7, 0, noCollision # temporary skip for when lives = 0
	blt $s4, 10, notColliding
	li $s4, 0
	j notColliding
incrementingIframes:
	addi $s4, $s4, 1
	j noCollision
notColliding:
 	bgt $s4, 0, incrementingIframes
	li $t2, 0
	subi $t2, $s3, 1792 # top left of player
	ble $s6, $t2, noCollision # right of laser smaller than left of player, no collision

	li $t2, 0
	addi $t2, $s3, 12 # bottom right of player
	li $t6, 0
	subi $t6, $s6, 24 # top left of laser
	ble $t2, $t6, noCollision # bottom right of player is smaller than top left of laser, no collision

	li $t2, 0
	subi $t2, $s3, 1804 # top right of player
	ble $t2, $t6, noCollision # right of player smaller than left of laser, no collision

	li $t2, 0
	subi $t2, $s3, 1792 # top left of player
	li $t6, 0
	addi $t6, $s6, 1280 # bottom right of laser
	ble $t6, $t2, noCollision # top of player greater than bottom of laser
	
	bgt $s4, 0, noCollision

collisionReg:
	# otherwise we got a collision, so delete a life accordingly.
	subi $s7, $s7, 1 # subtract 1 life from life register
	addi $s4, $s4, 1 # start counting iframes
noCollision:
	
.end_macro

# move character left
.macro movePlayerLeft (%objectLocation)
	li $t0, BASE_ADDRESS
	add $t0, $t0, %objectLocation
currentlyMovingLeft:
	beq $t4, 8, doneMovingLeft
	subi $t0, $t0, 4
	sw $t7, ($t0)
	addi $t0, $t0, 12
	sw $t9, ($t0)
	subi $t0, $t0, 264
	addi $t4, $t4, 1
	j currentlyMovingLeft
doneMovingLeft:
	subi $s3, $s3, 4
.end_macro

# move character right
.macro movePlayerRight (%objectLocation)
	li $t0, BASE_ADDRESS
	add $t0, $t0, %objectLocation
currentlyMovingRight:
	beq $t4, 8, doneMovingRight
	addi $t0, $t0, 12
	sw $t7, ($t0)
	subi $t0, $t0, 12
	sw $t9, ($t0)
	subi $t0, $t0, 256
	addi $t4, $t4, 1
	j currentlyMovingRight
doneMovingRight:
	addi $s3, $s3, 4
.end_macro

# jump character. Pink guy must jump 14 rows to clear a platform.
.macro jumpPlayer (%objectLocation)
	li $t0, BASE_ADDRESS
	add $t0, $t0, %objectLocation
currentlyJumping:
	#beq $t4, 15, doneJumping
	subi $t0, $t0, 2048
	sw $t7, ($t0)
	sw $t7, 4($t0)
	sw $t7, 8($t0)
	addi $t0, $t0, 2048
	sw $t9, ($t0)
	sw $t9, 4($t0)
	sw $t9, 8($t0)
	subi $t0, $t0, 256
	addi $t4, $t4, 1
	li $v0, 32
   	li $a0, 10
    	syscall
	#j currentlyJumping
doneJumping:
	#subi $s3, $s3, 3840
	subi $s3, $s3, 256
	addi $t3, $t3, 1
	# only fall if we are jumping all the way up
	bgt $s3, 3328, dontFall
	fallingPlayer $s3
dontFall:
.end_macro

# for player to fall back down
.macro fallingPlayer (%objectLocation)
	li $t0, BASE_ADDRESS
	add $t0, $t0, %objectLocation
	ble $s3, 6656, currentlyFallingOffTop
	ble $s3, 6912, doneFalling
	ble $s3, 10496, currentlyFallingOffPlat2
currentlyFallingOffPlat1:
	bge $s3, 13824, doneFalling
	addi $t0, $t0, 256
	sw $t7, ($t0)
	sw $t7, 4($t0)
	sw $t7, 8($t0)
	subi $t0, $t0, 2048
	sw $t9, ($t0)
	sw $t9, 4($t0)
	sw $t9, 8($t0)
	addi $t0, $t0, 2048
	addi $s3, $s3, 256
	li $v0, 32
   	li $a0, 10
    	syscall
    	j doneFalling
currentlyFallingOffPlat2:
	bge $s3, 10240, doneFalling
	addi $t0, $t0, 256
	sw $t7, ($t0)
	sw $t7, 4($t0)
	sw $t7, 8($t0)
	subi $t0, $t0, 2048
	sw $t9, ($t0)
	sw $t9, 4($t0)
	sw $t9, 8($t0)
	addi $t0, $t0, 2048
	addi $s3, $s3, 256
	li $v0, 32
   	li $a0, 10
    	syscall
    	j doneFalling
currentlyFallingOffTop:
	bge $s3, 6656, doneFalling
	addi $t0, $t0, 256
	sw $t7, ($t0)
	sw $t7, 4($t0)
	sw $t7, 8($t0)
	subi $t0, $t0, 2048
	sw $t9, ($t0)
	sw $t9, 4($t0)
	sw $t9, 8($t0)
	addi $t0, $t0, 2048
	addi $s3, $s3, 256
	li $v0, 32
   	li $a0, 10
    	syscall
    	j doneFalling
doneFalling:
	addi $s5, $s5, 1
.end_macro

.macro downThroughPlatform (%objectLocation)
	bge $s3, 13824, noFallingThroughGround
	li $t0, BASE_ADDRESS
	add $t0, $t0, %objectLocation
	addi $t0, $t0, 256
	sw $t7, ($t0)
	sw $t7, 4($t0)
	sw $t7, 8($t0)
	subi $t0, $t0, 2048
	sw $t9, ($t0)
	sw $t9, 4($t0)
	sw $t9, 8($t0)
	addi $t0, $t0, 2048
	addi $s3, $s3, 256
	fallingPlayer %objectLocation
noFallingThroughGround:
.end_macro

.macro laserAttack
	checkLeftLaserCollision
	li $t0, BASE_ADDRESS
	# get random number for which side the laser comes out of
	#li $v0, 42
	#li $a0, 0
	#li $a1, 3
	#syscall
	li $a0, 0
	beq $a0, 0, bottomLeftLaser
	beq $a0, 1, middleLeftLaser
	beq $a0, 2, bottomRightLaser
	beq $a0, 3, middleRightLaswer
bottomLeftLaser:
	bgt $s6, 0, pass
	addi $s6, $s6, 12032
	pass:
	addi $t0, $t0, 12032
	add $t0, $t0, $t5
	bge $t5, 256, doneLaseringRight
	bge $t5, 24, laseringRight
	addi $t0, $t0, 4
	drawExclamationMark
	subi $t0, $t0, 4
	makingLaser:
	beq $t5, 24, laseringRight
	sw $t1, ($t0)
	sw $t1, 256($t0)
	sw $t1, 512($t0)
	sw $t1, 768($t0)
	sw $t1, 1024($t0)
	addi $t0, $t0, 4
	addi $t5, $t5, 4
	addi $s6, $s6, 4
	j makingLaser
	laseringRight:
	sw $t1, ($t0)
	sw $t1, 256($t0)
	sw $t1, 512($t0)
	sw $t1, 768($t0)
	sw $t1, 1024($t0)
	sw $t9, -24($t0)
	sw $t9, 232($t0)
	sw $t9, 488($t0)
	sw $t9, 744($t0)
	sw $t9, 1000($t0)
	addi $t0, $t0, 4
	addi $t5, $t5, 4
	addi $s6, $s6, 4
	j doneLasering
	doneLaseringRight:
	beq $t5, 280, doneLasering 
	sw $t9, -24($t0)
	sw $t9, 232($t0)
	sw $t9, 488($t0)
	sw $t9, 744($t0)
	sw $t9, 1000($t0)
	addi $t0, $t0, 4
	addi $t5, $t5, 4
	addi $s6, $s6, 4
	j doneLaseringRight
middleLeftLaser:
bottomRightLaser:
middleRightLaswer:
doneLasering:
.end_macro
.macro drawEverything
# counter for drawing stuff
li $t4, 0
li $t0, BASE_ADDRESS
addi $t0, $t0, 14080
drawGrass:
	li $t2, 0x00ff00 # green
	beq $t4, 64, reset1 # 1 line of grass
	sw $t2, ($t0)
	addi $t0, $t0, 4
	addi $t4, $t4, 1
	j drawGrass
reset1:
	li $t4, 0
drawDirt:
	li $t6, 0x964B00 # brown
	beq $t4, 2304, reset2 # 32 lines of dirt, which is until 64 x 32 = 2304
	sw $t6, ($t0)
	addi $t0, $t0, 4
	addi $t4, $t4, 1
	j drawDirt
reset2:
	li $t4, 0
	li $t0, BASE_ADDRESS
	addi $t0, $t0, 10496
drawPlatform1:
	li $t8, 0xFFFFFF # white 
	beq $t4, 64, reset6
	sw $t8, ($t0)
	addi $t0, $t0, 4
	addi $t4, $t4, 1
	j drawPlatform1
reset6:
	li $t4, 0
	li $t0, BASE_ADDRESS
	addi $t0, $t0, 6912
drawPlatform2:
	li $t8, 0xFFFFFF # white 
	beq $t4, 64, reset4
	sw $t8, ($t0)
	addi $t0, $t0, 4
	addi $t4, $t4, 1
	j drawPlatform2
reset4:
	li $t0, BASE_ADDRESS
	li $t4, 0
	addi $t0, $t0, 260
drawBlackHearts:
	beq $t4, 3, doneDrawingBlackHearts
	removeHeart
	addi $t0, $t0, 24
	addi $t4, $t4, 1
	j drawBlackHearts
doneDrawingBlackHearts:
	li $t0, BASE_ADDRESS
	li $t4, 0
	addi $t0, $t0, 260
drawHearts:
	beq $t4, $s7, doneDrawingHearts
	drawHeart
	addi $t0, $t0, 24
	addi $t4, $t4, 1
	j drawHearts
doneDrawingHearts:
	clearTopRight
	# draw number 1, only if stack value is 1
	lw $t4, ($sp)
	bne $t4, 1, dontDrawOne
	drawNumberOne
dontDrawOne:
	# draw number 2, only if stack value is 2
	bne $t4, 2, dontDrawTwo
	clearTopRight
	drawNumberTwo
dontDrawTwo:
	# draw number 3, only if stack value is 3
	bne $t4, 3, doneDrawing
	clearTopRight
	drawNumberThree
	li $v0, 32
   	li $a0, 1000
    	syscall
doneDrawing:
.end_macro
.macro drawPlayer
	li $t4, 0
	li $t0, BASE_ADDRESS
	addi $t0, $t0, 12152
drawPinkGuy: # draw pink guy standing on grass
	beq $t4, 8, doneDrawingPinkGuy
	sw $t7, ($t0)
	sw $t7, 4($t0)
	sw $t7, 8($t0)
	addi $t0, $t0, 256
	addi $t4, $t4, 1
	j drawPinkGuy
doneDrawingPinkGuy:
.end_macro
deleteScreen
drawPlayer
# main loop
main:
	drawEverything
	beq $s7, 0, playerLost # if player runs out of 3 lives, lose
	lw $t4, ($sp)
	beq $t4, 3, playerWon # if player survives 3 lasers, win
	li $t8, 256
	li $t4, 0
	beq $t3, 0, notJumping
	jumpPlayer $s3
	blt $t3, 14, notJumpingOrFalling
	li $t3, 0
notJumping:
	beq $s5, 0, notJumpingOrFalling
	fallingPlayer $s3
	blt $s5, 14, notJumpingOrFalling
	li $s5, 0
notJumpingOrFalling:
	laserAttack
	lw $s1, 0($s0) # check for key press
	lw $s2, 4($s0) # check for what key
	bgt $t3, 0, main
	bgt $s5, 0, main
	beq $s1, 1, keypressHappened # check for keypress
	bge $t5, 280, resetLasers # reset laser position register after one laserbeam
	li $v0, 32
   	li $a0, 100
    	syscall
	j main
keypressHappened:
	#laserAttack
	div $s3, $t8
	mfhi $s1
	beq $s2, 0x61, moveLeft # a was pressed, move left 
	beq $s2, 0x64, moveRight # d was pressed, move right
	beq $s2, 0x77, jumpUp # w was pressed, jump 
	beq $s2, 0x73, fallDown # s was pressed, fall down from platform (that is not the ground)
	beq $s2, 0x72, restartGame # r was pressed, restart game
	beq $s2, 0x71, quit # quit if q is pressed
    	j doneKeypressCheck
restartGame:
	# reset everything
	deleteScreen
	drawPlayer
	li $t4, 0
	sw $t4, ($sp)
	# preset initial player coordinate
	li $s3, 13944 # bottom left of pink guy
	# load register for holding jump counter
	li $t3, 0
	# load register for enemy laser movement
	li $t5, 0
	# load register for player iframes counter
	li $s4, 0
	# load register for falling counter
	li $s5, 0
	# load register for enemy laser location (top right of laser for lasers coming from left, and vice versa)
	li $s6, 0
	# load register for number of lives 
	li $s7, 3
	j main
moveLeft:
	beq $s1, 0, doneKeypressCheck
	movePlayerLeft $s3
	j doneKeypressCheck
moveRight:
	bge $s1, 244, doneKeypressCheck
	movePlayerRight $s3
	j doneKeypressCheck
jumpUp:
	jumpPlayer $s3
	j doneKeypressCheck
fallDown:
	downThroughPlatform $s3
	j doneKeypressCheck
doneKeypressCheck:
	li $v0, 32
   	li $a0, 50
    	syscall
    	j main
resetLasers:
	li $t5, 0
	li $s6, 0
addPoint: # add a point for each laser survived
# increment the stack value by 1
	lw $t4, ($sp) 
	addi $t4, $t4, 1
	sw $t4, ($sp)
j main

quit:
deleteScreen
j end
playerLost:
gameOverScreen
j end
playerWon:
victoryScreen
j end
end:
li $v0, 10 # gg wp
syscall
