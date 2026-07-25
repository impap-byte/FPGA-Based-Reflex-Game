`timescale 1ns / 1ps
// Bunu AI yapt? test için kullan?lacak submitlenmeyecek zaten
module uart_rx(
    input            clk,
    input            reset,
    input            rx,           // The serial input wire
    output [7:0]     data_out,     // The 8-bit received payload
    output           rx_done       // Pulses HIGH for 1 clock cycle when a byte is fully received
);
    
    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;
    
    // 100,000,000 / 9600 = 10416 clock cycles per baud
    localparam BAUD_TICK = 14'd10416;
    // Exactly half of a baud period to sample in the middle of the bit
    localparam HALF_BAUD = 14'd5208; 
    
    reg [13:0] counter_r = 0, counter_n;
    reg [1:0]  state_r = IDLE, state_n;
    
    reg [7:0]  data_r = 0, data_n;
    reg [2:0]  bit_counter_r = 0, bit_counter_n;
    
    reg rx_done_r = 1'b0, rx_done_n;
    
    always @* begin
        // Default assignments to prevent latches
        counter_n     = counter_r + 1;
        state_n       = state_r;
        data_n        = data_r;
        bit_counter_n = bit_counter_r;
        rx_done_n     = 1'b0; // Default to 0, ONLY pulses HIGH for 1 cycle when done
        
        case (state_r)
            IDLE: begin
                counter_n = 0; // Keep counter at 0 while waiting
                
                // The rx line idling HIGH. A drop to LOW means a START bit is incoming.
                if (rx == 1'b0) begin
                    state_n = START;
                end
            end
            
            START: begin
                // Wait for HALF a baud cycle. This aligns our sampler to the dead center of the bit!
                if (counter_r == HALF_BAUD) begin
                    counter_n = 0;
                    bit_counter_n = 0;
                    
                    // Glitch filter: Check if rx is STILL low. If it spiked back high, it was noise.
                    if (rx == 1'b0) begin
                        state_n = DATA;
                    end else begin
                        state_n = IDLE; 
                    end
                end
            end
            
            DATA: begin
                // Now we wait for a FULL baud cycle, skipping from middle to middle of each bit
                if (counter_r == BAUD_TICK) begin
                    counter_n = 0;
                    
                    // Because UART sends the LSB (bit 0) first, we shift right and drop the new bit into the MSB (bit 7)
                    data_n = {rx, data_r[7:1]}; 
                    
                    if (bit_counter_r == 3'd7) begin
                        state_n = STOP;
                    end else begin
                        bit_counter_n = bit_counter_r + 1;
                    end
                end
            end
            
            STOP: begin
                // Wait for a full baud cycle to step through the middle of the STOP bit
                if (counter_r == BAUD_TICK) begin
                    counter_n = 0;
                    rx_done_n = 1'b1; // Trigger the success pulse!
                    state_n = IDLE;
                end
            end
            
            default: begin
                state_n = IDLE;
            end
        endcase
    end
    
    // Sequential block with synchronous reset
    always @(posedge clk) begin
        if (reset) begin
            state_r       <= IDLE;
            counter_r     <= 0;
            data_r        <= 0;
            bit_counter_r <= 0;
            rx_done_r     <= 1'b0;
        end else begin
            state_r       <= state_n;
            counter_r     <= counter_n;
            data_r        <= data_n;
            bit_counter_r <= bit_counter_n;
            rx_done_r     <= rx_done_n;
        end
    end
    
    assign data_out = data_r;
    assign rx_done  = rx_done_r;
    
endmodule