`timescale 1ns / 1ps
module FIFO #(
    parameter REGISTERS = 8,
    parameter PTR_WIDTH = clogb2(REGISTERS) + 1,
    parameter SYNCHRONIZER = 2,
    parameter BUS_WIDTH = 32
    )(
    input [BUS_WIDTH-1:0] data_in,
    input wclk, wen, wrst_n,
    input rclk, ren, rrst_n,
    output full, empty,
    output [BUS_WIDTH-1:0] data_out
);

    wire [PTR_WIDTH-1:0] wptr, b2g_bs_wptr, b2g_as_wptr, g2b_wptr,
                         rptr, b2g_bs_rptr, b2g_as_rptr, g2b_rptr;
        
    RegisterFile #(
        .BUS_WIDTH(BUS_WIDTH),
        .DEPTH(REGISTERS),
        .PTR_WIDTH(PTR_WIDTH)
        ) rfile (
        .data_in(data_in),
        .wclk(wclk), .wen(wen), .wptr(wptr),
        .rclk(rclk), .ren(ren), .rptr(rptr),
        .full(full), .empty(empty),
        .data_out(data_out)
    );
    
    write_pointer_handler #(
        .PTR_WIDTH(PTR_WIDTH)
        ) write_controller (
        .wen(wen), .wclk(wclk), .wrst_n(wrst_n),
        .rptr(g2b_rptr),
        .wptr(wptr), .full(full)
    );
    
    read_pointer_handler #(
        .PTR_WIDTH(PTR_WIDTH)
        ) read_controller (
        .ren(ren), .rclk(rclk), .rrst_n(rrst_n),
        .wptr(g2b_wptr),
        .rptr(rptr), .empty(empty)
    );
    
    b2g_converter #(.PTR_WIDTH(PTR_WIDTH)) b2g1 (
        .binary_ptr(wptr),
        .gray_ptr(b2g_bs_wptr)
    );
    b2g_converter #(.PTR_WIDTH(PTR_WIDTH)) b2g2 (
        .binary_ptr(rptr),
        .gray_ptr(b2g_bs_rptr)
    );
    g2b_converter #(.PTR_WIDTH(PTR_WIDTH)) g2b1 (
        .gray_ptr(b2g_as_rptr),
        .binary_ptr(g2b_rptr)
    );
    g2b_converter #(.PTR_WIDTH(PTR_WIDTH)) g2b2 (
        .gray_ptr(b2g_as_wptr),
        .binary_ptr(g2b_wptr)
    );
    
    batch_synchronizer #(
        .PTR_WIDTH(PTR_WIDTH),
        .DEPTH(SYNCHRONIZER)
        ) BS1 (
        .clk(wclk),
        .ptrs_in(b2g_bs_rptr),
        .ptrs_out(b2g_as_rptr)
    );
    batch_synchronizer #(
        .PTR_WIDTH(PTR_WIDTH),
        .DEPTH(SYNCHRONIZER)
        ) BS2 (
        .clk(rclk),
        .ptrs_in(b2g_bs_wptr),
        .ptrs_out(b2g_as_wptr)
    );

    function integer clogb2;
        input integer depth;
        begin
            depth = depth - 1;
            for(clogb2 = 0; depth > 0; clogb2 = clogb2 + 1)
                depth = depth >> 1;
        end
    endfunction

endmodule
