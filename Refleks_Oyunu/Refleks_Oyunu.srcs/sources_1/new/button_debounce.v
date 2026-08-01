 `timescale 1ns / 1ps

module button_debounce #(parameter DEBOUNCE_LIMIT = 1000000)(
    input clk,
    input rst,
    input btn_in,
    output reg btn_debounced
);
    reg [1:0] sync_reg;
    reg [19:0] counter; 
    
    always @(posedge clk) begin
        if (rst) begin
            sync_reg <= 2'b00;
        end else begin
            sync_reg[1] <= sync_reg[0];
            sync_reg[0] <= btn_in;
        end
     end

    always @(posedge clk) begin
        if (rst) begin
            counter <= 0;
            btn_debounced <= 0;
        end else if (sync_reg[1] != btn_debounced) begin
            counter <= counter + 1;
            if (counter >= DEBOUNCE_LIMIT - 1) begin
                btn_debounced <= sync_reg[1];
                counter <= 0;
            end
        end else begin
            counter <= 0; 
        end
    end
endmodule 