 `timescale 1ns / 1ps

module button_debounce #(parameter DEBOUNCE_LIMIT = 1000000)( // 10 ms bekleme suresi
    input clk,
    input rst,
    input btn_in,
    output reg btn_debounced
);
    
    reg [1:0] sync_reg;
    reg [19:0] counter = 0; 
    
    // D Flip-Flop zinciri, asenkron buton sinyali clk ile senkronize ediliyor
    always @(posedge clk) begin
        if (rst) begin
            sync_reg <= 2'b00;
        end else begin
            sync_reg[0] <= btn_in; // 1. FF: Asenkron buton alinir
            sync_reg[1] <= sync_reg[0]; // 2. FF: Senkronize sinyal ana devreye aktarilir 
        end
     end

    always @(posedge clk) begin
        if (rst) begin
            counter       <= 20'd0;
            btn_debounced <= 1'b0; // Cikis flip-flopu sifirlanir
        end else if (sync_reg[1] != btn_debounced) begin
            counter <= counter + 1'b1; // Titresim suresi sayilir
            if (counter >= DEBOUNCE_LIMIT - 1) begin // Sinyal 10ms sabit kaldiysa
                btn_debounced <= sync_reg[1]; // Yeni durum cikis flip-flopuna yazilir
                counter       <= 20'd0;
            end
        end else begin
            counter <= 20'd0; // Sinyal eski haline donerse sayac sifirlanir
        end
    end
endmodule 