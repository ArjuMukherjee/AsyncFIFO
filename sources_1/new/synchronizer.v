`timescale 1ns / 1ps
module synchronizer #(parameter DEPTH = 2)(
    input clk,
    input ptr_in,
    output ptr_out
);
    
    wire [DEPTH-1:0] d,q;
    
    assign d[0] = ptr_in;
    assign ptr_out = q[DEPTH-1];

    FFarray #(.PTR_WIDTH(DEPTH)) u_ff (
        .clk(clk),
        .rst(1'b1),
        .E(1'b1),
        .d(d),
        .q(q)
    );
    
    genvar i;
    
    generate
        for(i=0;i<DEPTH-1;i=i+1) begin: sync_ff
            assign d[i+1] = q[i];
        end
    endgenerate
    
endmodule
