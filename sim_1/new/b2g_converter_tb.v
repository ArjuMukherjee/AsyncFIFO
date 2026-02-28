`timescale 1ns / 1ps
module b2g_converter_tb;

    reg [3:0] binary_ptr;
    wire [3:0] gray_ptr;
    
    b2g_converter #(.PTR_WIDTH(4)) b2g1 (.binary_ptr(binary_ptr),.gray_ptr(gray_ptr));
    
    initial begin : b2g_tb_inst
        integer i;
        for(i=0;i<16;i=i+1) begin
            binary_ptr <= i;
            #10;
        end
        #10
        $finish;
        $monitor("Time=%0t Binary=%b Gray=%b",
        $time, binary_ptr, gray_ptr);
    end
endmodule