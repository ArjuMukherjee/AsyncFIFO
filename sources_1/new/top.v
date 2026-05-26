`timescale 1ns / 1ps
module top(
    input clk,
    input reset,
    input [7:0] data_in,
    output [7:0] data_out,
    output full,
    output empty,
    output led_locked,
    input w_en,
    input r_en
    );
    
    wire clk_50;
    wire clk_30;
    wire pll_locked;
    wire sys_reset;

    clk_wiz_0 system_clocks (
        .clk_in1(clk),         // 100 MHz input clock
        .clk_out1(clk_50),     // 50 MHz write clock domain
        .clk_out2(clk_30),     // 30 MHz read clock domain
        .reset(reset),          // Physical button resets the PLL hardware
        .locked(pll_locked)    // Output from PLL: 1 when stable, 0 when unstable
    );

    assign led_locked = pll_locked;
    assign sys_reset = reset || (~pll_locked);
    
    wire r_en_p, w_en_p;
    
    button_pulse_gen #(.freq_MHz(50)) btn1(.clk(clk_50),.rst(sys_reset),.btn_in(r_en),.btn_pulse(r_en_p));
    button_pulse_gen #(.freq_MHz(30)) btn2(.clk(clk_30),.rst(sys_reset),.btn_in(w_en),.btn_pulse(w_en_p));
    
    FIFO #(.BUS_WIDTH(8)) fifo(.data_in(data_in),
                               .wclk(clk_30), .wen(w_en_p), .wrst_n(~sys_reset),
                               .rclk(clk_50), .ren(r_en_p), .rrst_n(~sys_reset),
                               .full(full), .empty(empty),
                               .data_out(data_out));
    
endmodule
