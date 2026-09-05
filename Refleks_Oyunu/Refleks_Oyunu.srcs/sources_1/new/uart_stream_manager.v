`timescale 1ns / 1ps

module uart_stream_manager(
    input clk,
    input rst,

    input        start_print,
    input          game_over,  
    input [3:0]    round_num,     // round_count (0-tabanli)
    input [1:0]  player_count,  // 00->2, 01->3, 10->4 oyuncu

    input [12:0] p1_time, p2_time, p3_time, p4_time,
    input [2:0]  p1_score, p2_score, p3_score, p4_score,
    input [6:0]  p1_total, p2_total, p3_total, p4_total,
    
    // Final rankings from score_manager (0 is 1st place)
    input [1:0]  f_rank_p1, f_rank_p2, f_rank_p3, f_rank_p4, 
    
    input  p1_fs, p2_fs, p3_fs, p4_fs,
    input  p1_to, p2_to, p3_to, p4_to,
    input  p1_active, p2_active, p3_active, p4_active,

    output reg print_done,
    output tx
);
    reg tx_start;
    wire tx_done;
    reg [7:0] tx_data;

    wire [15:0] p1_time_bcd, p2_time_bcd, p3_time_bcd, p4_time_bcd;
    wire [15:0] p1_total_bcd, p2_total_bcd, p3_total_bcd, p4_total_bcd;
    
    bcd_converter conv_t1 (p1_time, p1_time_bcd);
    bcd_converter conv_t2 (p2_time, p2_time_bcd);
    
    bcd_converter conv_t3 (p3_time, p3_time_bcd);
    bcd_converter conv_t4 (p4_time, p4_time_bcd);
    
    bcd_converter conv_s1 ({6'd0, p1_total}, p1_total_bcd);
    bcd_converter conv_s2 ({6'd0, p2_total}, p2_total_bcd);
    bcd_converter conv_s3 ({6'd0, p3_total}, p3_total_bcd);
    bcd_converter conv_s4 ({6'd0, p4_total}, p4_total_bcd);

    wire [2:0] winner_count = ((f_rank_p1 == 2'd0 && p1_active) ? 1 : 0) +
                              ((f_rank_p2 == 2'd0 && p2_active) ? 1 : 0) +
                              ((f_rank_p3 == 2'd0 && p3_active) ? 1 : 0) +
                              ((f_rank_p4 == 2'd0 && p4_active) ? 1 : 0);
                              
    wire p1_lost = !p1_active || p1_fs || p1_to;
    wire p2_lost = !p2_active || p2_fs || p2_to;
    wire p3_lost = !p3_active || p3_fs || p3_to;
    wire p4_lost = !p4_active || p4_fs || p4_to;
    // "herkes kaybetti"nin tanimi kac kisininin oynadigine gore degisiyor
    wire all_players_lost = (player_count == 2'b00) ? (p1_lost && p2_lost) :
                           (player_count == 2'b01) ? (p1_lost && p2_lost && p3_lost) :
                                                     (p1_lost && p2_lost && p3_lost && p4_lost);
    wire draw = (winner_count > 1) || all_players_lost;

    localparam IDLE      = 2'b00;
    localparam SENDCHAR  = 2'b01;
    localparam WAIT_DONE = 2'b10;
    
    reg [1:0] state;
    reg [6:0] char_index;
    reg [6:0] msg_length;
    

    reg [7:0] round_char;
    reg [7:0] end_char;
    wire [7:0] current_char = game_over ? end_char : round_char;

    always @* begin
        case(char_index)

            7'd0:  round_char = 8'h0D; // \r
            7'd1:  round_char = 8'h0A; // \n
            7'd2:  round_char = "T";
            7'd3:  round_char = "U";
            7'd4:  round_char = "R";
            7'd5:  round_char = " ";
            7'd6:  round_char = "0" + ((round_num + 1) / 10); 
            7'd7:  round_char = "0" + ((round_num + 1) % 10);
            7'd8:  round_char = 8'h0D;
            7'd9:  round_char = 8'h0A;

            // Player 1 
            7'd10: round_char = "P";
            7'd11: round_char = "1";
            7'd12: round_char = ":";
            7'd13: begin 
                if      (!p1_active) round_char = "N";
                else if (p1_fs)      round_char = "F";
                else if (p1_to)      round_char = "T";
                else                 round_char = "0" + p1_time_bcd[15:12];
            end
            7'd14: begin 
                if      (!p1_active) round_char = "/";
                else if (p1_fs)      round_char = "S";
                else if (p1_to)      round_char = "O";
                else                 round_char = "0" + p1_time_bcd[11:8];
            end
            7'd15: begin 
                if      (!p1_active) round_char = "A";
                else if (p1_fs || p1_to) round_char = " ";
                else                 round_char = "0" + p1_time_bcd[7:4];
            end
            7'd16: begin 
                if (!p1_active || p1_fs || p1_to) round_char = " ";
                else                              round_char = "0" + p1_time_bcd[3:0];
            end
            7'd17: begin 
                if (!p1_active || p1_fs || p1_to) round_char = " ";
                else                              round_char = "m";
            end
            7'd18: begin 
                if (!p1_active || p1_fs || p1_to) round_char = " ";
                else                              round_char = "s";
            end
            7'd19: round_char = " ";
            7'd20: round_char = "S";
            7'd21: round_char = ":";
            7'd22: round_char = "0" + p1_score; 
            7'd23: round_char = " ";
            7'd24: round_char = "T";
            7'd25: round_char = ":";
            7'd26: round_char = "0" + p1_total_bcd[11:8]; 
            7'd27: round_char = "0" + p1_total_bcd[7:4];  
            7'd28: round_char = "0" + p1_total_bcd[3:0];  
            7'd29: round_char = 8'h0D;
            7'd30: round_char = 8'h0A;

            // Player 2
            7'd31: round_char = "P";
            7'd32: round_char = "2";
            7'd33: round_char = ":";
            7'd34: begin 
                if      (!p2_active) round_char = "N";
                
                else if (p2_fs)      round_char = "F";
                else if (p2_to)      round_char = "T";
                else                 round_char = "0" + p2_time_bcd[15:12];
            end
            7'd35: begin 
                if      (!p2_active) round_char = "/";
                else if (p2_fs)      round_char = "S";
                else if (p2_to)      round_char = "O";
                else                 round_char = "0" + p2_time_bcd[11:8];
            end
            7'd36: begin 
                if      (!p2_active) round_char = "A";
                else if (p2_fs || p2_to) round_char = " ";
                else                 round_char = "0" + p2_time_bcd[7:4];
            end
            7'd37: begin 
                if (!p2_active || p2_fs || p2_to) round_char = " ";
                else                              round_char = "0" + p2_time_bcd[3:0];
            end
            7'd38: begin 
                if (!p2_active || p2_fs || p2_to) round_char = " ";
                else                              round_char = "m";
            end
            7'd39: begin 
                if (!p2_active || p2_fs || p2_to) round_char = " ";
                else                              round_char = "s";
            end
            7'd40: round_char = " ";
            7'd41: round_char = "S";
            7'd42: round_char = ":";
            7'd43: round_char = "0" + p2_score;
            7'd44: round_char = " ";
            
            7'd45: round_char = "T";
            7'd46: round_char = ":";
            7'd47: round_char = "0" + p2_total_bcd[11:8];
            7'd48: round_char = "0" + p2_total_bcd[7:4];
            7'd49: round_char = "0" + p2_total_bcd[3:0];
            7'd50: round_char = 8'h0D;
            7'd51: round_char = 8'h0A;

            // Player 3
            7'd52: round_char = "P";
            7'd53: round_char = "3";
            7'd54: round_char = ":";
            7'd55: begin 
                if      (!p3_active) round_char = "N";
                else if (p3_fs)      round_char = "F";
                else if (p3_to)      round_char = "T";
                else                 round_char = "0" + p3_time_bcd[15:12];
            end
            7'd56: begin 
                if      (!p3_active) round_char = "/";
                else if (p3_fs)      round_char = "S";
                else if (p3_to)      round_char = "O";
                else                 round_char = "0" + p3_time_bcd[11:8];
            end
            7'd57: begin 
                if      (!p3_active) round_char = "A";
                else if (p3_fs || p3_to) round_char = " ";
                else                 round_char = "0" + p3_time_bcd[7:4];
            end
            7'd58: begin 
                if (!p3_active || p3_fs || p3_to) round_char = " ";
                else                              round_char = "0" + p3_time_bcd[3:0];
            end
            7'd59: begin 
                if (!p3_active || p3_fs || p3_to) round_char = " ";
                else                              round_char = "m";
            end
            7'd60: begin 
                if (!p3_active || p3_fs || p3_to) round_char = " ";
                else                              round_char = "s";
            end
            7'd61: round_char = " ";
            7'd62: round_char = "S";
            7'd63: round_char = ":";
            7'd64: round_char = "0" + p3_score;
            7'd65: round_char = " ";
            7'd66: round_char = "T";
            7'd67: round_char = ":";
            7'd68: round_char = "0" + p3_total_bcd[11:8];
            7'd69: round_char = "0" + p3_total_bcd[7:4];
            7'd70: round_char = "0" + p3_total_bcd[3:0];
            7'd71: round_char = 8'h0D;
            7'd72: round_char = 8'h0A;

            // Player 4
            7'd73: round_char = "P";
            7'd74: round_char = "4";
            7'd75: round_char = ":";
            7'd76: begin 
                if      (!p4_active) round_char = "N";
                else if (p4_fs)      round_char = "F";
                else if (p4_to)      round_char = "T";
                else                 round_char = "0" + p4_time_bcd[15:12];
            end
            7'd77: begin 
                if      (!p4_active) round_char = "/";
                else if (p4_fs)      round_char = "S";
                else if (p4_to)      round_char = "O";
                else                 round_char = "0" + p4_time_bcd[11:8];
            end
            7'd78: begin 
                if      (!p4_active) round_char = "A";
                else if (p4_fs || p4_to) round_char = " ";
                else                 round_char = "0" + p4_time_bcd[7:4];
            end
            7'd79: begin 
                if (!p4_active || p4_fs || p4_to) round_char = " ";
                else                              round_char = "0" + p4_time_bcd[3:0];
            end
            7'd80: begin 
                if (!p4_active || p4_fs || p4_to) round_char = " ";
                else                              round_char = "m";
            end
            7'd81: begin 
                if (!p4_active || p4_fs || p4_to) round_char = " ";
                else                              round_char = "s";
            end
            7'd82: round_char = " ";
            7'd83: round_char = "S";
            7'd84: round_char = ":";
            7'd85: round_char = "0" + p4_score;
            7'd86: round_char = " ";
            7'd87: round_char = "T";
            7'd88: round_char = ":";
            7'd89: round_char = "0" + p4_total_bcd[11:8];
            7'd90: round_char = "0" + p4_total_bcd[7:4];
            7'd91: round_char = "0" + p4_total_bcd[3:0];
            7'd92: round_char = 8'h0D;
            7'd93: round_char = 8'h0A;
            
            default: round_char = " ";
        endcase
    end

    // game over
    always @* begin
        case(char_index)
            7'd0:  end_char = 8'h0D;
            7'd1:  end_char = 8'h0A;
            7'd2:  end_char = "W";
            7'd3:  end_char = "I";
            7'd4:  end_char = "N";
            7'd5:  end_char = "N";
            7'd6:  end_char = "E";
            7'd7:  end_char = "R";
            7'd8:  end_char = "S";
            7'd9:  end_char = ":";
            7'd10: end_char = " ";
            
            7'd11: end_char = (f_rank_p1 == 2'd0 && p1_active) ? "1" : " ";
            7'd12: end_char = " ";
            7'd13: end_char = (f_rank_p2 == 2'd0 && p2_active) ? "2" : " ";
            7'd14: end_char = " ";
            7'd15: end_char = (f_rank_p3 == 2'd0 && p3_active) ? "3" : " ";
            7'd16: end_char = " ";
            7'd17: end_char = (f_rank_p4 == 2'd0 && p4_active) ? "4" : " ";
            
            7'd18: end_char = 8'h20;
            7'd19: end_char = 8'h20;
            // If there's a draw, print "DRAW"
            // When there is no draw, these extra characters are blank.
            7'd20: end_char = draw ? "D" : " ";
            7'd21: end_char = draw ? "R" : " ";
            7'd22: end_char = draw ? "A" : " ";
            7'd23: end_char = draw ? "W" : " ";
            7'd24: end_char = draw ? 8'h0D : 8'h20;
            7'd25: end_char = draw ? 8'h0A : 8'h20;

            default: end_char = " ";
        endcase
    end

    always @(posedge clk) begin
        if (rst) begin
            state      <= IDLE;
            tx_start   <= 1'b0;
            char_index <= 7'd0;
            
            msg_length <= 7'd0;
            print_done <= 1'b0;
        end else begin
            print_done <= 1'b0;
            
            tx_start   <= 1'b0;
            
            case(state)
                IDLE: begin
                    if(start_print == 1'b1) begin
                        if (game_over) begin
                            if (draw) msg_length <= 7'd26; else msg_length <= 7'd20;
                        end else begin
                            if(player_count == 2'b00) begin
                                msg_length <= 7'd52;
                            end
                            else if(player_count == 2'b01) begin
                                msg_length <= 7'd73; 
                            end
                            else msg_length <= 7'd94;
                        end
                        char_index <= 7'd0;
                        state      <= SENDCHAR;
                    end
                end
                SENDCHAR: begin
                    tx_data  <= current_char; 
                    tx_start <= 1'b1;
                    state    <= WAIT_DONE;
                end
                WAIT_DONE: begin
                    if (tx_done) begin
                        if (char_index == msg_length - 1) begin
                            print_done <= 1'b1;
                            state      <= IDLE;
                        end else begin
                            char_index <= char_index + 1'b1;
                            state      <= SENDCHAR;
                        end
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end
    uart_tx uart(
        .clk(clk),
        .reset(rst),
        .tx_start(tx_start),
        .data_in(tx_data),
        .tx(tx),
        .tx_done(tx_done)
    );
endmodule