`timescale 1ns / 1ps

module random_time(
    input clk,
    input rst,
    output done
    );
    reg [15:0] random;
    lfsr generator(clk, rst, random);
    
endmodule
