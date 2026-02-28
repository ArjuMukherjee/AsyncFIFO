`timescale 1ns / 1ps
module g2b_converter_tb;
    
    wire [3:0] binary_ptr;
    reg [3:0] gray_ptr;
    
    g2b_converter #(.PTR_WIDTH(4)) g2b1 (.gray_ptr(gray_ptr),.binary_ptr(binary_ptr));
    
    initial begin : g2b_tb_inst
        integer i;
        for(i=0;i<16;i=i+1) begin
            gray_ptr <= i;
            #10;
        end
        #10;
        $finish;
        $monitor("Time=%0t Binary=%b Gray=%b",
        $time, binary_ptr, gray_ptr);
    end
    
endmodule
