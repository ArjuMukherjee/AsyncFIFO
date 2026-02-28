`timescale 1ns / 1ps
module counter #(parameter PTR_WIDTH = 4)(
    input rst_n,
    input clk,
    input en,
    output [PTR_WIDTH-1:0] q
);
    
    wire [PTR_WIDTH-1:0] d;
    
    FFarray #(.PTR_WIDTH(PTR_WIDTH)) u_ff (
        .clk(clk),
        .rst(rst_n),
        .E(en),
        .d(d),
        .q(q)
    );
    
    assign d[0] = en ^ q[0];
    
    genvar i;
    wire [PTR_WIDTH-2:0] aq;
    assign aq[0] = q[0];
        
    generate
        for(i=0;i<PTR_WIDTH-2;i=i+1) begin
            assign aq[i+1] = aq[i] & q[i+1];
        end
        for(i=0;i<PTR_WIDTH-1;i=i+1) begin
            assign d[i+1] = (~en & q[i+1]) | (en & aq[i]);
        end
    endgenerate
    
endmodule
