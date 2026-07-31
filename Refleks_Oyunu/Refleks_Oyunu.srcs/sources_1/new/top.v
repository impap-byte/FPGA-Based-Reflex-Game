`timescale 1ns / 1ps

module top (
    input clk,          // 100 MHz Sistem Saati
    input btnC,         // Reset için (Orta Buton)
    input btnU,         // tx_start için (Üst Buton)
    input btnD,
    input btnR,
    
    input [7:0] sw,     // Gönderilecek 8-bit veri (Switch 0-7)
    output tx,        // UART TX Ç?k??? (Bilgisayara giden hat)
    output led0         // tx_done sinyalini görmek için
);
    wire p1_pushed;
    player_button p1(clk, 1'b0, btnU, p1_pushed);
    
    // UART TX 
    uart_tx uart_tx_module (
        .clk(clk),
        .reset(btnC),
        .tx_start(p1_pushed),
        .data_in(sw),
        .tx(tx),
        .tx_done(led0)
    );
    
 
endmodule