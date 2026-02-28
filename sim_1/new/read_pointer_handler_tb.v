`timescale 1ns / 1ps
module read_pointer_handler_tb;

    parameter PTR_WIDTH = 4;

    reg ren;
    reg rclk;
    reg rrst_n;
    reg [PTR_WIDTH-1:0] wptr;

    wire empty;
    wire [PTR_WIDTH-1:0] rptr;

    // DUT Instantiation
    read_pointer_handler #(.PTR_WIDTH(PTR_WIDTH)) dut (
        .ren(ren),
        .rclk(rclk),
        .rrst_n(rrst_n),
        .wptr(wptr),
        .empty(empty),
        .rptr(rptr)
    );

    // Clock Generation (10ns period)
    initial begin
        rclk = 0;
        forever #5 rclk = ~rclk;
    end

    // Stimulus
    initial begin
        // Initialize
        ren    = 0;
        rrst_n = 0;
        wptr   = 0;

        // Apply Reset
        #20;
        rrst_n = 1;

        // Case 1: FIFO Empty (wptr == rptr)
        #20;
        ren = 1;   // Try to read when empty
        #40;

        // Case 2: Make FIFO Non-Empty
        wptr = 4'd4;   // Simulate write pointer moved ahead
        #20;

        // Enable Read
        ren = 1;
        #100;

        // Stop Reading
        ren = 0;
        #40;

        $finish;
    end

    // Monitor
    initial begin
        $monitor("Time=%0t | rptr=%b | wptr=%b | empty=%b | ren=%b",
                  $time, rptr, wptr, empty, ren);
    end

endmodule
