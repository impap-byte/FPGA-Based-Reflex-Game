`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////


module seven_segment_driver(

    input wire clk,
    input wire reset,
    input wire display_enable,
    // Gösterilecek dört rakam
    input wire [3:0] digit0,
    input wire [3:0] digit1,
    input wire [3:0] digit2,
    input wire [3:0] digit3,
    // Basys3 7 segment çıkışları
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
    // Eğer display kapalıysa bütün basamaklar kapanır
        if(!display_enable) begin
            an = 4'b1111;
            current_digit = 4'd0;
        end

        else begin

            case(active_digit)
                // Birinci basamak
                2'b00:
                begin
                    an = 4'b1110;
                    current_digit = digit0;
                end
                // İkinci basamak
                2'b01:
                begin
                    an = 4'b1101;
                    current_digit = digit1;
                end
                // Üçüncü basamak
                2'b10:
                begin
                    an = 4'b1011;
                    current_digit = digit2;
                end
                // Dördüncü basamak
                2'b11:
                begin
                    an = 4'b0111;
                    current_digit = digit3;
                end
            endcase
        end
    end
    // 7 Segment Decoder
    // Basys3:
    //        a
    //       ---
    //    f |   | b
    //        g
    //    e |   | c
    //       ---
    //        d
    always @(*) begin
        // Blackout (tüm 7-segment basamaklarının söndüğü durum)
        if(!display_enable)
            seg = 7'b1111111;
        else begin
            case(current_digit)
                4'd0: // 0
                    seg = 7'b1000000;
                4'd1: // 1
                    seg = 7'b1111001;                
                4'd2: // 2
                    seg = 7'b0100100;
                4'd3: // 3
                    seg = 7'b0110000;
                4'd4: // 4
                    seg = 7'b0011001;
                4'd5: // 5
                    seg = 7'b0010010;
                4'd6: // 6
                    seg = 7'b0000010;
                4'd7: // 7
                    seg = 7'b1111000;  
                4'd8: // 8
                    seg = 7'b0000000;
                4'd9: // 9
                    seg = 7'b0010000;
                default: // Geçersiz değer
                    seg = 7'b1111111;
            endcase
        end
    end
endmodule