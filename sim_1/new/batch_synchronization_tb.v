`timescale 1ns / 1ps
module batch_synchronizer_tb;

    // Parameters
    parameter PTR_WIDTH = 4;
    parameter DEPTH = 3; // Standard 2-stage synchronizer

    // Inputs
    reg clk;
    reg [PTR_WIDTH-1:0] ptrs_in;

    // Outputs
    wire [PTR_WIDTH-1:0] ptrs_out;

    // DUT Instantiation
    batch_synchronizer #(
        .PTR_WIDTH(PTR_WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk(clk),
        .ptrs_in(ptrs_in),
        .ptrs_out(ptrs_out)
    );

    // Clock Generation: 100MHz (10ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Stimulus
    initial begin
        // 1. Initialize Inputs
        ptrs_in = 4'b0000;

        // 2. Wait 100 ns for Vivado Global Reset (GSR) settling
        #100;
        
        // 3. Apply Asynchronous Input Change #1
        // Changing data 2ns after the clock edge to mimic an asynchronous 
        // signal arriving from the opposite clock domain.
        #12; 
        ptrs_in = 4'b1010;
        
        // Wait and observe. With DEPTH=2, it should take 2 positive 
        // clock edges for ptrs_out to reflect 4'b1010.
        #40;
        
        // 4. Apply Asynchronous Input Change #2
        #13;
        ptrs_in = 4'b0101;
        
        // Wait to observe the propagation
        #40;
        
        // 5. The "Binary Pointer Glitch" Test (Why we use Gray Code!)
        // If a multi-bit binary signal changes multiple bits at once and arrives 
        // right on the setup/hold window of the clock edge, some bits might get 
        // captured on this clock, and others on the next!
        @(posedge clk);
        ptrs_in = 4'b1000; // Simulated transition from 0111 to 1000
        
        #50;
        
        // Pause simulation in Vivado
        $stop; 
    end

    // Console Monitor
    initial begin
        $monitor("Time=%0t | clk=%b | ptrs_in=%b | ptrs_out=%b", 
                  $time, clk, ptrs_in, ptrs_out);
    end

endmodule