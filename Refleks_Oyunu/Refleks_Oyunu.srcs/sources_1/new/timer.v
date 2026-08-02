`timescale 1ns / 1ps

module timer(
    input             clk,
    input             rst,
    input             start_wait, // BTNC'ye basilinca bekleme suresini baslatmak icin
    input             start_reaction, // Ekran sonunce reaksiyon zamanini baslatmak icin
    input [12:0]      wait_ms, 
    output reg        wait_done,
    output [12:0]     reaction_time,
    output reg        timeout // Reaksiyon suresi bitince
    );

    // Clock sinyali saniyede 100 milyon kez atildigi icin once 1 ms cozunurlukte olculmeli.
    reg [16:0] prescaler_count; // 0-99999 sayaci icin en az 17 bit gerekli.
    wire       ms_tick;
    
    assign ms_tick = (prescaler_count == 17'd99_999);
    
    // 0'dan 99999'a kadar sayan sayac 1 ms gectiginin haberini ms_tick sinyali araciligi ile veriyor.
    always @(posedge clk) begin
        if (rst) begin
            prescaler_count <= 17'd0;
        end else if (ms_tick) begin
            prescaler_count <= 17'd0; // 1 ms gectigi durum
        end else begin
            prescaler_count <= prescaler_count + 1'b1;
        end
    end 
    
    
    reg [12:0] target_wait_ms; // wait_ms'in anlik degerinin kaydedilmesi icin
    reg [12:0] wait_count; // Anlik sayýlan ms
    reg        wait_active; // Bekleme sayacinin durumu
    
    always @(posedge clk) begin
        if (rst) begin
            target_wait_ms <= 13'd0;
            wait_count     <= 13'd0;
            wait_active    <= 1'b0;
            wait_done      <= 1'b0;
        end else begin
            wait_done <= 1'b0;
            
            if (start_wait) begin // FSM'den gelen emir
                target_wait_ms <= wait_ms; // O anki ms degeri
                wait_count     <= 13'd0;   // Sayaci sifirlar
                wait_active    <= 1'b1;    // Saymayi aktiflestirir
            end else if (wait_active && ms_tick) begin 
                if (wait_count + 1'b1 >= target_wait_ms) begin
                    wait_active <= 1'b0; // Sayma biter
                    wait_done   <= 1'b1; // FSM'e haber vermek icin
                end else begin
                    wait_count <= wait_count + 1'b1; // Sayac 1 ms artar
                end
            end
        end
    end
    
    reg [12:0] reaction_count; // 0-5000 ms arasý sayacak kronometre
    reg        reaction_active;
    
    assign reaction_time = reaction_count;
    
    always @(posedge clk) begin
        if (rst) begin
            reaction_count  <= 13'd0;
            reaction_active <= 1'b0;
            timeout         <= 1'b0;
        end else begin
            timeout <= 1'b0; 
            
            if (start_reaction) begin
                reaction_count  <= 13'd0;
                reaction_active <= 1'b1; // Sayma baslar.
            end else if (reaction_active && ms_tick) begin
                if (reaction_count >= 13'd5000) begin // 5000 ms olup olmadiginin kontrolu
                    reaction_active <= 1'b0;
                    timeout         <= 1'b1;
                end else begin
                    reaction_count <= reaction_count + 1'b1;
                end
            end
        end
    end
endmodule