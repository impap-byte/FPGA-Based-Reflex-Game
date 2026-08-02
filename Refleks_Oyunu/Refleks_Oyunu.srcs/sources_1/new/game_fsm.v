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
localparam UART_PRINT       = 4'd8;
localparam NEXT_ROUND       = 4'd9;
localparam GAME_FINISH      = 4'd10;

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
    RESET_STATE:
    begin
        if(!rst)
            next_state = CONFIG;
    end
    CONFIG:
    begin
        if(config_done)
            next_state = WAIT_START;
    end
    WAIT_START:
    begin
        if(btnC)
            next_state = DISPLAY_SEQUENCE;
    end
    DISPLAY_SEQUENCE:
    
    
    begin
        if(seq_done)
            next_state = RANDOM_WAIT;
    end
    RANDOM_WAIT:
    begin
        if(wait_done)
            next_state = BLACKOUT;
    end
    BLACKOUT:
    begin
        next_state = REACTION;
    end
    REACTION:
    begin
        if(reaction_done)
            next_state = SCORE;
    end
    SCORE:
    begin
        next_state = UART_PRINT;
    end
    UART_PRINT:
    begin
        if(uart_done)
            next_state = NEXT_ROUND;
    end
    NEXT_ROUND:
    begin
        if(last_round || game_over_early)
            next_state = GAME_FINISH;
        else
            next_state = WAIT_START;
    end
    GAME_FINISH:
    begin
        next_state = GAME_FINISH;
    end
    default:
        next_state = RESET_STATE;
    endcase
end
always @(*) begin
    start_wait = 0;
    start_reaction = 0;
    calc_score = 0;
    uart_start = 0;
    display_enable = 0;
    game_over = 0;
    case(state)
    CONFIG:
    begin
        display_enable = 1;
    end
    WAIT_START:
    begin
        display_enable = 1;
    end
    DISPLAY_SEQUENCE:
    begin
        display_enable = 1;
    end
    RANDOM_WAIT:
    begin
        display_enable = 1;
        start_wait = 1;
    end
    BLACKOUT:
    begin
        display_enable = 0;
        start_reaction = 1;
    end
    REACTION:
    begin
        display_enable = 0;
    end
    SCORE:
    begin
        calc_score = 1;
    end
    UART_PRINT:
    begin
        uart_start = 1;
    end
    GAME_FINISH:
    begin
        game_over = 1;
    end
    default:
    begin
    end
    endcase
end
always @(*) begin
    state_out = state;
end
endmodule