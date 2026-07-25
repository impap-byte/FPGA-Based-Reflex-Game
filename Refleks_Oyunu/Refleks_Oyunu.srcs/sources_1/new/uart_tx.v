`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/22/2026 02:59:47 PM
// Design Name: 
// Module Name: uart_tx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: :)
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_tx(
        input           clk,
        input         reset,
        input      tx_start,
        input [7:0] data_in,
        output           tx,
        output       tx_done
    );
    
    localparam IDLE = 2'b00;
    localparam START = 2'b01;
    localparam DATA = 2'b10;
    localparam STOP = 2'b11;
    localparam BAUD_TICK = 14'd10416;
    // Saniyede 9600 bit iletece?iz(9600 baud rate)
    // Basys3 FPGA'imizin clock h?z? 100 Mhz yani saniyede 100 * 10^6 kez posedge vuruyor
    // 100000000/9600 = 10416 | her 10416 posedge'de bir veri iletmeliyiz ki saniyede 9600 bit iletilsin.
    // Her bir veri iletimi cycle'?n? ayr? bir clock gibi dü?ünürsek bu clock'un her bir posedge'ine BAUD_TICK diyebiliriz.
    
    reg baud_tick;
    reg [13:0] counter_r, counter_n;
    reg [1:0] state_n = IDLE;
    reg [1:0] state_r = IDLE;
    
    reg [7:0] data_n = 0;
    reg [7:0] data_r = 0;
    
    reg tx_r, tx_n;
    reg[2:0] bit_counter_n = 0;
    reg[2:0] bit_counter_r = 0;
    
    reg tx_done_r, tx_done_n;
    
    always @* begin
    
        //Default olarak counter artacak
        counter_n = counter_r + 1;
        data_n = data_r;
        //Default olarak state degismeyecek
        state_n = state_r;
        bit_counter_n = bit_counter_r;
        
        //Default de?erler
        tx_done_n = 1'b0;
        tx_n = 1'b1;
        
        case (state_r) 
            IDLE: begin
                //tx_start sinyali bize iletime ba?lama emrini veriyor
                if(tx_start) begin
                    // Gönderilecek veriyi bir buffera al?yoruz. Bir sonraki posedge'de data_r'a aktar?lacak
                    data_n = data_in;
                    state_n = START;
                    counter_n = 0;
                    bit_counter_n  = 0;
                end
                else counter_n = 0;
                
            end
            
            START: begin
                tx_n = 1'b0;
                if(counter_r == BAUD_TICK) begin
                    counter_n = 0;
                    state_n = DATA;
                end    
            end
            
            DATA: begin
                //en önemsiz bit tx yoluna verilir
                tx_n = data_r[0];
                if(bit_counter_r == 3'd7 && counter_r == BAUD_TICK) begin
                        state_n = STOP;
                        counter_n = 0;
                end
                
                else if(counter_r == BAUD_TICK) begin
                    // Veri bir sa?a kayd?r?l?r, en önemsiz bit de?i?ir
                    data_n = data_r >> 1;
                    bit_counter_n = bit_counter_r + 1;
                    counter_n = 0;
                end
                
                
                
            end
            
            STOP: begin
                tx_n = 1'b1;
                if(counter_r == BAUD_TICK) begin
                    counter_n = 0;
                    tx_done_n = 1'b1;
                    state_n = IDLE;
                end
            end
            
            default: begin
                state_n = IDLE;
                tx_n = 1'b1;
            end
        endcase
      
    end
    
    
    always @(posedge clk) begin
        if (reset) begin
            state_r <= IDLE;
            counter_r <= 0;
            tx_r <= 1'b1;
            data_r <= 0;
            bit_counter_r <= 0;
            tx_done_r <= 1'b0;
        end
        else begin
            state_r <= state_n; 
            counter_r <= counter_n;
            tx_r <= tx_n;
            data_r <= data_n;
            bit_counter_r <= bit_counter_n;
            tx_done_r <= tx_done_n;
        end
    end
    
    assign tx = tx_r;
    assign tx_done = tx_done_r;
    
    
endmodule
