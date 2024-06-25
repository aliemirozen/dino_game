.text
.global _start

_start:
   LDR R2, =0xFF200020 // HEX1 Adress
   LDR R3, =0xFF200030 // HEX2 Adress
   LDR R4, =0xfffec600 // Timer Adress
   LDR R5, =0xFF200050 // Buttons Adress
   LDR R6, =0xFF200040 // Switches Adress

   //Timer Configuration
   LDR R8, =200000000 // 200MHz = 1sn
   STR R8, [R4]
   MOV R8, #0b011
   STR R8, [R4, #8]
   MOV R0, #0
   
   LDR R8, =0x7B6D6D06    // 01111011 01101101 01101101 00000110 = ESS1
   STR R8, [R2]
   LDR R8 , =0x00007331   // 00000000 00000000 01110011 00110001 = PR
   STR R8, [R3]
   
   LDR R1, =0x00000600 //Score
   
START_GAME: 
   LDR R7, [R5, #12] 
   AND R7, R7, #1
   CMP R7, #1 // Checking whether the rightmost button is pressed or not
   BEQ RESET
   BNE START_GAME
   
LOOP_DINO:
   // Check the position of the switches
   MOV R8, #0x00000001
   LDR R10, [R6]
   AND R8, R8, R10
   CMP R8 , #1
   MOVEQ R9, #0b01100000 // If the switches are up, that is, "1", the Dino is up.
   MOVNE R9, #0b01010000 // If the switches are down, that is, "0", the Dino is down
   ADD R9, R9, R1 // Score + Dino
   STR R9, [R3]

OBSTACLE_UPDATE:
   LDR R8, [R4, #12] // An obstacle comes every second.
   CMP R8, #1
   BNE LOOP_DINO // If 1 second is not up, go back to LOOP_DINO
   ADD R0, R0, #1 // Counter that keeps count of seconds
   
   LDR R11, [R2]
   ADD R7, R7, R0
   LSL R7, #31
   CMP R7, #0x80000000 // Check if the obstacle is up
   MOVEQ R12, #0b00000001 // If the last bit of the number we obtain is 1, the obstacle occurs below.
   MOVNE R12, #0b00001000 // If the last bit of the number we obtain is 0, the obstacle occurs above.
   
   // Check if dead
   MOV R9, #0x00000001
   LDR R10, [R6]
   AND R9, R9, R10
   CMP R9, #0
   MOVEQ R9, #0b00000001
   MOVEQ R9, #0b00001000
   MOV R10, R11
   LSR R10, #24
   AND R10, R10, R9
   CMP R10, #0b00000001
   BEQ DIE // If the Dino and the obstacle are above, kill the Dino in the last swipe.
   CMP R10, #0b00001000
   BEQ DIE // If the Dino and the obstacle are below, kill the Dino in the last swipe.
   
   // Move all obstacles to the left
   LSL R11, #8
   ADD R11, R11, R12
   STR R11, [R2]
   STR R8, [R4, #12]
   
   // Speed up obstacle arrival after 7 seconds. Cycle every 0.75 seconds.
   CMP R0, #7
   BEQ TIME_UPDATE2
   
   // Speed up obstacle arrival after 16 seconds. Cycle every 0.5 seconds.
   CMP R0, #19
   BEQ TIME_UPDATE3
   
   // Win the game after 25 seconds.
   CMP R0, #37
   BEQ WON_THE_GAME 
   LDR R7, [R4, #4]
   B LOOP_DINO

DIE: 
   //After Dino dies, write LOSE on the display.
   LDR R8, =0x3F6D7900 //00111111 01101101 01111001 = OSE
   STR R8, [R2]
   LDR R8 , =0x00000038 //00111000 = L
   STR R8, [R3]
   B END

TIME_UPDATE2:
   // Set obstacle encounter time to 0.75
   LDR R8, =150000000
   STR R8, [R4]
   LDR R1 , =0x00005B00   // 01011011 Change the score
   B LOOP_DINO

TIME_UPDATE3:
   // Set obstacle encounter time to 0.5
   LDR R8, =100000000
   STR R8, [R4]
   LDR R1 , =0x00004F00   // 01001111 Change the score
   B LOOP_DINO
   
WON_THE_GAME:
   // If Dino survives for 25 seconds, print finish on the screen.
   LDR R8, =0x37066D76    // 00110111 00000110 01101101 01110110 = NISH
   STR R8, [R2]
   LDR R8 , =0x00007106   // 00000000 00000000 01110001 00000110 = FI
   STR R8, [R3]
   B END              
   
RESET:
   // 7-segment display resets and the game begins
   LDR R8, =0x00000000 
   STR R8, [R2]
   LDR R8 , =0x00000000
   STR R8, [R3]
   B LOOP_DINO

END:
   B END
