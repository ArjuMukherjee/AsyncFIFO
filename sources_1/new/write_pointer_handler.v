`timescale 1ns / 1ps
module write_pointer_handler #(parameter PTR_WIDTH = 4)(
    input wen,
    input wclk,
    input wrst_n,
    input [PTR_WIDTH-1:0] rptr,
    output full,
    output [PTR_WIDTH-1:0] wptr
);
    
    wire add_eq = ~(|(wptr[PTR_WIDTH-2:0] ^ rptr[PTR_WIDTH-2:0]));                                             
    assign full = add_eq & (wptr[PTR_WIDTH-1] ^ rptr[PTR_WIDTH-1]);
    
    counter #(.PTR_WIDTH(PTR_WIDTH)) c1(.rst_n(wrst_n),.clk(wclk),.en(wen & ~full),.q(wptr));

endmodule
