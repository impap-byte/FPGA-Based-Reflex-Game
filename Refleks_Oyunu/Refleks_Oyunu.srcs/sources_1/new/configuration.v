`timescale 1ns / 1ps

module configuration(
    input clk,
    input rst,
    input [8:0] sw,       // Raw switches from Basys3
    
    output reg [1:0] player_count,
    output reg hardmode,
    output reg [3:0] max_round,
    output reg elimination, // Added the elimination output
    output reg config_done
);
    
    wire confirm = sw[0];
    wire [1:0] p_count = sw[2:1];
    wire [3:0] rounds = sw[6:3]; 
    wire elim = sw[7];
    wire mode = sw[8];

    always @(posedge clk) begin
        if (rst) begin
            config_done  <= 1'b0;
            player_count <= 2'b00;
            max_round    <= 4'd0;
            elimination  <= 1'b0;
            hardmode     <= 1'b0;
        end 
        else if (confirm && !config_done) begin
            // Validate the inputs. 

            if (p_count != 2'b11) begin 
                player_count <= p_count;
                
                max_round    <= rounds;
                elimination  <= elim;
                hardmode     <= mode;
                
                config_done  <= 1'b1; // Lock the configuration
            end
        end
    end
endmodule