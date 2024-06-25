# dino_game

## 1. Explanations

This project was inspired by Dino Game’, which was opened when there was no internet available in Chrome. When the game is first run, “PRESS1” text comes on display. From “0xFF200050”, we read 12 bytes ahead of “Edge Bits” and check if there is data coming through the button. If this comes from “0001”, which is the rightmost button, it means that the button is pressed, and this starts the game. We only read data from the rightmost button. We do this by masking the data we hold with the value of "0001". If the data from the button is equal with this masked value, we clean the display and the game starts.

When our game starts, Dino is first positioned from left to 2nd display. Then the obstacles start to come from the right. When the game starts, the timer is set to 200MHz with an obstacle coming every 1 seconds. These obstacles are random. We carry out this random making process through the timer that we already use. First of all, after the obstacle has formed, we read the value of “Current Value” in the timer. We add to this value the R0 counter that we observe to the number of refreshes in the timer. Then we shift this number to 31 bit left and get the last bit to the top and the rest is reset. Then we compare this number with the number of “0x8000000”. As a result, if the value we get is “1”, the obstacle is below, if this value is “0”, the obstacle is formed above. Thus, we can form our obstacles in a random way.

As the obstacles slip, we take the final version of the obstacle from the right through the 4th display and compare it to the current position of the Dino. If Dino is on the side of the obstacle after the obstacle is slipped, Dino dies and in the other case the game continues. When Dino dies, the game ends and “LOST” is printed on the screen. 

This is how our game works. The game lasts 25 seconds and consists of 3 levels:

•    LEVEL1: The first level is the process of getting used to the game. We write 200MHz to “Load Value” address in Timer, which is equivalent to one second. This creates a new obstacle every second and then shifts to the left. This level covers the first 7 seconds of the game. After 7 seconds, the first level is completed and reached to level 2.

•    LEVEL2: In the second level after the 7th second of the game, we update the “Load Value" located in the timer. Here we write 150MHz, which is equivalent to 0.75 seconds. At this level, an obstacle is created every 0.75 seconds. This level makes the game both faster and more difficult.At the end of 9 seconds, the second level is completed and the final level is reached to level 3.


•    LEVEL3: From the 16th second of the game, the last level, level 3, has been reached. This level is now the most difficult level of our game and it is really quite difficult to survive at this level. At this level, we are updating “Load Value” for the last time. We write 100MHz, which is equal to 0.5 seconds. This creates an obstacle every 0.5 seconds. This level covers the last 9 seconds of the game. Then the game is completed.

These durations are created thanks to the “Interrupt Status” bit found in Timer. This bit becomes one when each timer 0’s and starts again. According to this bit, our R0 counter increases. In this way, we can keep the data on how many obstacles have come and how many times the timer has been reset in the R0 register. In this way, we can adjust the time according to R0’ and make level upgrades.  We also print the level numbers here at the leftmost display. So the player can see what level he is on display. 

If the player successfully passes all these levels and manages to keep Dino alive without any obstacles for a total of 25 seconds, the player wins the game and "FINISH" is displayed on the display.

## 2. Flowchart

