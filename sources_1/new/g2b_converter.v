`timescale 1ns / 1ps
module g2b_converter #(parameter PTR_WIDTH = 4) (
    input [PTR_WIDTH-1:0] gray_ptr,
    output [PTR_WIDTH-1:0] binary_ptr
    );
    
    assign binary_ptr[PTR_WIDTH-1] = gray_ptr[PTR_WIDTH-1];
    
    genvar i;
    generate
        for(i=PTR_WIDTH-2;i>=0;i=i-1) begin : genblock
            assign binary_ptr[i] = gray_ptr[i] ^ binary_ptr[i+1];
        end
    endgenerate
    
endmodule
