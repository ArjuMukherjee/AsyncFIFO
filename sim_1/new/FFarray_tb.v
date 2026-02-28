`timescale 1ns / 1ps

module FFarray_tb;

    // Parameters
    parameter PTR_WIDTH = 4;

    // Inputs
    reg clk;
    reg rst;
    reg E;
    reg [PTR_WIDTH-1:0] d;

    // Outputs
    wire [PTR_WIDTH-1:0] q;

    // DUT Instantiation
    FFarray #(.PTR_WIDTH(PTR_WIDTH)) dut (
        .clk(clk),
        .rst(rst),
        .E(E),
        .d(d),
        .q(q)
    );

    // Clock Generation: 100MHz (10ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Stimulus
    initial begin
        // 1. Initialize Inputs
        rst = 1;    // Assuming active-high reset for the D_FF
        E   = 0;
        d   = 4'b0000;

        // 2. Wait 100 ns for Vivado Global Reset to finish
        #100;
        
        // 3. Release Reset
        @(negedge clk);
        rst = 0;

        // 4. Test Enable Low (Hold State)
        @(negedge clk);
        d = 4'b1010; 
        #20; // q should remain 0000

        // 5. Test Enable High (Latching State)
        @(negedge clk);
        E = 1;
        #20; // q should update to 1010 on the next posedge
        
        // 6. Test Changing Data while Enabled
        @(negedge clk);
        d = 4'b0101;
        #20; // q should update to 0101
        
        // 7. Test Disable and Hold
        @(negedge clk);
        E = 0;
        d = 4'b1111;
        #20; // q should stay 0101, ignoring 1111
        
        // 8. Test Reset during active operation
        @(negedge clk);
        E = 1;
        rst = 1;
        #20; // q should clear to 0000
        
        // Pause simulation in Vivado (leaves waveform window open)
        $stop; 
    end

    // Optional: Keep monitor for Vivado Tcl Console output
    initial begin
        $monitor("Time=%0t | clk=%b | rst=%b | E=%b | d=%b | q=%b", 
                  $time, clk, rst, E, d, q);
    end

endmodule