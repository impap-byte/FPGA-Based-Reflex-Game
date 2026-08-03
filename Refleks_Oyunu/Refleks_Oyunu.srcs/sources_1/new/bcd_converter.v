`timescale 1ns / 1ps

module bcd_converter(
    input [12:0] binary_num,
    output reg [15:0] bcd
    );

    reg [28:0] shift_reg;
    integer i;
    
    always @* begin
        shift_reg = {16'b0, binary_num};
        
        for(i = 0; i < 13; i = i+1) begin
            //birler
            if(shift_reg[16:13] >= 5) begin
                shift_reg[16:13] = shift_reg[16:13] + 3;
            end
            //onlar
            if(shift_reg[20:17] >= 5) begin
                shift_reg[20:17] = shift_reg[20:17] + 3;
            end
            //yuzler
            if(shift_reg[24:21] >= 5) begin
                shift_reg[24:21] = shift_reg[24:21] + 3;
            end
            //binler
            if(shift_reg[28:25] >= 5) begin
                shift_reg[28:25] = shift_reg[28:25] + 3;
            end
            shift_reg = shift_reg << 1;
        end
        
        bcd = shift_reg[28:13];
    end
    
    
endmodule
