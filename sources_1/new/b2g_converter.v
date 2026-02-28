`timescale 1ns / 1ps
module b2g_converter #(parameter PTR_WIDTH = 4) (
    input [PTR_WIDTH-1:0] binary_ptr,
    output [PTR_WIDTH-1:0] gray_ptr
    );
    
    assign gray_ptr = binary_ptr ^ (binary_ptr >> 1);
    
endmodule
