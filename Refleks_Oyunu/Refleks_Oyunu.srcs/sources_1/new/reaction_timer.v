`timescale 1ns / 1ps

module reaction_timer(

    input clk,
    input rst,
    input start, // FSM
    input active_p1, // Aktif oyuncu 1
    input active_p2, // Aktif oyuncu 2
    input active_p3, // Aktif oyuncu 3
    input active_p4, // Aktif oyuncu 4

    // Buton pulse giri?leri
    input p1_btn,
    input p2_btn,
    input p3_btn,
    input p4_btn,

    // Reaksiyon s?releri (ms)
    output reg [12:0] p1_time,
    output reg [12:0] p2_time,
    output reg [12:0] p3_time,
    output reg [12:0] p4_time,

    // Timeout bilgileri
    output reg p1_timeout,
    output reg p2_timeout,
    output reg p3_timeout,
    output reg p4_timeout,

    // ?l??m tamamland?
    output reg done

);
// 100 MHz -> 1 ms
localparam CLK_PER_MS = 100000;
localparam MAX_TIME   = 5000;

reg [16:0] clk_counter;
reg [12:0] ms_counter;
reg running;
reg p1_recorded;
reg p2_recorded;
reg p3_recorded;
reg p4_recorded;

reg active1_s, active2_s, active3_s, active4_s;

always @(posedge clk) begin

if(rst) begin
    clk_counter <= 0;
    ms_counter <= 0;
    running <= 0;
    done <= 0;
    p1_time <= 0;
    p2_time <= 0;
    p3_time <= 0;
    p4_time <= 0;
    p1_timeout <= 0;
    p2_timeout <= 0;
    p3_timeout <= 0;
    p4_timeout <= 0;
    p1_recorded <= 0;
    p2_recorded <= 0;
    p3_recorded <= 0;
    p4_recorded <= 0;
    active1_s <= 0;
    active2_s <= 0;
    active3_s <= 0;
    active4_s <= 0;
end
else begin

    if(start && !running) begin
        running <= 1;
        done <= 0;
        clk_counter <= 0;
        ms_counter <= 0;
        p1_time <= 0;
        p2_time <= 0;
        p3_time <= 0;
        p4_time <= 0;
        p1_timeout <= 0;
        p2_timeout <= 0;
        p3_timeout <= 0;
        p4_timeout <= 0;
        p1_recorded <= 0;
        p2_recorded <= 0;
        p3_recorded <= 0;
        p4_recorded <= 0;
        // latch which players are active for this round
        active1_s <= active_p1;
        active2_s <= active_p2;
        active3_s <= active_p3;
        active4_s <= active_p4;
    end
        
    if(running) begin
        if(clk_counter == CLK_PER_MS-1) begin
            clk_counter <= 0;
            ms_counter <= ms_counter + 1;
        end
        else
            clk_counter <= clk_counter + 1;

        // latchlenmis sinyalleri kullaniyoruz yoksa bug oluyor
        if(active1_s && !p1_recorded && p1_btn) begin // Oyuncu 1
            p1_recorded <= 1;
            p1_time <= ms_counter;
        end

        if(active2_s && !p2_recorded && p2_btn) begin // Oyuncu 2
            p2_recorded <= 1;
            p2_time <= ms_counter;
        end

        if(active3_s && !p3_recorded && p3_btn) begin // Oyuncu 3
            p3_recorded <= 1;
            p3_time <= ms_counter;
        end

        if(active4_s && !p4_recorded && p4_btn) begin // Oyuncu 4
            p4_recorded <= 1;
            p4_time <= ms_counter;
        end

        if(
            ((!active1_s)||p1_recorded) &&
            ((!active2_s)||p2_recorded) &&
            ((!active3_s)||p3_recorded) &&
            ((!active4_s)||p4_recorded)
        )
        begin
            running <= 0;
            done <= 1;
        end

        if(ms_counter >= MAX_TIME) begin

            running <= 0;
            done <= 1;

            if(active1_s && !p1_recorded)
                p1_timeout <= 1;

            if(active2_s && !p2_recorded)
                p2_timeout <= 1;

            if(active3_s && !p3_recorded)
                p3_timeout <= 1;

            if(active4_s && !p4_recorded)
                p4_timeout <= 1;
        end
    end
    else begin
        done <= 0;
    end
end
end
endmodule