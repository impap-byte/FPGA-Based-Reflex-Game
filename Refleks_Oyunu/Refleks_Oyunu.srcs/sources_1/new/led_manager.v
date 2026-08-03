`timescale 1ns / 1ps

module led_manager(
    input             clk,
    input             rst,
    input             game_over, // fsm'den
    input [2:0]       score_p1, score_p2, score_p3, score_p4, // round içi
    input [1:0]       f_rank_p1, f_rank_p2, f_rank_p3, f_rank_p4, // oyun sonu
    input             active_p1, active_p2, active_p3, active_p4,
    output reg [15:0] led
);
    
    
    always @(*) begin
        if (rst) begin
            led = 16'b0;
        end else if (game_over) begin
            led[3:0]   = (active_p1 && f_rank_p1 == 0) ? 4'b1111 : 4'b0000;
            led[7:4]   = (active_p2 && f_rank_p2 == 0) ? 4'b1111 : 4'b0000;
            led[11:8]  = (active_p3 && f_rank_p3 == 0) ? 4'b1111 : 4'b0000;
            led[15:12] = (active_p4 && f_rank_p4 == 0) ? 4'b1111 : 4'b0000;
        end else begin
            // Oyuncu 1
            case(score_p1)
                3'd0: led[3:0] = 4'b0000;
                3'd1: led[3:0] = 4'b0001;
                3'd2: led[3:0] = 4'b0011;
                3'd3: led[3:0] = 4'b0111;
                3'd4: led[3:0] = 4'b1111;
                default: led[3:0] = 4'b0000;
            endcase
    
            // Oyuncu 2
            case(score_p2)
                3'd0: led[7:4] = 4'b0000;
                3'd1: led[7:4] = 4'b0001;
                3'd2: led[7:4] = 4'b0011;
                3'd3: led[7:4] = 4'b0111;
                3'd4: led[7:4] = 4'b1111;
                default: led[7:4] = 4'b0000;
            endcase
    
            // Oyuncu 3
            case(score_p3)
                3'd0: led[11:8] = 4'b0000;
                3'd1: led[11:8] = 4'b0001;
                3'd2: led[11:8] = 4'b0011;
                3'd3: led[11:8] = 4'b0111;
                3'd4: led[11:8] = 4'b1111;
                default: led[11:8] = 4'b0000;
            endcase
    
            // Oyuncu 4
            case(score_p4)
                3'd0: led[15:12] = 4'b0000;
                3'd1: led[15:12] = 4'b0001;
                3'd2: led[15:12] = 4'b0011;
                3'd3: led[15:12] = 4'b0111;
                3'd4: led[15:12] = 4'b1111;
                default: led[15:12] = 4'b0000;
            endcase
        end
    end
endmodule