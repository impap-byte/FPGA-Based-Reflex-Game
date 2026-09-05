`timescale 1ns / 1ps

module button_manager(

    input clk,
    input rst,

// Ham buton girişleri
    input btn_u,
    input btn_l,
    input btn_r,
    input btn_d,

// 2,3 veya 4 oyuncu
    input [1:0] player_count,

// Her oyuncu için tek clockluk pulse
    output player1_pulse,
    output player2_pulse,
    output player3_pulse,
    output player4_pulse

);


 // Debounce çıkışları


    wire p1_db;
    wire p2_db;
    wire p3_db;
    wire p4_db;

// Edge detector çıkışları

    wire p1_edge;
    wire p2_edge;
    wire p3_edge;
    wire p4_edge;

    // Debounce Modülleri

    button_debounce db_p1(
        .clk(clk),
        .rst(rst),
        .btn_in(btn_u),
        .btn_debounced(p1_db)
    );

    button_debounce db_p2(
        .clk(clk),
        .rst(rst),
        .btn_in(btn_l),
        .btn_debounced(p2_db)
    );

    button_debounce db_p3(
        .clk(clk),
        .rst(rst),
        .btn_in(btn_r),
        .btn_debounced(p3_db)
    );

    button_debounce db_p4(
        .clk(clk),
        .rst(rst),
        .btn_in(btn_d),
        .btn_debounced(p4_db)
    );

 // Edge Detectorlar

    edge_detector ed_p1(
        .clk(clk),
        .rst(rst),
        .in_signal(p1_db),
        .pulse_out(p1_edge)
    );

    edge_detector ed_p2(
        .clk(clk),
        .rst(rst),
        .in_signal(p2_db),
        .pulse_out(p2_edge)
    );

    edge_detector ed_p3(
        .clk(clk),
        .rst(rst),
        .in_signal(p3_db),
        .pulse_out(p3_edge)
    );

    edge_detector ed_p4(
        .clk(clk),
        .rst(rst),
        .in_signal(p4_db),
        .pulse_out(p4_edge)
    );



 // player_count:
 // 00 -> 2 oyuncu
 // 01 -> 3 oyuncu
 // 10 -> 4 oyuncu


    assign player1_pulse = p1_edge;

    assign player2_pulse = p2_edge;

    assign player3_pulse =
        (player_count >= 2'b01) ? p3_edge : 1'b0;

    assign player4_pulse =
        (player_count == 2'b10) ? p4_edge : 1'b0;

endmodule
