`timescale 1ns / 1ps

module score_manager (
    input clk,
    input rst,
    input calc_enable,

    input [12:0] rt_p1,
    input [12:0] rt_p2,
    input [12:0] rt_p3,
    input [12:0] rt_p4,

    input fs_p1, fs_p2, fs_p3, fs_p4,              
    input to_p1, to_p2, to_p3, to_p4,              
    input active_p1, active_p2, active_p3, active_p4, 

    output [6:0] total_score_p1,
    output [6:0] total_score_p2,
    output [6:0] total_score_p3,
    output [6:0] total_score_p4,

    output reg [1:0] rank_p1,
    output reg [1:0] rank_p2,
    output reg [1:0] rank_p3,
    output reg [1:0] rank_p4,
    
    output reg [2:0] score_p1,
    output reg [2:0] score_p2,
    output reg [2:0] score_p3,
    output reg [2:0] score_p4,
    
    output reg [1:0] f_rank_p1,
    output reg [1:0] f_rank_p2,
    output reg [1:0] f_rank_p3,
    output reg [1:0] f_rank_p4
    
);

    reg new_calculation = 0;
    always @(*) begin
        f_rank_p1 = 2'd0;
        if (active_p2 && (total_score_p2 > total_score_p1)) f_rank_p1 = f_rank_p1 + 1'b1;
        if (active_p3 && (total_score_p3 > total_score_p1) ) f_rank_p1 = f_rank_p1 + 1'b1;
        if (active_p4 && (total_score_p4 > total_score_p1)) f_rank_p1 = f_rank_p1 + 1'b1;

        // P2 Final Rank
        f_rank_p2 = 2'd0;
        if (active_p1 && (total_score_p1 > total_score_p2)) f_rank_p2 = f_rank_p2 + 1'b1;
        if (active_p3 && (total_score_p3 > total_score_p2)) f_rank_p2 = f_rank_p2 + 1'b1;
        if (active_p4 && (total_score_p4 > total_score_p2 )) f_rank_p2 = f_rank_p2 + 1'b1;

        // P3 Final Rank
        f_rank_p3 = 2'd0;
        if (active_p1 && (total_score_p1 > total_score_p3)) f_rank_p3 = f_rank_p3 + 1'b1;
        if (active_p2 && (total_score_p2 > total_score_p3)) f_rank_p3 = f_rank_p3 + 1'b1;
        if (active_p4 && (total_score_p4 > total_score_p3)) f_rank_p3 = f_rank_p3 + 1'b1;

        // P4 Final Rank
        f_rank_p4 = 2'd0;
        if (active_p1 && (total_score_p1 >  total_score_p4 )) f_rank_p4 = f_rank_p4 + 1'b1;
        if (active_p2 && (total_score_p2 > total_score_p4)) f_rank_p4 = f_rank_p4 + 1'b1;
        if (active_p3 && (total_score_p3 > total_score_p4)) f_rank_p4 = f_rank_p4 + 1'b1;
    end
    
    always @(*) begin
        // P1
        rank_p1 = 2'd0;
        if (active_p2 && (rt_p2 < rt_p1)) rank_p1 = rank_p1 + 1'b1;
        if (active_p3 && (rt_p3 < rt_p1)) rank_p1 = rank_p1 + 1'b1;
        if (active_p4 && (rt_p4 < rt_p1)) rank_p1 = rank_p1 + 1'b1;

        // P2
        rank_p2 = 2'd0;
        if (active_p1 && (rt_p1 < rt_p2)) rank_p2 = rank_p2 + 1'b1;
        if (active_p3 && (rt_p3 < rt_p2)) rank_p2 = rank_p2 + 1'b1;
        if (active_p4 && (rt_p4 < rt_p2)) rank_p2 = rank_p2 + 1'b1;

        // P3
        rank_p3 = 2'd0;
        if (active_p1 && (rt_p1 < rt_p3)) rank_p3 = rank_p3 + 1'b1;
        if (active_p2 && (rt_p2 < rt_p3)) rank_p3 = rank_p3 + 1'b1;
        if (active_p4 && (rt_p4 < rt_p3)) rank_p3 = rank_p3 + 1'b1;

        // P4
        rank_p4 = 2'd0;
        if (active_p1 && (rt_p1 < rt_p4)) rank_p4 = rank_p4 + 1'b1;
        if (active_p2 && (rt_p2 < rt_p4)) rank_p4 = rank_p4 + 1'b1;
        if (active_p3 && (rt_p3 < rt_p4)) rank_p4 = rank_p4 + 1'b1;
        
        
    end


    always @(posedge clk) begin
        if (rst) begin
            score_p1 <= 3'd0;
            score_p2 <= 3'd0;
            score_p3 <= 3'd0;
            score_p4 <= 3'd0;
            new_calculation <= 0;
        end else begin
            new_calculation <= 0;
            
            if (calc_enable) begin
                if (fs_p1 || to_p1 || !active_p1) score_p1 <= 3'd0;
                else score_p1 <= 3'd4 - rank_p1;

                if (fs_p2 || to_p2 || !active_p2) score_p2 <= 3'd0;
                else score_p2 <= 3'd4 - rank_p2;

                if (fs_p3 || to_p3 || !active_p3) score_p3 <= 3'd0;
                else score_p3 <= 3'd4 - rank_p3;

                if (fs_p4 || to_p4 || !active_p4) score_p4 <= 3'd0;
                else score_p4 <= 3'd4 - rank_p4;
                
                new_calculation <= 1'b1;
            end
        end
    end

    total_score_manager tsm(
       .clk(clk),
       .rst(rst),
       .new_score_arrived(new_calculation),
       .score_p1(score_p1),
       .score_p2(score_p2),
       .score_p3(score_p3),
       .score_p4(score_p4),
       .total1(total_score_p1),
       .total2(total_score_p2),
       .total3(total_score_p3),
       .total4(total_score_p4)
    );
endmodule