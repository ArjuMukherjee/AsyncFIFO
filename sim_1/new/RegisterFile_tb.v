`timescale 1ns / 1ps

module RegisterFile_tb;

    // Parameters
    parameter BUS_WIDTH = 32;
    parameter DEPTH = 8;
    parameter PTR_WIDTH = 4;

    // Inputs
    reg [BUS_WIDTH-1:0] data_in;
    reg wclk;
    reg rclk;
    reg wen;
    reg ren;
    reg [PTR_WIDTH-1:0] wptr;
    reg [PTR_WIDTH-1:0] rptr;
    reg full;
    reg empty;

    // Outputs
    wire [BUS_WIDTH-1:0] data_out;

    // DUT Instantiation
    RegisterFile #(
        .BUS_WIDTH(BUS_WIDTH),
        .DEPTH(DEPTH),
        .PTR_WIDTH(PTR_WIDTH)
    ) dut (
        .data_in(data_in),
        .wclk(wclk),
        .rclk(rclk),
        .wen(wen),
        .ren(ren),
        .wptr(wptr),
        .rptr(rptr),
        .full(full),
        .empty(empty),
        .data_out(data_out)
    );

    // Clock Generation
    // Write Clock: 100 MHz (10ns period)
    initial begin
        wclk = 0;
        forever #5 wclk = ~wclk;
    end

    // Read Clock: ~66.6 MHz (15ns period) to simulate asynchronous domains
    initial begin
        rclk = 0;
        forever #7.5 rclk = ~rclk;
    end

    // Stimulus
    initial begin
        // 1. Initialize Inputs
        data_in = 0;
        wen     = 0;
        ren     = 0;
        wptr    = 0;
        rptr    = 0;
        full    = 0;
        empty   = 1; // FIFO starts empty

        // 2. Wait 100 ns for Vivado Global Reset (GSR)
        #100;

        // 3. Write Data Sequence (Synchronous to wclk)
        @(negedge wclk);
        wen = 1; full = 0;
        
        wptr = 4'd0; data_in = 32'hAAAA_1111; @(negedge wclk);
        wptr = 4'd1; data_in = 32'hBBBB_2222; @(negedge wclk);
        wptr = 4'd2; data_in = 32'hCCCC_3333; @(negedge wclk);
        
        wen = 0; // Stop writing

        // 4. Test Full Flag Protection
        @(negedge wclk);
        wen = 1; full = 1; // Assert full flag
        wptr = 4'd3; data_in = 32'hDEAD_BEEF; // Try to write malicious data
        @(negedge wclk);
        wen = 0; full = 0;

        // 5. Read Data Sequence (Synchronous to rclk)
        @(negedge rclk);
        ren = 1; empty = 0; // FIFO is no longer empty
        
        rptr = 4'd0; @(negedge rclk); // Should read AAAA_1111
        rptr = 4'd1; @(negedge rclk); // Should read BBBB_2222
        rptr = 4'd2; @(negedge rclk); // Should read CCCC_3333
        
        // 6. Test Empty Flag Protection & verify the blocked write
        rptr = 4'd3; empty = 1; // Assert empty flag, try to read index 3
        @(negedge rclk);
        
        ren = 0; empty = 0;
        
        // To verify index 3 wasn't overwritten by DEAD_BEEF earlier, 
        // read it normally. It should be X (uninitialized) in simulation.
        @(negedge rclk);
        ren = 1; rptr = 4'd3; 
        @(negedge rclk);
        
        ren = 0;

        // Pause simulation in Vivado
        #20;
        $stop;
    end

    // Console Monitor
    initial begin
        $monitor("Time=%0t | wclk=%b | wen=%b | wptr=%0d | din=%h || rclk=%b | ren=%b | rptr=%0d | dout=%h | full=%b | empty=%b", 
                  $time, wclk, wen, wptr, data_in, rclk, ren, rptr, data_out, full, empty);
    end

endmodule