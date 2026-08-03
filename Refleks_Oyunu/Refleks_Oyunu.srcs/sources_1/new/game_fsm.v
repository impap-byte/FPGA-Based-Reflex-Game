`timescale 1ns / 1ps

module game_fsm(
    input clk,
    input rst,
    input btnC,
    input config_done,
    input seq_done,
    input wait_done,
    input reaction_done,
    input uart_done,
    input last_round,
    input game_over_early,
    output reg start_wait,
    output reg start_reaction,
    output reg calc_score,
    output reg uart_start,
    output reg display_enable,
    output reg game_over,
    output reg [3:0] state_out
);

    localparam RESET_STATE      = 4'd0;
    localparam CONFIG           = 4'd1;
    localparam WAIT_START       = 4'd2;
    localparam DISPLAY_SEQUENCE = 4'd3;
    localparam RANDOM_WAIT      = 4'd4;
    localparam BLACKOUT         = 4'd5;
    localparam REACTION         = 4'd6;
    localparam SCORE            = 4'd7;

    localparam UART_ROUND_PULSE = 4'd8;
    localparam UART_ROUND_WAIT  = 4'd9;
    localparam NEXT_ROUND       = 4'd10;
    
    // Added dedicated states to print the Game Over winner message
    localparam UART_OVER_PULSE  = 4'd11;
    localparam UART_OVER_WAIT   = 4'd12;
    localparam GAME_FINISH      = 4'd13;

    reg [3:0] state;
    reg [3:0] next_state;

    always @(posedge clk) begin
        if(rst)
            state <= RESET_STATE;
        else
            state <= next_state;
    end

    always @(*) begin
        next_state = state;
        case(state)
            RESET_STATE: begin
                if(!rst) next_state = CONFIG;
            end
            CONFIG: begin
                if(config_done) next_state = WAIT_START;
            end
            WAIT_START: begin
                if(btnC) next_state = DISPLAY_SEQUENCE;
            end
            DISPLAY_SEQUENCE: begin
                if(seq_done) next_state = RANDOM_WAIT;
            end
            RANDOM_WAIT: begin
                if(wait_done) next_state = BLACKOUT;
            end
            BLACKOUT: begin
                next_state = REACTION;
            end
            REACTION: begin
                if(reaction_done) next_state = SCORE;
            end
            SCORE: begin
                next_state = UART_ROUND_PULSE; // Go to pulse state
            end
            
            UART_ROUND_PULSE: begin
                next_state = UART_ROUND_WAIT;  // Immediately move to wait state (1 cycle later)
            end
            UART_ROUND_WAIT: begin
                if(uart_done) next_state = NEXT_ROUND; // Wait for UART to finish
            end
            
            NEXT_ROUND: begin
                if(last_round || game_over_early)
                    next_state = UART_OVER_PULSE; // Trigger final print
                else
                    next_state = WAIT_START;
            end
            
            UART_OVER_PULSE: begin
                next_state = UART_OVER_WAIT; // Immediately move to wait state
            end
            UART_OVER_WAIT: begin
                if(uart_done) next_state = GAME_FINISH; // Wait for final print to finish
            end
            
            GAME_FINISH: begin
                next_state = GAME_FINISH; // Lock up here safely
            end
            default: next_state = RESET_STATE;
        endcase
    end

    // --- Output Logic ---
    always @(*) begin
        start_wait = 0;
        start_reaction = 0;
        calc_score = 0;
        uart_start = 0;
        display_enable = 0;
        game_over = 0;
        
        case(state)
            CONFIG: begin
                display_enable = 1;
            end
            WAIT_START: begin
                display_enable = 1;
            end
            DISPLAY_SEQUENCE: begin
                display_enable = 1;
            end
            RANDOM_WAIT: begin
                display_enable = 1;
                start_wait = 1;
            end
            BLACKOUT: begin
                display_enable = 0;
                start_reaction = 1;
            end
            REACTION: begin
                display_enable = 0;
            end
            SCORE: begin
                calc_score = 1;
            end
            
            // Generate a strict 1-cycle pulse for uart_start
            UART_ROUND_PULSE: begin
                uart_start = 1; 
            end
            // In the WAIT state, uart_start drops to 0 automatically
            
            // Same for the Game Over print, but ensure game_over is High!
            UART_OVER_PULSE: begin
                uart_start = 1;
                game_over = 1;
            end
            UART_OVER_WAIT: begin
                game_over = 1; // Keep the multiplexer pointed at the end_char string
            end
            
            GAME_FINISH: begin
                game_over = 1; 
            end
            default: begin
            end
        endcase
    end

    always @(*) begin
        state_out = state;
    end
endmodule