`timescale 1ns / 1ps
module write_pointer_handler_tb;

    // Parameters
    parameter PTR_WIDTH = 4;

    // Inputs
    reg wen;
    reg wclk;
    reg wrst_n;
    reg [PTR_WIDTH-1:0] rptr;

    // Outputs
    wire full;
    wire [PTR_WIDTH-1:0] wptr;

    // DUT Instantiation
    write_pointer_handler #(.PTR_WIDTH(PTR_WIDTH)) dut (
        .wen(wen),
        .wclk(wclk),
        .wrst_n(wrst_n),
        .rptr(rptr),
        .full(full),
        .wptr(wptr)
    );

    // Clock Generation: 100MHz (10ns period)
    initial begin
        wclk = 0;
        forever #5 wclk = ~wclk;
    end

    // Stimulus
    initial begin
        // 1. Initialize Inputs
        wen    = 0;
        wrst_n = 0;
        rptr   = 4'b0000;

        // 2. Wait 100 ns for Vivado Global Reset (GSR)
        #100;
        
        // 3. Release Reset
        @(negedge wclk);
        wrst_n = 1;

        // 4. Test Normal Writing (Fill the FIFO)
        @(negedge wclk);
        wen = 1;
        
        // Let it write 8 times to fill the FIFO.
        // wptr will count: 0 -> 1 -> ... -> 8 (4'b1000)
        #80; 
        
        // 5. Test Overflow Protection (FIFO is Full)
        // At this point, wptr = 4'b1000 and rptr = 4'b0000.
        // The MSBs are different, so 'full' will be 1.
        // Even though 'wen' is still 1, wptr should NOT increment to 9.
        #40; 
        
        // 6. Test Releasing Full Condition
        // Simulate the read pointer advancing (reading data out)
        @(negedge wclk);
        rptr = 4'b0010; // Read domain read 2 items
        
        // 'full' should instantly drop to 0. 
        // Because 'wen' is still 1, wptr should start incrementing again (to 9, 10...)
        #40;

        // 7. Stop writing
        @(negedge wclk);
        wen = 0;
        #40;
        
        // Pause simulation in Vivado
        $stop; 
    end

    // Console Monitor
    initial begin
        $monitor("Time=%0t | wrst_n=%b | wen=%b | rptr=%b | wptr=%b | full=%b", 
                  $time, wrst_n, wen, rptr, wptr, full);
    end

endmodule