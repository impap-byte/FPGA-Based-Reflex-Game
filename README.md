# FPGA-Based Reflex Game

This game was designed as part of TOBB ETU Computer Engineering course [BIL265(Logical Circuit Design and its Applications)](https://abys.etu.edu.tr/public/lesson.jsp?program=5&lang=tr&lesson=B%C4%B0L265). 

This project features a game coded in Verilog and running on a Basys3 FPGA, that measures the players' reaction times and handles an FSM. During the game, the four digits on the 7-segment display of Basys3 light up in sequence. After a random delay suddenly all the digits turn off. The player who presses the button first after the blackout wins the round. The logs are sent to the computer at the end of each round through UART. Essentially, the game works in similar fashion to the following: https://www.youtube.com/watch?v=3o2ulXGwy-k&t=296s.

## Button and LED Assignments

* __BTNU__: Player 1
* __BTNL__: Player 2
* __BTNR__: Player 3
* __BTND__: Player 4

* __Player 1__: LED0-LED3
* __Player 2__: LED4-LED7
* __Player 3__: LED8-LED11
* __Player 4__: LED12-LED15

## Configuration
- __SW14 & SW13__ -> Player count (00 -> 2 players, 01 -> 3 players, 10 -> 4 players)
- __SW12-SW9__ -> Number of rounds (0000 -> 1 round)
- __SW8__ -> Elimination mode active if 1
- __SW7__ -> Hard mode active if 1

### Elimination Mode
* **When Elimination Mode is ON:**
  * Players who press the button before the LEDs turn off are **eliminated** from subsequent rounds.
  * Players who fail to press the button within **5 seconds** after the blackout are **eliminated** from subsequent rounds.

* **When Elimination Mode is OFF:**
  * Players who commit these errors simply receive **0 points** for that round and **continue playing** in subsequent rounds.
    
## Difficulty Mode 
The difficulty mode determines the random time interval to wait before the 7-segment LEDs turn off.
- Easy mode: 2.0 – 5.0 seconds 
- Hard mode: 0.5 – 5.0 seconds

## Modules

### configuration.v
Sets game modes based on switches; rejects invalid configurations.

### game_manager.v
Controls round count and eliminated players; acts as a bridge between modules.

### game_fsm.v
Handles state transitions and communicates current/previous states to game_manager.

### wait_manager.v
Generates a random waiting time based on hard/easy mode using an internal LFSR(Linear Feedback Shift Register).

### buttons.v
Ensures correct operation of player buttons using edge detection and debouncing.

### reaction_timer.v
Measures player reaction times and transmits TO (Timeout), FS (False Start), or timing data to score_manager via game_manager for calculations.

### score_manager.v
Calculates rankings and scores. The submodule (total_score_manager.v) stores/updates the total scores.

### seven_segment_manager.v
Manages the seven-segment display using an FSM specific to the reflex game.

### uart_stream_manager.v
Converts binary values ​​to BCD using internal BCD converters and transmits them (along with text) to the computer via the UART protocol.

### led_manager.v
Illuminates the LEDs according to the sequence.
