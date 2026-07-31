`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module player_button(
    input clk,
    input rst,
    input in_signal,     
    output pulse_out 
    );
    
    wire debounced;
    
    button_debounce debouncer(clk, rst, in_signal, debounced);
    edge_detector ed(clk, rst, debounced, pulse_out);
    
endmodule
