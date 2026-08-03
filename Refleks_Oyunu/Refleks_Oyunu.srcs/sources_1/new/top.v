`timescale 1ns / 1ps

module top (
    input clk,          // 100 MHz Sistem Saati
    input btnC,        
    input btnU,         
    input btnD,
    input btnR,
    input btnL,
    input reset,
    input [8:0] sw,
    
    output tx,          // UART TX Ç?k??? (Bilgisayara giden hat)
    output [15:0] led,  // led ç?k??lar?
    output [6:0] seg,   // 7-segment display
    output [3:0] an     // 7-segment display anot
);

    wire config_done, hardmode, elimination;
    wire [1:0] player_count;
    wire [3:0] max_round;
    wire uart_start;
    wire game_over;
    wire uart_done;
    wire [3:0] current_round;
    
    wire [12:0] p1_time, p2_time, p3_time, p4_time;
    wire [2:0]  p1_score, p2_score, p3_score, p4_score;
    wire [6:0]  p1_total, p2_total, p3_total, p4_total;
    wire [1:0]  f_rank_p1, f_rank_p2, f_rank_p3, f_rank_p4;
    
    wire p1_fs, p2_fs, p3_fs, p4_fs;
    wire p1_to, p2_to, p3_to, p4_to;
    wire p1_active, p2_active, p3_active, p4_active;

    configuration c(
        .clk(clk),
        .rst(reset),
        .sw(sw),
        .btnC(btnC),
        .player_count(player_count),
        .hardmode(hardmode),
        .max_round(max_round),
        .elimination(elimination),
        .config_done(config_done)
    );
      
    game_manager gm(
        .clk(clk),
        .rst(reset),
        .config_done(config_done),
        .btnC(btnC),
        .btnU(btnU),
        .btnD(btnD),
        .btnR(btnR),
        .btnL(btnL),
        .player_count(player_count),
        .hardmode(hardmode),
        .max_round(max_round),
        .elimination(elimination),
        
        .uart_start(uart_start),
        .game_over(game_over),
        .uart_done(uart_done), 
        .current_round(current_round),
        
        .p1_time(p1_time), .p2_time(p2_time), .p3_time(p3_time), .p4_time(p4_time),
        .p1_score(p1_score), .p2_score(p2_score), .p3_score(p3_score), .p4_score(p4_score),
        .p1_total(p1_total), .p2_total(p2_total), .p3_total(p3_total), .p4_total(p4_total),
        .f_rank_p1(f_rank_p1), .f_rank_p2(f_rank_p2), .f_rank_p3(f_rank_p3), .f_rank_p4(f_rank_p4),
        
        .p1_fs(p1_fs), .p2_fs(p2_fs), .p3_fs(p3_fs), .p4_fs(p4_fs),
        .p1_to(p1_to), .p2_to(p2_to), .p3_to(p3_to), .p4_to(p4_to),
        .p1_active(p1_active), .p2_active(p2_active), .p3_active(p3_active), .p4_active(p4_active),

        .seg(seg),
        .an(an),
        .led(led)
    );  
    
      uart_stream_manager uart_mgr(
        .clk(clk),
        .rst(reset),
        .start_print(uart_start),
        .game_over(game_over),
        .round_num(current_round),
        .player_count(player_count),

        .p1_time(p1_time), .p2_time(p2_time), .p3_time(p3_time), .p4_time(p4_time),
        .p1_score(p1_score), .p2_score(p2_score), .p3_score(p3_score), .p4_score(p4_score),
        .p1_total(p1_total), .p2_total(p2_total), .p3_total(p3_total), .p4_total(p4_total),
        .f_rank_p1(f_rank_p1), .f_rank_p2(f_rank_p2), .f_rank_p3(f_rank_p3), .f_rank_p4(f_rank_p4),
        
        .p1_fs(p1_fs), .p2_fs(p2_fs), .p3_fs(p3_fs), .p4_fs(p4_fs),
        .p1_to(p1_to), .p2_to(p2_to), .p3_to(p3_to), .p4_to(p4_to),
        .p1_active(p1_active), .p2_active(p2_active), .p3_active(p3_active), .p4_active(p4_active),
        .print_done(uart_done),
        .tx(tx)
    );
    
endmodule