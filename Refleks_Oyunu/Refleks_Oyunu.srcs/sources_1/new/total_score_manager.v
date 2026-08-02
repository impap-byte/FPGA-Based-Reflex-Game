`timescale 1ns / 1ps


module total_score_manager(
    input clk,
    input rst,
    input new_score_arrived,
    input [2:0] score_p1,
    input [2:0] score_p2,
    input [2:0] score_p3,
    input [2:0] score_p4,
    output [6:0] total1,
    output [6:0] total2,
    output [6:0] total3,
    output [6:0] total4
    
    );
    
    reg [6:0] p1_points, p2_points, p3_points, p4_points;
    reg [6:0] p1_points_n, p2_points_n, p3_points_n, p4_points_n;
    always @* begin
        p1_points_n = p1_points;
        p2_points_n = p2_points;
        p3_points_n = p3_points;
        p4_points_n = p4_points;
        if(new_score_arrived) begin
            p1_points_n = p1_points + score_p1;
            p2_points_n = p2_points + score_p2;
            p3_points_n = p3_points + score_p3;
            p4_points_n = p4_points + score_p4;
        end
    end
    
    always @(posedge clk) begin
        if(rst) begin
            p1_points <= 0;
            p2_points <= 0;
            p3_points <= 0;
            p4_points <= 0;
        end
        else begin
            p1_points <= p1_points_n;
            p2_points <= p2_points_n;
            p3_points <= p3_points_n;
            p4_points <= p4_points_n;
        end
    end
endmodule
