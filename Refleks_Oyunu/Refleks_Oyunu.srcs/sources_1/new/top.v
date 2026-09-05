`timescale 1ns / 1ps
// Refleks Oyunu - Gumus Adalar

//BTNU: Oyuncu 1 
//BTNL: Oyuncu 2 
//BTNR: Oyuncu 3 
//BTND: Oyuncu 4

//Oyuncu 1: LED0-LED3 
//Oyuncu 2: LED4-LED7 
//Oyuncu 3: LED8-LED11 
//Oyuncu 4: LED12-LED15

//Konfigürasyon
//SW15 -> 1 ise reset
//SW14 ve SW13 -> Player count (00 -> 2 oyuncu, 01 -> 3 oyuncu, 10 -> 4 oyuncu)
//SW12-SW9 -> Raunt Say?s? (0000 -> 1 raunt)
//SW8 -> 1 ise eleme modu aktif
//SW7 -> 1 ise zor mod aktif

// Modüller

//configuration.v
//Switchlere gore oyun modlar?n? ayarlar, gecersiz konfigleri kabul etmez

//game_manager.v
//Tur say?s?n?, elenenleri kontrol eder ve moduller aras? kopru gorevi gorur

//game_fsm.v
//Durumlar arasi gecis yapar ve game_manager'a su anki ve bir onceki durumu iletir

//wait_manager.v
// Icindeki lfsr yardimiyla zor/kolay moda gore rastgele bekleme zamani uretir

// buttons.v
// edge detector ve debouncer yardimiyla oyuncu butonlarinin dogru calismasini saglar

// reaction_timer.v
// oyuncularin basma zamanlarini olcer ve hesaplamalar icin TO, FS veya zaman bilgilerini score managera game man. 
// uzerinden iletir

//score_manager.v
// siralama ve puan hesaplar. Alt modulu(total_score_manager.v) genel puanlari depolar/gunceller

//seven_segment_manager.v
//seven segmenti refleks oyununa ozgu bir fsm sayesinde yonetir

//uart_stream_manager.v
// Icindeki bcd donusturuculer sayesinde binary degerleri bcd'ye cevirir ve UART protokolu uzerinden yaziyla
// beraber bilgisayara yollar

//led_manager.v
//Siralamaya gore ledleri yakar

module top (
    input clk,        
    input btnC,        
    input btnU,         
    input btnD,
    input btnR,
    input btnL,
    input reset,
    input [8:0] sw,
    
    output tx,          
    output [15:0] led,  // led cikislari  
    output [6:0] seg,   // 7-segment display
    output [3:0] an    
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