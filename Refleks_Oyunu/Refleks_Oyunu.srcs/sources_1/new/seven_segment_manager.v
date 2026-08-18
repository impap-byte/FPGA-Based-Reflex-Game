`timescale 1ns / 1ps

module seven_segment_manager #(parameter DIGIT_WAIT_TIME = 50000000)(
    input clk,
    input rst,
    input [3:0] round_count,
    input display_enable,
    output reg done,
    output [6:0] seg, 
    output [3:0] an
);  
    
    // 0 for even rounds, 1 for odd rounds
    wire even_odd = round_count[0]; 
    
    reg [3:0] digit0, digit1, digit2, digit3;
    reg [3:0] digit_enable; // 4-bit mask to tell the driver which digits are actively on.
    
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
    localparam FIFTH  = 3'd5;
    
    reg [2:0] state;
    reg [31:0] counter;
    
    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            counter <= 0;
            done <= 0;
            digit_enable <= 4'b0000;
            
            digit0 <= 4'hF; 
            digit1 <= 4'hF; 
            digit2 <= 4'hF;
            digit3 <= 4'hF;
        end else if (display_enable) begin

            if (state == FIFTH) begin
                // Tum LEDLER acik hali
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