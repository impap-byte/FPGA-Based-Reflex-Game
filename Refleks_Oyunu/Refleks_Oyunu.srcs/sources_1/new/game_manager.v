`timescale 1ns / 1ps

module game_manager(
    input clk,
    input rst,
    input config_done,
    input btnC,
    input btnU,
    input btnD,
    input btnR,
    input btnL,
    input [1:0] player_count,
    input p1_active,
    input p2_active,
    input p3_active,
    input p4_active,
    input hardmode,
    output uart_data, // Will be connected to uart_tx module later
    input [3:0] max_round,
    output [6:0] seg,  
    output [3:0] an
);
    
    wire game_over;
    wire display_enable;
    wire reaction_done;
    wire seq_done;
    wire wait_done;
    wire start_wait;
    wire start_reaction;
    wire p1_pulse, p2_pulse, p3_pulse, p4_pulse;
    wire [3:0] fsm_state;
    
    reg last_round;
    reg p1_false_start, p2_false_start, p3_false_start, p4_false_start;
    
    // --- INTERNAL WIRES FOR REACTION TIMER & SCORE MANAGER ---
    wire [12:0] p1_time, p2_time, p3_time, p4_time;
    wire p1_timeout, p2_timeout, p3_timeout, p4_timeout;
    wire [6:0] p1_score, p2_score, p3_score, p4_score;
    
    // Validity signals for the score manager (Player must be active and not have false started)
    wire p1_valid = p1_active && !p1_false_start;
    wire p2_valid = p2_active && !p2_false_start;
    wire p3_valid = p3_active && !p3_false_start && player_count != 2'b01;
    wire p4_valid = p4_active && !p4_false_start && player_count != 2'b01 && player_count != 2'b11;

    wire [1:0] p1_rank, p2_rank, p3_rank, p4_rank;
    wire [6:0] p1_total_score, p2_total_score, p3_total_score, p4_total_score;
    
    wait_manager wait_man(
        .clk(clk),
        .rst(rst),
        .start_wait(start_wait),
        .hardmode(hardmode), 
        .wait_done(wait_done)
    );
    
    button_manager buttons(
        .clk(clk),
        .rst(rst),
        .btn_u(btnU),
        .btn_l(btnL),
        .btn_r(btnR),
        .btn_d(btnD),
        .player_count(player_count),
        .player1_pulse(p1_pulse),
        .player2_pulse(p2_pulse),
        .player3_pulse(p3_pulse),
        .player4_pulse(p4_pulse)
    );
    
    wire calculate_enable;

    game_fsm fsm(
        .clk(clk),
        .rst(rst),
        .btnC(btnC),
        .config_done(config_done),
        .seq_done(seq_done),
        .wait_done(wait_done),
        .reaction_done(reaction_done),
        .uart_done(1'b1), // TEMPORARY: Tied to 1 so FSM doesn't get stuck waiting for UART
        .last_round(last_round),
        
        .start_sequence(), // redundant
        .start_wait(start_wait),
        .start_reaction(start_reaction),
        .calc_score(calculate_enable),
        .uart_start(),
        .display_enable(display_enable),
        .game_over(game_over),
        .state_out(fsm_state)
    );
    
    reaction_timer rt(
        .clk(clk),
        .rst(rst),
        .start(start_reaction),
        .active_p1(p1_valid), // Only allow press if they didn't false start
        .active_p2(p2_valid),
        .active_p3(p3_valid),
        .active_p4(p4_valid),
    
        .p1_btn(p1_pulse),
        .p2_btn(p2_pulse),
        .p3_btn(p3_pulse),
        .p4_btn(p4_pulse),
    
        // Connected to internal wires
        .p1_time(p1_time),
        .p2_time(p2_time),
        .p3_time(p3_time),
        .p4_time(p4_time),
    
        // Connected to internal wires
        .p1_timeout(p1_timeout),
        .p2_timeout(p2_timeout),
        .p3_timeout(p3_timeout),
        .p4_timeout(p4_timeout),
    
        .done(reaction_done)
    );
    
    score_manager scores(
        .clk(clk),
        .rst(rst),
        .calc_enable(calculate_enable),
        
        .rt_p1(p1_time),
        .rt_p2(p2_time),
        .rt_p3(p3_time),
        .rt_p4(p4_time),
        
        .fs_p1(p1_false_start),
        .fs_p2(p2_false_start),
        .fs_p3(p3_false_start),
        .fs_p4(p4_false_start),
        
        .to_p1(p1_timeout),
        .to_p2(p2_timeout),
        .to_p3(p3_timeout),
        .to_p4(p4_timeout),
        
        .active_p1(p1_valid),
        .active_p2(p2_valid),
        .active_p3(p3_valid),
        .active_p4(p4_valid),
        
        .score_p1(p1_score),
        .score_p2(p2_score),
        .score_p3(p3_score),
        .score_p4(p4_score),
        
        .rank_p1(p1_rank),
        .rank_p2(p2_rank),
        .rank_p3(p3_rank),
        .rank_p4(p4_rank),
        
        .total_score_p1(p1_total_score),
        .total_score_p2(p2_total_score),
        .total_score_p3(p3_total_score),
        .total_score_p4(p4_total_score)
    );
    
    reg[3:0] round_count = 0;
    
    seven_segment_manager seven_segment(
        .clk(clk),
        .rst(rst),
        .round_count(round_count), 
        .display_enable(display_enable),
        .done(seq_done),
        .seg(seg), 
        .an(an) 
    );
    
    localparam NEXT_ROUND = 4'd9;
    
    always @(posedge clk) begin
        last_round <= 0;
        round_count <= round_count;
        if(fsm_state == NEXT_ROUND) begin
            round_count <= round_count + 1'b1;
            if(round_count == max_round) last_round <= 1'b1;
        end
    end
    
    localparam WAIT_START       = 4'd2;
    localparam DISPLAY_SEQUENCE = 4'd3;
    localparam RANDOM_WAIT      = 4'd4;
    
    wire in_early_zone = (fsm_state == DISPLAY_SEQUENCE) || (fsm_state == RANDOM_WAIT);
    
    always @(posedge clk) begin
        if (rst || fsm_state == WAIT_START) begin 
            p1_false_start <= 0;
            p2_false_start <= 0;
            p3_false_start <= 0;
            p4_false_start <= 0;
        end else if (in_early_zone) begin
            if (p1_pulse && p1_active) p1_false_start <= 1;
            if (p2_pulse && p2_active) p2_false_start <= 1;
            if (p3_pulse && p3_active) p3_false_start <= 1;
            if (p4_pulse && p4_active) p4_false_start <= 1;
        end
    end
endmodule