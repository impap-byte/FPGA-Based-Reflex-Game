`timescale 1ns / 1ps

module top (
    input clk,          // 100 MHz Sistem Saati
    input btnC,         // Reset için (Orta Buton)
    input btnU,         // tx_start için (Üst Buton)
    input btnD,
    input btnR,
    input btnL,
    input reset,
    input [8:0] sw,
    output tx,        // UART TX Ç?k??? (Bilgisayara giden hat)
    output led0,         // tx_done sinyalini görmek için
    // 7 segment
    output [6:0] seg,  // Pass-through to physical pins
    output [3:0] an    // Pass-through to physical pins
);

    wire config_done, hardmode, elimination;
    wire [1:0] player_count;
    wire [3:0] max_round;
    
    configuration c(
        .clk(clk),
        .rst(reset),
        .sw(sw),       // Raw switches from Basys3
        
        .player_count(player_count),
        .hardmode(hardmode),
        .max_round(max_round),
        .elimination(elimination), // Added the elimination output
        .config_done(config_done)
    );
    
//    // UART TX 
//    uart_tx uart_tx_module (
//        .clk(clk),
//        .reset(btnC),
//        .tx_start(p1_pushed),
//        .data_in(sw),
//        .tx(tx),
//        .tx_done(led0)
//    );
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
        .uart_data(),  // Will be connected to uart_tx module later
        .max_round(max_round),
        .elimination(elimination),
        .seg(seg),
        .an(an)
);
 
    
    
    
endmodule