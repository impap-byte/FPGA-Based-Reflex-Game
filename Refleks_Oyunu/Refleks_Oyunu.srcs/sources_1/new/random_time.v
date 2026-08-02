`timescale 1ns / 1ps

module random_time(
    input clk,
    input rst,
    input hardmode,
    output reg [12:0] wait_ms // timer'a gidecek milisaniye degeri, max sure 5000 ms oldugundan oturu 13 bit araliginda
    );
    wire [15:0] random;
    
    lfsr generator(clk, rst, random);
    
    always @(*) begin
        if (hardmode) begin
            // Zor Mod: 500 - 5000 ms (genislik N = 4501)
            wait_ms = 13'd500 + ((random * 32'd4501) >> 16);
        end else begin
            // Kolay Mod: 2000 - 5000 ms (genislik N = 3001)
            wait_ms = 13'd2000 + ((random * 32'd3001) >> 16);
        end
    end
endmodule