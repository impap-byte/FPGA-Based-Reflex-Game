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
    output uart_data,
    input max_round,
    output [6:0] seg,  // Pass-through to physical pins
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
    wait_manager wait_man(
        .clk(clk),
        .rst(rst),
        .start_wait(start_wait), // BTNC'ye basilinca bekleme suresini baslatmak icin
        .hardmode(hardmode), 
        .wait_done(wait_done)
    );
    
    button_manager buttons(

    .clk(clk),
    .rst(rst),

    // Ham buton giriþleri
    .btn_u(btnU),
    .btn_l(btnL),
    .btn_r(btnR),
    .btn_d(btnD),

    // 2,3 veya 4 oyuncu
    .player_count(player_count),

    // Her oyuncu için tek clockluk pulse
    .player1_pulse(p1_pulse),
    .player2_pulse(p2_pulse),
    .player3_pulse(p3_pulse),
    .player4_pulse(p4_pulse)

);
    
    
    game_fsm fsm(
        .clk(clk),
        .rst(rst),
        .btnC(btnC),
        .config_done(config_done),
        .seq_done(seq_done),
        .wait_done(wait_done),
        .reaction_done(),
        .uart_done(),
        .last_round(last_round),
        
        
        .start_sequence(), // redundant
        .start_wait(start_wait),
        .start_reaction(start_reaction),
        .calc_score(),
        .uart_start(),
        .display_enable(display_enable),
        .game_over(game_over),
        .state_out(fsm_state)
    );
    
    
    
    reaction_timer rt(
        .clk(clk),
        .rst(rst),
        .start(start_reaction), // FSM kontrolü
        .active_p1(p1_active && !p1_false_start),// Aktif oyuncu 1
        .active_p2(p2_active && !p2_false_start),// Aktif oyuncu 2
        .active_p3(p3_active && !p3_false_start),// Aktif oyuncu 3
        .active_p4(p4_active && !p4_false_start),// Aktif oyuncu 4
    
        // Buton pulse giriþleri
        .p1_btn(p1_pulse),
        .p2_btn(p2_pulse),
        .p3_btn(p3_pulse),
        .p4_btn(p4_pulse),
    
        // Reaksiyon süreleri (ms)
        .p1_time(),
        .p2_time(),
        .p3_time(),
        .p4_time(),
    
        // Timeout bilgileri
        .p1_timeout(),
        .p2_timeout(),
        .p3_timeout(),
        .p4_timeout(),
    
        // Ölçüm tamamlandý
        .done()
    
    );
    
    
    reg[3:0] round_count = 0;
    
    seven_segment_manager seven_segment(
        .clk(clk),
        .rst(rst),
        .round_count(round_count),
        .display_enable(display_enable),
        .done(seq_done),
        .seg(seg),  // Fiziksel pinlere yollayaca??z
        .an(an) 
    );
    
    localparam NEXT_ROUND = 4'd9;
    always @(posedge clk) begin
        last_round <= 0;
        round_count <= round_count;
        if(fsm_state == NEXT_ROUND) begin
            round_count <= round_count + 1;
            if(round_count == max_round - 2) last_round <= 1'b1;
        end

    end
    
    localparam DISPLAY_SEQUENCE = 4'd3;
    localparam RANDOM_WAIT      = 4'd4;
    localparam WAIT_START       = 4'd2;
    // Define when it is illegal to press the button.
 
    wire in_early_zone = (fsm_state == DISPLAY_SEQUENCE) || (fsm_state == RANDOM_WAIT);
    
   
    always @(posedge clk) begin
        if (rst || WAIT_START) begin 
            // Flagleri temizliyoruz
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
