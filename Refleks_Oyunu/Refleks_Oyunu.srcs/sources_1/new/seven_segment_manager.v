`timescale 1ns / 1ps

module seven_segment_manager #(parameter DIGIT_WAIT_TIME = 50000000)(
    input clk,
    input rst,
    input [3:0] round_count,
    input display_enable,
    output reg done,
    output [6:0] seg,  // Pass-through to physical pins
    output [3:0] an    // Pass-through to physical pins
);  
    
    // 0 for even rounds (4, 6), 1 for odd rounds (5, 7)
    wire even_odd = round_count[0]; 
    
    reg [3:0] digit0, digit1, digit2, digit3;
    reg [3:0] digit_enable; // 4-bit mask to tell the driver which digits are actively ON
    
    seven_segment_driver driver(
        .clk(clk),
        .reset(rst),
        .display_enable(display_enable),
        .digit0(digit0),
        .digit1(digit1),
        .digit2(digit2),
        .digit3(digit3),
        .digit_enable_mask(digit_enable),
        .seg(seg),
        .an(an)
    );
    
    localparam IDLE   = 3'd0;
    localparam FIRST  = 3'd1;
    localparam SECOND = 3'd2;
    localparam THIRD  = 3'd3;
    localparam FOURTH = 3'd4;
    localparam FIFTH  = 3'd5; // Added to prevent the logic lockup
    
    reg [2:0] state;
    reg [31:0] counter;
    
    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            counter <= 0;
            done <= 0;
            digit_enable <= 4'b0000;
            
            // Initialize digits so they don't display '0' randomly before assignment
            digit0 <= 4'hF; // Assuming your driver turns 4'hF into a blank display
            digit1 <= 4'hF; 
            digit2 <= 4'hF;
            digit3 <= 4'hF;
        end else if (display_enable) begin

            if (state == FIFTH) begin
                // Sequence is fully visible: latch done high and stay here.
                // (Counter is irrelevant now, so it's never checked/incremented again.)
                done <= 1'b1;
            end else if (counter == DIGIT_WAIT_TIME - 1) begin
                counter <= 0;
                
                case (state)
                    IDLE: begin
                        state <= FIRST;
                    end
                    FIRST: begin
                        digit0 <= (even_odd * 4) + 1;
                        digit_enable <= 4'b0001; 
                        state <= SECOND;
                    end
                    SECOND: begin
                        digit1 <= (even_odd * 4) + 2;
                        digit_enable <= 4'b0011; 
                        state <= THIRD;
                    end
                    THIRD: begin
                        digit2 <= (even_odd * 4) + 3;
                        digit_enable <= 4'b0111; 
                        state <= FOURTH;
                    end
                    FOURTH: begin
                        digit3 <= (even_odd * 4) + 4;
                        digit_enable <= 4'b1111; 
                        state <= FIFTH;
                    end
                endcase
            end else begin
                counter <= counter + 1;
            end
            
        end else begin
            // Reset everything when display_enable drops
            state <= IDLE;
            counter <= 0;
            done <= 0;
            digit_enable <= 4'b0000;
        end
    end
endmodule