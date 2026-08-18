`timescale 1ns / 1ps

module seven_segment_driver(

    input clk,
    input reset,
    input display_enable,
    input [3:0] digit0,
    input [3:0] digit1,
    input [3:0] digit2,
    input [3:0] digit3,
    input [3:0] digit_enable_mask,
    output reg [6:0] seg,
    output reg [3:0] an

);
    
    reg [16:0] refresh_counter;

    always @(posedge clk) begin

        if(reset)
            refresh_counter <= 17'd0;

        else
            refresh_counter <= refresh_counter + 1'b1;

    end

    wire [1:0] active_digit;
    assign active_digit = refresh_counter[16:15];
    reg [3:0] current_digit;

    always @(*) begin
        if(!display_enable) begin
            an = 4'b1111;
            current_digit = 4'd0;
        end

        else begin

            case(active_digit)
                2'b00:
                begin
                    an = (digit_enable_mask[0]) ? 4'b0111 : 4'b1111;
                    current_digit = digit0;
                end
                2'b01:
                begin
                    an = (digit_enable_mask[1]) ? 4'b1011 : 4'b1111;
                    current_digit = digit1;
                end
                2'b10:
                begin
                    an = (digit_enable_mask[2]) ? 4'b1101 : 4'b1111;
                    current_digit = digit2;
                end
                2'b11:
                begin
                    an = (digit_enable_mask[3]) ? 4'b1110 : 4'b1111;
                    current_digit = digit3;
                end
            endcase
        end
    end

    always @(*) begin
        if(!display_enable)
            seg = 7'b1111111;
        else begin
            case(current_digit)
                4'd0:
                    seg = 7'b1000000;
                4'd1:
                    seg = 7'b1111001;                
                4'd2:
                    seg = 7'b0100100;
                4'd3:
                    seg = 7'b0110000;
                4'd4:
                    seg = 7'b0011001;
                4'd5:
                    seg = 7'b0010010;
                4'd6:
                    seg = 7'b0000010;
                4'd7:
                    seg = 7'b1111000;  
                4'd8:
                    seg = 7'b0000000;
                4'd9:
                    seg = 7'b0010000;
                default:
                    seg = 7'b1111111;
            endcase
        end
    end
endmodule