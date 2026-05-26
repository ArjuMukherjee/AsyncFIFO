module button_pulse_gen #(parameter freq_MHz = 100) (
    input clk,              // Connect to your main system clock (e.g., 50 MHz or 100 MHz)
    input rst,              // System reset
    input btn_in,           // Raw bouncy button input from Basys 3 pin
    output reg btn_pulse    // Perfect 1-clock-cycle pulse for wr_en / rd_en
);

    // ==========================================
    // STEP 1: The "Slow" Sampling Enable
    // ==========================================
    localparam count = freq_MHz * 10000 - 1;
    localparam bit_width = $clog2(count);
    reg [bit_width:0] clk_div = 0;
    wire slow_sample_tick = (clk_div == count);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            clk_div <= 0;
        end else if (slow_sample_tick) begin
            clk_div <= 0;
        end else begin
            clk_div <= clk_div + 1;
        end
    end

    // ==========================================
    // STEP 2: Debouncing (Filtering out the bounce)
    // ==========================================
    reg [2:0] shift_reg = 3'b000;
    reg debounced_btn = 1'b0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            shift_reg     <= 3'b000;
            debounced_btn <= 1'b0;
        end else if (slow_sample_tick) begin
            shift_reg <= {shift_reg[1:0], btn_in};
            
            // If button is held high for 3 consecutive slow samples, it's stable
            if (shift_reg == 3'b111) begin
                debounced_btn <= 1'b1;
            end else if (shift_reg == 3'b000) begin
                debounced_btn <= 1'b0;
            end
        end
    end

    // ==========================================
    // STEP 3: Edge Detection (Creating the 1-cycle pulse)
    // ==========================================
    reg debounced_btn_d1 = 1'b0; // Delayed version of the stable button state

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            debounced_btn_d1 <= 1'b0;
            btn_pulse        <= 1'b0;
        end else begin
            debounced_btn_d1 <= debounced_btn; // Delay by 1 clock cycle
            
            // Generates a pulse ONLY on the rising edge
            // It triggers when the current state is HIGH, but the previous cycle was LOW
            btn_pulse <= debounced_btn && (~debounced_btn_d1);
        end
    end

endmodule