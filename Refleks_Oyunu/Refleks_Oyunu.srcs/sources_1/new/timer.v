`timescale 1ns / 1ps

module timer(
    input             clk,
    input             rst,
    input             start_wait,
    input             start_reaction,
    input [12:0]      wait_ms,
    output reg        wait_done,
    output reg [12:0] reaction_time,
    output reg        timeout
    );

    // Clock sinyali saniyede 100 milyon kez atildigi icin once 1 ms cozunurlukte olculmeli.
    reg [16:0] prescaler_count; // 0-99999 sayaci icin en az 17 bit gerekli.
    wire       ms_tick;
    
    assign ms_tick = (prescaler_count == 17'd99_999);
    
    // 0'dan 99999'a kadar sayan sayac 1 ms gectiginin haberini ms_tick sinyali araciligi ile veriyor.
    always @(posedge clk) begin
        if (rst) begin
            prescaler_count <= 17'd0;
        end else if (ms_tick) begin
            prescaler_count <= 17'd0; // 1 ms gectigi durum
        end else begin
            prescaler_count <= prescaler_count + 1'b1;
        end
    end 
    
    
    
endmodule
