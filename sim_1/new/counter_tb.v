`timescale 1ns / 1ps
module counter_tb;

    // Parameters
    parameter PTR_WIDTH = 4;

    // Inputs
    reg rst_n;
    reg clk;
    reg en;

    // Outputs
    wire [PTR_WIDTH-1:0] q;

    // DUT Instantiation
    counter #(.PTR_WIDTH(PTR_WIDTH)) dut (
        .rst_n(rst_n),
        .clk(clk),
        .en(en),
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
        rst_n = 0; // Assert active-low reset
        en    = 0;

        // 2. Wait 100 ns for Vivado Global Reset to finish
        #100;
        
        // 3. Release Reset
        @(negedge clk);
        rst_n = 1;

        // 4. Test Enable High (Counting)
        @(negedge clk);
        en = 1;
        
        // Let it run for enough cycles to see the wrapping behavior
        #200; 

        // 5. Test Enable Low (Hold State)
        @(negedge clk);
        en = 0;
        #40;

        // Pause simulation in Vivado
        $stop; 
    end

    // Console Monitor
    initial begin
        $monitor("Time=%0t | rst_n=%b | en=%b | q=%b", 
                  $time, rst_n, en, q);
    end

endmodule