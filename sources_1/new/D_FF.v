`timescale 1ns / 1ps
module D_FF(
    input D,
    input clk,
    input E,
    input rst,
    output reg Q
    );
    
    always@(posedge clk or negedge rst) begin
        if(~rst) Q <= 1'b0;
        else
            if(E) Q <= D;
    end
    
endmodule
