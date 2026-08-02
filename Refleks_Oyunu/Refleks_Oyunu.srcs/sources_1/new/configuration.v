`timescale 1ns / 1ps
// 1 b enable - 2 bit player count - 4 bit tur sayisi - 1 bit eleme - 1 bit zorluk
module config_manager(
    input clk,
    input rst,
    input [8:0] sw,       // Raw switches from Basys3
    
    output reg [1:0] player_count,
    output ready,
    output reg hardmode,
    output reg [3:0] max_round,
    output reg config_done
);
    // Logic to decode switches and set config_done goes here
    reg conf_done = 0;
    wire confirm = sw[0];
    wire rounds = sw[6:3];
    always @(posedge clk) begin
        
        if (confirm && !conf_done) begin
            conf_done <= 1;
            
            player_count <= sw[2:1];
            
            max_round <= sw[3:6];
            if(player_count == 2'b11) begin
                conf_done <= 0;
            end
            
            
        end
        
    end
endmodule
