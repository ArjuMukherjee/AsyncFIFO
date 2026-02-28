`timescale 1ns / 1ps
module FFarray #(parameter PTR_WIDTH = 4) (
    input clk,
    input rst,
    input E,
    input [PTR_WIDTH-1:0] d,
    output [PTR_WIDTH-1:0] q
);
    
    genvar i;
    
    generate
        for(i=0;i<PTR_WIDTH;i=i+1) begin : dff_inst
            D_FF dff (
                .clk(clk),
                .E(E),
                .rst(rst),
                .D(d[i]),
                .Q(q[i])
            );
        end
    endgenerate
    
endmodule
