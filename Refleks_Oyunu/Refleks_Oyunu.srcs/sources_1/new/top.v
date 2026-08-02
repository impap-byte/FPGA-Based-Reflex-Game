`timescale 1ns / 1ps

module top (
    input clk,          // 100 MHz Sistem Saati
    input btnC,         // Reset için (Orta Buton)
    input btnU,         // tx_start için (Üst Buton)
    input btnD,
    input btnR,
    input btnL,
    input reset,
    
    
    input[3:0] conf,
    input [7:0] sw,     // Gönderilecek 8-bit veri (Switch 0-7)
    output tx,        // UART TX Ç?k??? (Bilgisayara giden hat)
    output led0,         // tx_done sinyalini görmek için
    // 7 segment
    output [6:0] seg,  // Pass-through to physical pins
    output [3:0] an    // Pass-through to physical pins
);

    
    
    
    // UART TX 
    uart_tx uart_tx_module (
        .clk(clk),
        .reset(btnC),
        .tx_start(p1_pushed),
        .data_in(sw),
        .tx(tx),
        .tx_done(led0)
    );
    game_manager gm();
 
endmodule