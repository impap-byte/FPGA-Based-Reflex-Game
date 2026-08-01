`timescale 1ns / 1ps

module random_time(
    input clk,
    input rst,
    input hardmode,
    output reg [12:0] wait_ms // timer'a gidecek milisaniye degeri, max sure 5000 ms oldugundan oturu 13 bit araliginda
    );
    wire [15:0] random;
    
    lfsr generator(clk, rst, random);
    
    always @* begin
        if (hardmode) begin
            wait_ms = (random % 16'd4501) + 13'd500;
        end else begin
            wait_ms = (random % 16'd3001) + 13'd2000;
        end
    end
endmodule
