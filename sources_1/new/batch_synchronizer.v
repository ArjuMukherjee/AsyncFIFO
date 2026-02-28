`timescale 1ns / 1ps
module batch_synchronizer #(
    parameter PTR_WIDTH = 4,
    parameter DEPTH = 2
    )(
    input clk,
    input [PTR_WIDTH-1:0] ptrs_in,
    output [PTR_WIDTH-1:0] ptrs_out
);
    
    genvar i;
    generate
        for(i=0;i<PTR_WIDTH;i=i+1) begin : sync_bit
            synchronizer #(.DEPTH(DEPTH)) ss(
                .clk(clk),
                .ptr_in(ptrs_in[i]),
                .ptr_out(ptrs_out[i])
            );
        end
    endgenerate
    
endmodule
