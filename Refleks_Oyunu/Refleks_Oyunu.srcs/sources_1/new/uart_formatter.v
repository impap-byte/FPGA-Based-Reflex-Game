`timescale 1ns / 1ps

module uart_formatter(
    input clk,
    input rst,

    input        start_print,   // game_fsm.uart_start (1 cycle pulse)
    input [3:0]  round_num,     // round_count (0-tabanli)
    input [1:0]  player_count,  // 00->2, 01->3, 10->4 oyuncu

    input [12:0] p1_time, p2_time, p3_time, p4_time,
    input [2:0]  p1_score, p2_score, p3_score, p4_score,
    input [6:0]  p1_total, p2_total, p3_total, p4_total,
    input        p1_fs, p2_fs, p3_fs, p4_fs,
    input        p1_to, p2_to, p3_to, p4_to,
    input        p1_active, p2_active, p3_active, p4_active,

    output reg        tx_start,
    output reg [7:0]  tx_data,
    input             tx_done,

    output reg        print_done
);

    localparam STATE_IDLE      = 3'd0;
    localparam STATE_PREPARE   = 3'd1;
    localparam STATE_SEND_CHAR = 3'd2;
    localparam STATE_WAIT_DONE = 3'd3;
    localparam STATE_NEXT_CHAR = 3'd4;

    reg [2:0] state;

    // En fazla 4 oyuncu icin: 10 (header) + 4*21 (oyuncu blogu) = 94 bayt
    reg [7:0] msg_buffer [0:99];
    reg [6:0] char_index;
    reg [6:0] msg_length;
    wire [4:0] round_no = round_num + 1;

    always @(posedge clk) begin
        if (rst) begin
            state      <= STATE_IDLE;
            tx_start   <= 1'b0;
            tx_data    <= 8'h00;
            char_index <= 7'd0;
            msg_length <= 7'd0;
            print_done <= 1'b0;
        end else begin
            print_done <= 1'b0; // varsayilan pasif
            tx_start   <= 1'b0; // varsayilan pasif

            case (state)

                STATE_IDLE: begin
                    if (start_print) begin
                        state <= STATE_PREPARE;
                    end
                end
                STATE_PREPARE: begin
                    msg_buffer[0] <= 8'h0D; // \r
                    msg_buffer[1] <= 8'h0A; // \n
                    msg_buffer[2] <= "T";
                    msg_buffer[3] <= "U";
                    msg_buffer[4] <= "R";
                    msg_buffer[5] <= " ";
                    msg_buffer[6] <= 8'd48 + (round_no / 10);
                    msg_buffer[7] <= 8'd48 + (round_no % 10);
                    msg_buffer[8] <= 8'h0D;
                    msg_buffer[9] <= 8'h0A;

                    // Oyuncu 1: index 10-30, 21 bayt
                    msg_buffer[10] <= "P";
                    msg_buffer[11] <= "1";
                    msg_buffer[12] <= ":";
                    if (!p1_active) begin
                        msg_buffer[13] <= "N"; msg_buffer[14] <= "/"; msg_buffer[15] <= "A";
                        msg_buffer[16] <= " "; msg_buffer[17] <= " "; msg_buffer[18] <= " ";
                    end else if (p1_fs) begin
                        msg_buffer[13] <= "F"; msg_buffer[14] <= "S"; msg_buffer[15] <= " ";
                        msg_buffer[16] <= " "; msg_buffer[17] <= " "; msg_buffer[18] <= " ";
                    end else if (p1_to) begin
                        msg_buffer[13] <= "T"; msg_buffer[14] <= "O"; msg_buffer[15] <= " ";
                        msg_buffer[16] <= " "; msg_buffer[17] <= " "; msg_buffer[18] <= " ";
                    end else begin
                        msg_buffer[13] <= 8'd48 + ((p1_time / 1000) % 10);
                        msg_buffer[14] <= 8'd48 + ((p1_time / 100)  % 10);
                        msg_buffer[15] <= 8'd48 + ((p1_time / 10)   % 10);
                        msg_buffer[16] <= 8'd48 + (p1_time % 10);
                        msg_buffer[17] <= "m";
                        msg_buffer[18] <= "s";
                    end
                    msg_buffer[19] <= " ";
                    msg_buffer[20] <= "S";
                    msg_buffer[21] <= ":";
                    msg_buffer[22] <= 8'd48 + p1_score;
                    msg_buffer[23] <= " ";
                    msg_buffer[24] <= "T";
                    msg_buffer[25] <= ":";
                    msg_buffer[26] <= 8'd48 + ((p1_total / 100) % 10);
                    msg_buffer[27] <= 8'd48 + ((p1_total / 10)  % 10);
                    msg_buffer[28] <= 8'd48 + (p1_total % 10);
                    msg_buffer[29] <= 8'h0D;
                    msg_buffer[30] <= 8'h0A;

                    // Oyuncu 2: index 31-51
                    msg_buffer[31] <= "P";
                    msg_buffer[32] <= "2";
                    msg_buffer[33] <= ":";
                    if (!p2_active) begin
                        msg_buffer[34] <= "N"; msg_buffer[35] <= "/"; msg_buffer[36] <= "A";
                        msg_buffer[37] <= " "; msg_buffer[38] <= " "; msg_buffer[39] <= " ";
                    end else if (p2_fs) begin
                        msg_buffer[34] <= "F"; msg_buffer[35] <= "S"; msg_buffer[36] <= " ";
                        msg_buffer[37] <= " "; msg_buffer[38] <= " "; msg_buffer[39] <= " ";
                    end else if (p2_to) begin
                        msg_buffer[34] <= "T"; msg_buffer[35] <= "O"; msg_buffer[36] <= " ";
                        msg_buffer[37] <= " "; msg_buffer[38] <= " "; msg_buffer[39] <= " ";
                    end else begin
                        msg_buffer[34] <= 8'd48 + ((p2_time / 1000) % 10);
                        msg_buffer[35] <= 8'd48 + ((p2_time / 100)  % 10);
                        msg_buffer[36] <= 8'd48 + ((p2_time / 10)   % 10);
                        msg_buffer[37] <= 8'd48 + (p2_time % 10);
                        msg_buffer[38] <= "m";
                        msg_buffer[39] <= "s";
                    end
                    msg_buffer[40] <= " ";
                    msg_buffer[41] <= "S";
                    msg_buffer[42] <= ":";
                    msg_buffer[43] <= 8'd48 + p2_score;
                    msg_buffer[44] <= " ";
                    msg_buffer[45] <= "T";
                    msg_buffer[46] <= ":";
                    msg_buffer[47] <= 8'd48 + ((p2_total / 100) % 10);
                    msg_buffer[48] <= 8'd48 + ((p2_total / 10)  % 10);
                    msg_buffer[49] <= 8'd48 + (p2_total % 10);
                    msg_buffer[50] <= 8'h0D;
                    msg_buffer[51] <= 8'h0A;

                    // Oyuncu 3 index 52-72
                    msg_buffer[52] <= "P";
                    msg_buffer[53] <= "3";
                    msg_buffer[54] <= ":";
                    if (!p3_active) begin
                        msg_buffer[55] <= "N"; msg_buffer[56] <= "/"; msg_buffer[57] <= "A";
                        msg_buffer[58] <= " "; msg_buffer[59] <= " "; msg_buffer[60] <= " ";
                    end else if (p3_fs) begin
                        msg_buffer[55] <= "F"; msg_buffer[56] <= "S"; msg_buffer[57] <= " ";
                        msg_buffer[58] <= " "; msg_buffer[59] <= " "; msg_buffer[60] <= " ";
                    end else if (p3_to) begin
                        msg_buffer[55] <= "T"; msg_buffer[56] <= "O"; msg_buffer[57] <= " ";
                        msg_buffer[58] <= " "; msg_buffer[59] <= " "; msg_buffer[60] <= " ";
                    end else begin
                        msg_buffer[55] <= 8'd48 + ((p3_time / 1000) % 10);
                        msg_buffer[56] <= 8'd48 + ((p3_time / 100)  % 10);
                        msg_buffer[57] <= 8'd48 + ((p3_time / 10)   % 10);
                        msg_buffer[58] <= 8'd48 + (p3_time % 10);
                        msg_buffer[59] <= "m";
                        msg_buffer[60] <= "s";
                    end
                    msg_buffer[61] <= " ";
                    msg_buffer[62] <= "S";
                    msg_buffer[63] <= ":";
                    msg_buffer[64] <= 8'd48 + p3_score;
                    msg_buffer[65] <= " ";
                    msg_buffer[66] <= "T";
                    msg_buffer[67] <= ":";
                    msg_buffer[68] <= 8'd48 + ((p3_total / 100) % 10);
                    msg_buffer[69] <= 8'd48 + ((p3_total / 10)  % 10);
                    msg_buffer[70] <= 8'd48 + (p3_total % 10);
                    msg_buffer[71] <= 8'h0D;
                    msg_buffer[72] <= 8'h0A;

                    // Oyuncu 4: index 73-93
                    msg_buffer[73] <= "P";
                    msg_buffer[74] <= "4";
                    msg_buffer[75] <= ":";
                    if (!p4_active) begin
                        msg_buffer[76] <= "N"; msg_buffer[77] <= "/"; msg_buffer[78] <= "A";
                        msg_buffer[79] <= " "; msg_buffer[80] <= " "; msg_buffer[81] <= " ";
                    end else if (p4_fs) begin
                        msg_buffer[76] <= "F"; msg_buffer[77] <= "S"; msg_buffer[78] <= " ";
                        msg_buffer[79] <= " "; msg_buffer[80] <= " "; msg_buffer[81] <= " ";
                    end else if (p4_to) begin
                        msg_buffer[76] <= "T"; msg_buffer[77] <= "O"; msg_buffer[78] <= " ";
                        msg_buffer[79] <= " "; msg_buffer[80] <= " "; msg_buffer[81] <= " ";
                    end else begin
                        msg_buffer[76] <= 8'd48 + ((p4_time / 1000) % 10);
                        msg_buffer[77] <= 8'd48 + ((p4_time / 100)  % 10);
                        msg_buffer[78] <= 8'd48 + ((p4_time / 10)   % 10);
                        msg_buffer[79] <= 8'd48 + (p4_time % 10);
                        msg_buffer[80] <= "m";
                        msg_buffer[81] <= "s";
                    end
                    msg_buffer[82] <= " ";
                    msg_buffer[83] <= "S";
                    msg_buffer[84] <= ":";
                    msg_buffer[85] <= 8'd48 + p4_score;
                    msg_buffer[86] <= " ";
                    msg_buffer[87] <= "T";
                    msg_buffer[88] <= ":";
                    msg_buffer[89] <= 8'd48 + ((p4_total / 100) % 10);
                    msg_buffer[90] <= 8'd48 + ((p4_total / 10)  % 10);
                    msg_buffer[91] <= 8'd48 + (p4_total % 10);
                    msg_buffer[92] <= 8'h0D;
                    msg_buffer[93] <= 8'h0A;

                    case (player_count)
                        2'b00:   msg_length <= 7'd52; // 2 oyuncu: 10 + 21 + 21
                        2'b01:   msg_length <= 7'd73; // 3 oyuncu: 10 + 21*3
                        default: msg_length <= 7'd94; // 4 oyuncu: 10 + 21*4
                    endcase

                    char_index <= 7'd0;
                    state      <= STATE_SEND_CHAR;
                end
                
                STATE_SEND_CHAR: begin
                    tx_data  <= msg_buffer[char_index];
                    tx_start <= 1'b1; 
                    state    <= STATE_WAIT_DONE;
                end
                
                STATE_WAIT_DONE: begin
                    // uart_tx'in tx_done pulse'i bekleniyor
                    if (tx_done) begin
                        state <= STATE_NEXT_CHAR;
                    end
                end
                
                STATE_NEXT_CHAR: begin
                    if (char_index == msg_length - 1) begin
                        print_done <= 1'b1; 
                        state      <= STATE_IDLE;
                    end else begin
                        char_index <= char_index + 1'b1;
                        state      <= STATE_SEND_CHAR;
                    end
                end

                default: state <= STATE_IDLE;
            endcase
        end
    end
endmodule