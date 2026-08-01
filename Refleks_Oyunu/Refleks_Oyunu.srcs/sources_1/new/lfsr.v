`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////

module lfsr (
    input  wire        clk,
    input  wire        rst,
    output wire [15:0] random
);
    reg [15:0] lfsr_reg; // 16-bit LFSR register
    wire feedback; // Feedback polinomu x^16 + x^14 + x^13 + x^11 + 1

    assign feedback = lfsr_reg[15] ^
                      lfsr_reg[13] ^
                      lfsr_reg[12] ^
                      lfsr_reg[10];

    always @(posedge clk) begin
        if (rst || lfsr_reg == 0) // sifira esit olmasina izin vermeyin demisler sansa 0 olursa diye ne olur ne olmaz kontrol ekledim
            lfsr_reg <= 16'hACE1; // sıfırdan farklı seed değeri
        else
            lfsr_reg <= {lfsr_reg[14:0], feedback}; // bu durumda sola kaydır ve feedback bitini ekle
    end
    
    assign random = lfsr_reg; //son durumdaki rastgele değer
    
endmodule