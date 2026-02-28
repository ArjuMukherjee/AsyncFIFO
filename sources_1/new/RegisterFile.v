`timescale 1ns / 1ps
module RegisterFile #(
        parameter BUS_WIDTH = 32,
        parameter DEPTH = 8,
        parameter PTR_WIDTH = 4
    )(
        input [BUS_WIDTH-1:0] data_in,
        input wclk,
        input rclk,
        input wen,
        input ren,
        input [PTR_WIDTH-1:0] wptr,
        input [PTR_WIDTH-1:0] rptr,
        input full,
        input empty,
        output reg [BUS_WIDTH-1:0] data_out
);

reg [BUS_WIDTH-1:0] file [DEPTH-1:0];

always@(posedge wclk) begin
    if(wen & ~full) file[wptr[PTR_WIDTH-2:0]] <= data_in;
end

always@(posedge rclk) begin
    if(ren & ~empty) data_out <= file[rptr[PTR_WIDTH-2:0]];
end

endmodule
