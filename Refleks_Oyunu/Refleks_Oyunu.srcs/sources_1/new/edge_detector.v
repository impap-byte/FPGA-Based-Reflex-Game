`timescale 1ns / 1ps

module edge_detector (
    input clk,
    input rst,
    input in_signal, // Button_debounce'dan gelir
    output reg pulse_out
);

    // D flip-flop register'i
    reg in_signal_prev; 

    always @(posedge clk) begin
        if (rst) begin
            in_signal_prev <= 1'b0;
            pulse_out      <= 1'b0;
        end else begin
            in_signal_prev <= in_signal; // Bir sonraki cycle icin kaydedilir
            
            pulse_out <= in_signal && !in_signal_prev; 
        end
    end

endmodule