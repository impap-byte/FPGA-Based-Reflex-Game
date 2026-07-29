`timescale 1ns / 1ps

// Geçici olarak AI desteði yapýlmýþtýr, bu modül baþtan yazýlacak.
module edge_detector (
    input clk,
    input rst,
    input in_signal,     
    output reg pulse_out 
);

    reg in_signal_prev; 

    always @(posedge clk) begin
        if (rst) begin
            in_signal_prev <= 1'b0;
            pulse_out      <= 1'b0;
        end else begin
            in_signal_prev <= in_signal;
            
            pulse_out <= in_signal && !in_signal_prev;
        end
    end

endmodule