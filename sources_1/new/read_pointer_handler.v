`timescale 1ns / 1ps
module read_pointer_handler #(parameter PTR_WIDTH = 4)(
    input ren,
    input rclk,
    input rrst_n,
    input [PTR_WIDTH-1:0] wptr,
    output empty,
    output [PTR_WIDTH-1:0] rptr
);
                                          
    assign empty = ~(|(rptr[PTR_WIDTH-1:0] ^ wptr[PTR_WIDTH-1:0]));
    
    counter #(.PTR_WIDTH(PTR_WIDTH)) c1(.rst_n(rrst_n),.clk(rclk),.en(ren & ~empty),.q(rptr));

endmodule
