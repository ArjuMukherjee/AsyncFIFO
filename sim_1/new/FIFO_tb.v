`timescale 1ns / 1ps

module FIFO_tb;

    // Parameters matching your top module
    parameter REGISTERS = 8;
    parameter SYNCHRONIZER = 2;
    parameter BUS_WIDTH = 32;

    // Inputs
    reg [BUS_WIDTH-1:0] data_in;
    reg wclk, wen, wrst_n;
    reg rclk, ren, rrst_n;

    // Outputs
    wire full, empty;
    wire [BUS_WIDTH-1:0] data_out;

    // DUT Instantiation
    FIFO #(
        .REGISTERS(REGISTERS),
        .SYNCHRONIZER(SYNCHRONIZER),
        .BUS_WIDTH(BUS_WIDTH)
    ) dut (
        .data_in(data_in),
        .wclk(wclk), 
        .wen(wen), 
        .wrst_n(wrst_n),
        .rclk(rclk), 
        .ren(ren), 
        .rrst_n(rrst_n),
        .full(full), 
        .empty(empty),
        .data_out(data_out)
    );

    // ---------------------------------------------------------
    // Clock Generation
    // ---------------------------------------------------------
    // Write Clock: 100 MHz (10ns period)
    initial begin
        wclk = 0;
        forever #5 wclk = ~wclk;
    end

    // Read Clock: ~66.6 MHz (15ns period) - Asynchronous to wclk
    initial begin
        rclk = 0;
        forever #7.5 rclk = ~rclk;
    end

    // ---------------------------------------------------------
    // Stimulus
    // ---------------------------------------------------------
    initial begin
        // 1. Initialize all signals
        data_in = 0;
        wen     = 0;
        wrst_n  = 0;
        ren     = 0;
        rrst_n  = 0;

        // 2. Wait for Vivado Global Reset (GSR)
        #100;

        // 3. Release Resets
        @(negedge wclk) wrst_n = 1;
        @(negedge rclk) rrst_n = 1;

        // Give the synchronizers a few clocks to flush out their initial states
        #50;

        // ---------------------------------------------------------
        // Phase 1: Write until FULL
        // ---------------------------------------------------------
        $display("[%0t] Starting Phase 1: Filling the FIFO...", $time);
        @(negedge wclk);
        wen = 1;
        
        // Write exactly 8 items to fill the memory
        data_in = 32'hA111_1111; @(negedge wclk);
        data_in = 32'hB222_2222; @(negedge wclk);
        data_in = 32'hC333_3333; @(negedge wclk);
        data_in = 32'hD444_4444; @(negedge wclk);
        data_in = 32'hE555_5555; @(negedge wclk);
        data_in = 32'hF666_6666; @(negedge wclk);
        data_in = 32'h7777_7777; @(negedge wclk);
        data_in = 32'h8888_8888; @(negedge wclk);
        
        // The FIFO should now assert 'full'. Let's try to write one more 
        // to test the overflow protection.
        data_in = 32'hDEAD_BEEF; 
        @(negedge wclk);
        wen = 0; // Stop writing

        // ---------------------------------------------------------
        // Phase 2: Wait for pointers to synchronize
        // ---------------------------------------------------------
        // The read domain won't instantly know the FIFO has data. 
        // We must wait for the Gray write-pointer to pass through the read synchronizers.
        #60; 

        // ---------------------------------------------------------
        // Phase 3: Read until EMPTY
        // ---------------------------------------------------------
        $display("[%0t] Starting Phase 3: Emptying the FIFO...", $time);
        @(negedge rclk);
        ren = 1;

        // Read all 8 items. Watch the data_out in the waveform!
        repeat(8) @(negedge rclk);
        
        // The FIFO should now assert 'empty'. Keep 'ren' high for one more clock 
        // to ensure the read pointer doesn't underflow and read garbage.
        @(negedge rclk);
        ren = 0; // Stop reading

        // ---------------------------------------------------------
        // Phase 4: Concurrent Read and Write
        // ---------------------------------------------------------
        // Let the read pointer sync back over to the write domain to clear the 'full' flag
        #60; 
        
        $display("[%0t] Starting Phase 4: Concurrent Read/Write...", $time);
        
        // Start writing and reading simultaneously
        @(negedge wclk) wen = 1; data_in = 32'h9999_9999;
        @(negedge rclk) ren = 1;
        
        @(negedge wclk) data_in = 32'hAAAA_AAAA;
        @(negedge wclk) wen = 0;
        
        @(negedge rclk) ren = 0;

        #100;
        $display("[%0t] Simulation Complete!", $time);
        $stop; // Pause in Vivado
    end

    // ---------------------------------------------------------
    // Console Monitor
    // ---------------------------------------------------------
    initial begin
        $monitor("Time=%0t | WCLK: wen=%b, din=%h, full=%b || RCLK: ren=%b, dout=%h, empty=%b", 
                  $time, wen, data_in, full, ren, data_out, empty);
    end

endmodule