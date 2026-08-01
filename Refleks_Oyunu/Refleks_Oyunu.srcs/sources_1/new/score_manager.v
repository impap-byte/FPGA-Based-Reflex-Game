`timescale 1ns / 1ps

module score_manager (
    input wire clk,
    input wire rst,
    input wire calc_enable, // Tur bittiðinde hesaplamayý tetikleyecek sinyal (game_fsm'den gelir)

    // Oyuncularýn reaksiyon süreleri (Milisaniye bazýnda, maks ~5000ms olacaðý için 16-bit yeterlidir)
    input wire [15:0] rt_p1,
    input wire [15:0] rt_p2,
    input wire [15:0] rt_p3,
    input wire [15:0] rt_p4,

    // Hata durumlarý ve geçerlilik bayraklarý
    input wire fs_p1, fs_p2, fs_p3, fs_p4,             // False start (Erken basma) bayraklarý
    input wire to_p1, to_p2, to_p3, to_p4,             // Timeout (5 sn içinde basmama) bayraklarý
    input wire valid_p1, valid_p2, valid_p3, valid_p4, // Kurallara uygun geçerli basýþ bayraklarý

    // Hesaplanan tur puanlarý (Olasý deðerler: 0, 4, 5, 6, 7 -> 3-bit yeterlidir)
    output reg [2:0] score_p1,
    output reg [2:0] score_p2,
    output reg [2:0] score_p3,
    output reg [2:0] score_p4
);

    // Oyuncularýn sýralamasýný belirlemek için kullanýlacak register'lar (0=1., 1=2., 2=3., 3=4. sýra)
    reg [1:0] rank_p1, rank_p2, rank_p3, rank_p4;

    always @(posedge clk) begin
        if (rst) begin
            score_p1 <= 3'd0;
            score_p2 <= 3'd0;
            score_p3 <= 3'd0;
            score_p4 <= 3'd0;
        end else if (calc_enable) begin
            
            // --- P1 Sýralama Hesaplamasý ---
            // Kendisinden daha hýzlý (düþük süreli) geçerli basýþ yapan her oyuncu, P1'in sýrasýný 1 geriletir.
            rank_p1 = 2'd0;
            if (valid_p2 && (rt_p2 < rt_p1)) rank_p1 = rank_p1 + 1;
            if (valid_p3 && (rt_p3 < rt_p1)) rank_p1 = rank_p1 + 1;
            if (valid_p4 && (rt_p4 < rt_p1)) rank_p1 = rank_p1 + 1;

            // --- P2 Sýralama Hesaplamasý ---
            // Eþitlik (tie) durumlarýnda tutarsýzlýk olmamasý için <= (küçük eþittir) ile indeks önceliði saðlanýr.
            rank_p2 = 2'd0;
            if (valid_p1 && (rt_p1 <= rt_p2)) rank_p2 = rank_p2 + 1;
            if (valid_p3 && (rt_p3 < rt_p2))  rank_p2 = rank_p2 + 1;
            if (valid_p4 && (rt_p4 < rt_p2))  rank_p2 = rank_p2 + 1;

            // --- P3 Sýralama Hesaplamasý ---
            rank_p3 = 2'd0;
            if (valid_p1 && (rt_p1 <= rt_p3)) rank_p3 = rank_p3 + 1;
            if (valid_p2 && (rt_p2 <= rt_p3)) rank_p3 = rank_p3 + 1;
            if (valid_p4 && (rt_p4 < rt_p3))  rank_p3 = rank_p3 + 1;

            // --- P4 Sýralama Hesaplamasý ---
            rank_p4 = 2'd0;
            if (valid_p1 && (rt_p1 <= rt_p4)) rank_p4 = rank_p4 + 1;
            if (valid_p2 && (rt_p2 <= rt_p4)) rank_p4 = rank_p4 + 1;
            if (valid_p3 && (rt_p3 <= rt_p4)) rank_p4 = rank_p4 + 1;

            // --- Puan Atamalarý ---
            // Belge Kuralý: False start veya timeout yapanlara 0 puan.
            // Geçerli basanlara reaksiyon süresine göre: 1. -> 7, 2. -> 6, 3. -> 5, 4. -> 4 puan. (Matematiksel olarak: 7 - rank)
            
            if (fs_p1 || to_p1 || !valid_p1) score_p1 <= 3'd0;
            else score_p1 <= 3'd7 - rank_p1;

            if (fs_p2 || to_p2 || !valid_p2) score_p2 <= 3'd0;
            else score_p2 <= 3'd7 - rank_p2;

            if (fs_p3 || to_p3 || !valid_p3) score_p3 <= 3'd0;
            else score_p3 <= 3'd7 - rank_p3;

            if (fs_p4 || to_p4 || !valid_p4) score_p4 <= 3'd0;
            else score_p4 <= 3'd7 - rank_p4;
            
        end
    end

endmodule